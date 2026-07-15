import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomMarkerPainter {
  static Future<BitmapDescriptor> createMarker({
    required Color fillColor,
    required Color borderColor,
    required IconData icon,
    double size = 48,
  }) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint();

    // Outer circle (border)
    paint.color = borderColor;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

    // Inner circle (fill)
    paint.color = fillColor;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2 - 3, paint);

    // Icon
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: size * 0.45,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: borderColor,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  /// Load and resize the top-down car icon asset
  static Future<BitmapDescriptor> carAssetMarker() async {
    return await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(45, 45)),
      'assets/images/map_navigator_icon.png',
      width: 45,
    );
  }

  /// Top-down 2D car icon (Uber-style) — for driver location
  static Future<BitmapDescriptor> driverMarker() async {
    const double size = 56;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint();

    final cx = size / 2;
    final cy = size / 2;

    // Shadow
    paint.color = const Color(0x40000000);
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 2), width: 28, height: 36),
      paint,
    );
    paint.maskFilter = null;

    // White circle background
    paint.color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), 24, paint);

    // Gold border ring
    paint
      ..color = const Color(0xFFD4A843)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(Offset(cx, cy), 24, paint);
    paint.style = PaintingStyle.fill;

    // Car body (dark rounded rect, pointing up)
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy), width: 18, height: 30),
      const Radius.circular(6),
    );
    paint.color = const Color(0xFF1A1A2E);
    canvas.drawRRect(bodyRect, paint);

    // Windshield (lighter blue at front/top)
    final windshieldRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 7, cy - 11, 14, 8),
      const Radius.circular(3),
    );
    paint.color = const Color(0xFF4A6FA5);
    canvas.drawRRect(windshieldRect, paint);

    // Rear window (smaller, darker, at back/bottom)
    final rearRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 6, cy + 5, 12, 5),
      const Radius.circular(2),
    );
    paint.color = const Color(0xFF2C3E50);
    canvas.drawRRect(rearRect, paint);

    // Side mirrors
    paint.color = const Color(0xFF1A1A2E);
    canvas.drawCircle(Offset(cx - 11, cy - 4), 2.5, paint);
    canvas.drawCircle(Offset(cx + 11, cy - 4), 2.5, paint);

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  static Future<ui.Image?> _loadNetworkImage(String url) async {
    try {
      final imageProvider = NetworkImage(url);
      final stream = imageProvider.resolve(const ImageConfiguration());
      final completer = Completer<ui.Image>();
      stream.addListener(ImageStreamListener((info, _) {
        completer.complete(info.image);
      }, onError: (error, stackTrace) {
        completer.completeError(error);
      }));
      return await completer.future;
    } catch (e) {
      return null;
    }
  }

  /// Profile pin marker — for pickup location
  static Future<BitmapDescriptor> pickupMarker({required bool isDark, String? avatarUrl}) async {
    const double size = 120; // High resolution size for crisp marker
    const double radius = 40;
    final cx = size / 2;
    final cy = size / 2 - 10;
    
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint();

    // Shadow
    paint.color = Colors.black.withOpacity(0.2);
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(cx, cy + 20), radius, paint);
    paint.maskFilter = null;

    // Pin shape (circle + bottom triangle)
    final path = Path();
    path.addOval(Rect.fromCircle(center: Offset(cx, cy), radius: radius));
    path.moveTo(cx - 20, cy + radius - 5);
    path.lineTo(cx, cy + radius + 20);
    path.lineTo(cx + 20, cy + radius - 5);
    path.close();

    // Fill pin background
    paint.color = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    canvas.drawPath(path, paint);

    // Inner circle background
    final innerRadius = radius - 6;
    paint.color = isDark ? const Color(0xFF2C3E50) : const Color(0xFFF0F0F0);
    canvas.drawCircle(Offset(cx, cy), innerRadius, paint);

    ui.Image? avatarImage;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      avatarImage = await _loadNetworkImage(avatarUrl);
    }

    if (avatarImage != null) {
      // Draw image clipped to inner circle
      canvas.save();
      canvas.clipPath(Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: innerRadius)));
      
      final src = Rect.fromLTWH(0, 0, avatarImage.width.toDouble(), avatarImage.height.toDouble());
      
      // Calculate destination rect to cover the circle (aspect fill)
      final scale = (innerRadius * 2) / (avatarImage.width < avatarImage.height ? avatarImage.width : avatarImage.height);
      final destWidth = avatarImage.width * scale;
      final destHeight = avatarImage.height * scale;
      final dest = Rect.fromCenter(center: Offset(cx, cy), width: destWidth, height: destHeight);
      
      canvas.drawImageRect(avatarImage, src, dest, Paint());
      canvas.restore();
    } else {
      // Draw default person icon
      final icon = Icons.person_rounded;
      final textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: innerRadius * 1.2,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          cx - textPainter.width / 2,
          cy - textPainter.height / 2,
        ),
      );
    }

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  /// Green glowing flag marker — for dropoff location
  static Future<BitmapDescriptor> dropoffMarker() async {
    const double size = 56;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint();

    // Green glow
    paint.color = const Color(0xFF4CAF50).withOpacity(0.25);
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);
    paint.maskFilter = null;

    // Outer circle (green border)
    paint.color = const Color(0xFF4CAF50);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2 - 4, paint);

    // Inner circle (dark fill)
    paint.color = const Color(0xFF1A1A2E);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2 - 7, paint);

    // Flag icon
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(Icons.flag_rounded.codePoint),
      style: TextStyle(
        fontSize: size * 0.40,
        fontFamily: Icons.flag_rounded.fontFamily,
        package: Icons.flag_rounded.fontPackage,
        color: const Color(0xFF4CAF50),
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  /// Dark circle with gold border — for intermediate stops
  static Future<BitmapDescriptor> stopMarker() {
    return createMarker(
      fillColor: const Color(0xFF1A1A2E),
      borderColor: const Color(0xFFD4A843),
      icon: Icons.location_on_rounded,
      size: 44,
    );
  }
}

