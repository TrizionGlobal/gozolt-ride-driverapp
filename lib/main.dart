import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Force orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // Initialize Firebase with timeout
    try {
      await Firebase.initializeApp().timeout(
        const Duration(seconds: 5),
      );
    } catch (e) {
      debugPrint('Main: Firebase init error or timeout: $e');
    }

    // Initialize Stripe
    try {
      Stripe.publishableKey = AppConstants.stripePublishableKey;
      await Stripe.instance.applySettings().timeout(
        const Duration(seconds: 3),
      );
    } catch (e) {
      debugPrint('Main: Stripe error or timeout: $e');
    }

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    runApp(
      const ProviderScope(
        child: GozoltDriverApp(),
      ),
    );
  } catch (e, stack) {
    debugPrint('CRITICAL STARTUP ERROR: $e');
    debugPrint(stack.toString());
    
    // Fallback minimal app
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error starting app: $e'),
          ),
        ),
      ),
    );
  }
}
