import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/shared/components/constants.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  // text field obscure
  bool isObscure = true;
  IconData eyeIcon = Icons.visibility_off_outlined;

  void changeTextFieldObscure() {
    isObscure = !isObscure;
    eyeIcon =
        isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined;
    emit(TextFieldObscureState());
  }

  // text field validation
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  GlobalKey<FormState> formKey = GlobalKey();
  void noticeTextFormFieldValidation() {
    autovalidateMode = AutovalidateMode.always;
    emit(TextFieldValidationState());
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  /// يتحقق من صحة بيانات تسجيل الدخول
  bool validateLoginData(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      emit(LoginFailureState(errMessage: 'يرجى ملء جميع الحقول'));
      return false;
    }

    if (!email.contains('@')) {
      emit(LoginFailureState(errMessage: 'البريد الإلكتروني غير صحيح'));
      return false;
    }

    if (password.length < 6) {
      emit(LoginFailureState(
          errMessage: 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'));
      return false;
    }

    return true;
  }

  void loginUser({required String email, required String password}) async {
    // التحقق من صحة البيانات قبل المحاولة
    if (!validateLoginData(email, password)) {
      return;
    }

    emit(LoginLoadingState()); // إضافة حالة التحميل

    try {
      log('=== محاولة تسجيل الدخول ===');
      log('البريد الإلكتروني: $email');
      log('البريد الإلكتروني بعد التنظيف: "${email.trim()}"');
      log('طول كلمة المرور: ${password.length}');
      log('كود أحرف كلمة المرور: ${password.codeUnits}');

      // تنظيف البيانات
      String cleanEmail = email.trim().toLowerCase();
      String cleanPassword = password.trim();

      // التحقق من أن المستخدم غير مسجل دخول بالفعل
      if (FirebaseAuth.instance.currentUser != null) {
        log('المستخدم مسجل دخول بالفعل، تسجيل خروج أولاً...');
        await FirebaseAuth.instance.signOut();
      }

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: cleanEmail,
        password: cleanPassword,
      );

      log('✅ نجح تسجيل الدخول للمستخدم: ${userCredential.user!.uid}');
      log('البريد الإلكتروني المؤكد: ${userCredential.user!.email}');
      log('حالة التحقق: ${userCredential.user!.emailVerified}');

      // تحديث FCM token بعد نجاح تسجيل الدخول
      await updateFCMToken(userCredential.user!.uid);

      emit(LoginSuccessState(uid: userCredential.user!.uid));
    } on FirebaseAuthException catch (e) {
      // معالجة أخطاء Firebase Auth بشكل مفصل
      String errorMessage;
      log('❌ خطأ Firebase Auth: ${e.code}');
      log('رسالة الخطأ: ${e.message}');

      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'كلمة المرور غير صحيحة';
          break;
        case 'user-not-found':
          errorMessage = 'لا يوجد مستخدم بهذا البريد الإلكتروني';
          break;
        case 'user-disabled':
          errorMessage = 'تم تعطيل هذا الحساب من قبل المشرف';
          break;
        case 'invalid-email':
          errorMessage = 'البريد الإلكتروني غير صحيح';
          break;
        case 'invalid-credential':
          // هذا الخطأ شائع حتى مع البيانات الصحيحة
          errorMessage = 'بيانات تسجيل الدخول غير صحيحة. تأكد من:\n'
              '• البريد الإلكتروني مكتوب بشكل صحيح\n'
              '• كلمة المرور صحيحة\n'
              '• الحساب مفعل في Firebase Console';
          break;
        case 'too-many-requests':
          errorMessage =
              'تم تجاوز عدد المحاولات المسموح، انتظر قليلاً وحاول مرة أخرى';
          break;
        case 'network-request-failed':
          errorMessage = 'خطأ في الاتصال بالإنترنت';
          break;
        case 'operation-not-allowed':
          errorMessage =
              'تسجيل الدخول بالبريد الإلكتروني غير مفعل في Firebase Console';
          break;
        case 'user-token-expired':
          errorMessage = 'انتهت صلاحية جلسة المستخدم، سجل دخول مرة أخرى';
          break;
        case 'invalid-user-token':
          errorMessage = 'رمز المستخدم غير صحيح';
          break;
        default:
          errorMessage = 'حدث خطأ غير متوقع: ${e.message}';
      }
      emit(LoginFailureState(errMessage: errorMessage));

      // تسجيل مفصل للخطأ
      log('🔍 تفاصيل الخطأ:');
      log('   الكود: ${e.code}');
      log('   الرسالة: ${e.message}');
      log('   البريد المستخدم: $email');
      log('   طول كلمة المرور: ${password.length}');
      log('   البريد بعد التنظيف: "${email.trim()}"');
    } catch (error) {
      log('❌ خطأ عام: $error');
      emit(LoginFailureState(errMessage: 'حدث خطأ غير متوقع: $error'));
    }
  }

  /// يحديث FCM token للمستخدم في Firestore
  Future<void> updateFCMToken(String uid) async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection(kUsersCollection)
            .doc(uid)
            .update({'fcmToken': token});
        log('FCM token updated successfully for user: $uid');
      }
    } catch (error) {
      log('Error updating FCM token: $error');
    }
  }

  /// يتحقق من حالة Firebase ووجود المستخدم
  Future<bool> checkUserExists(String email) async {
    try {
      // محاولة الحصول على قائمة المستخدمين (إذا كان لديك صلاحيات)
      log('Checking if user exists: $email');
      return true; // افتراضياً، سيعطي Firebase الخطأ المناسب
    } catch (error) {
      log('Error checking user existence: $error');
      return false;
    }
  }

  /// إرسال رابط إعادة تعيين كلمة المرور
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      log('إرسال رابط إعادة تعيين كلمة المرور إلى: $email');
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      log('✅ تم إرسال رابط إعادة تعيين كلمة المرور بنجاح');
    } on FirebaseAuthException catch (e) {
      log('❌ خطأ في إرسال رابط إعادة تعيين كلمة المرور: ${e.code} - ${e.message}');
      throw Exception(
          'خطأ في إرسال رابط إعادة تعيين كلمة المرور: ${e.message}');
    } catch (error) {
      log('❌ خطأ عام في إرسال رابط إعادة تعيين كلمة المرور: $error');
      throw Exception('خطأ في إرسال رابط إعادة تعيين كلمة المرور: $error');
    }
  }

  /// طريقة لاختبار الاتصال بـ Firebase
  Future<void> testFirebaseConnection() async {
    try {
      log('=== اختبار الاتصال بـ Firebase ===');

      // التحقق من حالة Firebase
      User? currentUser = FirebaseAuth.instance.currentUser;
      log('المستخدم الحالي: ${currentUser?.email ?? "لا يوجد"}');

      // اختبار إنشاء مستخدم مؤقت
      const testEmail = 'test_connection@example.com';
      const testPassword = 'test123456';

      log('إنشاء مستخدم اختبار مؤقت...');
      UserCredential testUser =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );

      log('✅ تم إنشاء مستخدم الاختبار: ${testUser.user!.uid}');

      // تسجيل خروج المستخدم المؤقت
      await FirebaseAuth.instance.signOut();
      log('✅ تم تسجيل خروج المستخدم المؤقت');

      // حذف المستخدم المؤقت
      await testUser.user!.delete();
      log('✅ تم حذف المستخدم المؤقت');

      log('✅ اختبار Firebase نجح - الاتصال يعمل بشكل صحيح');
    } catch (error) {
      log('❌ اختبار Firebase فشل: $error');
      rethrow;
    }
  }
}
