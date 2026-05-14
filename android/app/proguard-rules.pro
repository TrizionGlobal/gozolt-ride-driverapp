# Stripe
-keep class com.stripe.android.** { *; }
-dontwarn com.stripe.android.**
-keep class com.reactnativestripesdk.** { *; }
-dontwarn com.reactnativestripesdk.**

# Push Provisioning
-dontwarn com.stripe.android.pushProvisioning.**
-keep class com.stripe.android.pushProvisioning.** { *; }
