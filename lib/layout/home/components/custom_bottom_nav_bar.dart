import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/modules/new_post/new_post.dart';
import 'package:social_media_app/shared/bloc/social_cubit/social_cubit.dart';
import 'package:social_media_app/shared/components/bottom_bar_cilper.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return BlocBuilder<SocialCubit, SocialState>(
      builder: (context, state) {
        var cubit = context.read<SocialCubit>();

        return Container(
          width: width,
          height: 100,
          color: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              /// الـ Bar الأساسي
              Positioned(
                bottom: 3, // البعد عن أسفل الشاشة بمقدار 3
                left: 15, // بادينج من الشمال
                right: 15, // بادينج من اليمين
                child: CustomPaint(
                  // العرض هنا بيقل بسبب الـ Padding (15 من كل ناحية)
                  size: Size(width - 30, 70),
                  painter: BottomBarShadowPainter(),
                  child: ClipPath(
                    clipper: BottomBarClipper(),
                    child: Container(
                      height: 70,
                      color: const Color(0xffF5F5F5),
                      child: BottomNavigationBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        type: BottomNavigationBarType.fixed,
                        selectedItemColor: const Color(0xff6A5C93),
                        unselectedItemColor: Colors.grey,
                        currentIndex: cubit.currentBottomNavBarIndex,
                        onTap: cubit.changeBottomNavBar,
                        items: cubit.bottomNavigationBarItem,
                      ),
                    ),
                  ),
                ),
              ),

              /// زر الإضافة (FAB)
              Positioned(
                bottom: 38, // تم رفعه ليتناسب مع الـ bottom: 3 الجديد
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff6A5C93).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: FloatingActionButton(
                      elevation: 0,
                      backgroundColor: const Color(0xff6A5C93),
                      onPressed: () {
                        // Logic
                      },
                      child: const Icon(Icons.add,
                          color: Color(0xffD2C0DD), size: 32),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BottomBarShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // بننادي على الـ Clipper اللي إحنا عملناه عشان نجيب نفس المسار
    Path path = BottomBarClipper().getClip(size);

    // 1. رسم الظل (Shadow)
    // نستخدم drawShadow عشان الظل يمشي مع انحناءات الكيرف بالظبط
    canvas.drawShadow(
        path,
        Colors.black.withValues(alpha: 0.3), // قوة الظل
        8.0, // مدى الانتشار (Blur)
        false // هل الشكل شفاف؟ (false تعني شكل مصمت)
        );

    // 2. رسم الحدود (Border) - الخط البنفسجي اللي في الصورة
    Paint paint = Paint()
      ..color = const Color(0xffBA85E8) // نفس الدرجة البنفسجي اللي في صورتك
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0; // سمك الخط

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
