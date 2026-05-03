import 'dart:ui' as ui;
import 'package:flutter/material.dart';
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

  /// Dark circle with gold border — for pickup location
  static Future<BitmapDescriptor> pickupMarker() {
    return createMarker(
      fillColor: const Color(0xFF1A1A2E),
      borderColor: const Color(0xFFE53935),
      icon: Icons.person_pin_circle,
      size: 48,
    );
  }

  /// Green glowing flag marker — for dropoff location
  static Future<BitmapDescriptor> dropoffMarker() async {
    const double size = 56;
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint();

    // Green glow
    paint.color = const Color(0xFF4CAF50).withValues(alpha: 0.25);
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
