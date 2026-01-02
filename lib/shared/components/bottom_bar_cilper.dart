import 'package:flutter/material.dart';

class BottomBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double width = size.width;
    double height = size.height;
    double fabSize = 80.0; 
    double radius = 20.0; // درجة الانحناء للأركان

    Path path = Path();
    
    // البداية من الزاوية الشمال فوق
    path.moveTo(radius, 0);
    
    // 1. الكيرف العلوي مع فتحة الـ FAB
    path.lineTo((width - fabSize) / 2 - 10, 0);
    path.cubicTo(
      (width - fabSize) / 2 + 5, 0,
      (width - fabSize) / 2 + 5, fabSize * 0.5,
      width / 2, fabSize * 0.5,
    );
    path.cubicTo(
      (width + fabSize) / 2 - 5, fabSize * 0.5,
      (width + fabSize) / 2 - 5, 0,
      (width + fabSize) / 2 + 10, 0,
    );
    path.lineTo(width - radius, 0);

    // 2. الزاوية اليمين فوق
    path.quadraticBezierTo(width, 0, width, radius);
    
    // 3. الزاوية اليمين تحت (التعديل الجديد)
    path.lineTo(width, height - radius);
    path.quadraticBezierTo(width, height, width - radius, height);
    
    // 4. الزاوية الشمال تحت (التعديل الجديد)
    path.lineTo(radius, height);
    path.quadraticBezierTo(0, height, 0, height - radius);
    
    // 5. الزاوية الشمال فوق للغلق
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}