import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/splash/presentation/force_update_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/auth/presentation/registration_screen.dart';
import '../../features/auth/presentation/registration_status_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/forgot_password/forgot_password_screen.dart';
import '../../features/auth/presentation/forgot_password/forgot_password_otp_screen.dart';
import '../../features/auth/presentation/forgot_password/reset_password_screen.dart';
import '../../features/auth/presentation/forgot_password/reset_success_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/domain/models/auth_state.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/home/presentation/notifications/notification_screen.dart';
import '../theme/app_colors.dart';
import '../providers/storage_provider.dart';
import 'route_names.dart';
import 'startup_provider.dart';

import '../../features/partner_services/domain/models/partner_service_type.dart';
import '../../features/partner_services/presentation/screens/partner_service_selection_screen.dart';
import '../../features/food_grocery_delivery/presentation/screens/food_grocery_delivery_home_screen.dart';
import '../../features/food_grocery_delivery/presentation/screens/incoming_delivery_request_screen.dart';
import '../../features/food_grocery_delivery/presentation/screens/delivery_job_details_screen.dart';
import '../../features/food_grocery_delivery/domain/models/delivery_job_stage.dart';
import '../../features/food_grocery_delivery/presentation/providers/food_grocery_delivery_home_provider.dart';
import '../../features/food_grocery_delivery/presentation/providers/food_grocery_delivery_session_provider.dart';
import '../../features/food_grocery_delivery/presentation/screens/navigate_to_pickup_screen.dart';
import '../../features/food_grocery_delivery/presentation/screens/pickup_at_business_screen.dart';
import '../../features/food_grocery_delivery/presentation/providers/delivery_pickup_status_provider.dart';
import '../../features/food_grocery_delivery/presentation/screens/pickup_verification_screen.dart';
import '../../features/food_grocery_delivery/presentation/providers/pickup_verification_provider.dart';
import '../../features/food_grocery_delivery/presentation/screens/navigate_to_customer_screen.dart';
import '../../features/food_grocery_delivery/presentation/providers/handover_verification_provider.dart';
import '../../features/food_grocery_delivery/presentation/screens/customer_handover_screen.dart';
import '../../features/food_grocery_delivery/presentation/screens/cash_collection_screen.dart';
import '../../features/food_grocery_delivery/presentation/providers/cash_collection_provider.dart';
import '../../features/food_grocery_delivery/presentation/screens/delivery_completed_screen.dart';
import '../../features/food_grocery_delivery/presentation/providers/delivery_history_provider.dart';
import '../../features/food_grocery_delivery/presentation/screens/delivery_history_earnings_screen.dart';
import '../../features/food_grocery_delivery/presentation/screens/delivery_cash_activity_screen.dart';
import '../../features/food_grocery_delivery/presentation/screens/food_grocery_partner_account_screen.dart';
import '../../features/partner_services/presentation/providers/partner_availability_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final startupNotifier = ref.watch(startupProvider);

  return GoRouter(
    restorationScopeId: 'router',
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    refreshListenable: startupNotifier,
    redirect: (context, state) {
      final isInitialized = startupNotifier.value;
      final isGoingToSplash = state.uri.path == RouteNames.splash;

      if (!isInitialized && !isGoingToSplash) {
        // If not initialized and trying to go somewhere else (like when OS restores app),
        // intercept and go to splash, remembering where they wanted to go.
        return '${RouteNames.splash}?from=${state.uri.path}';
      }

      if (!isInitialized) return null;

      if (state.matchedLocation == '/force-update') {
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/force-update',
        name: 'forceUpdate',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>? ?? {};
          return ForceUpdateScreen(
            iosStoreUrl: extras['iosStoreUrl'] ?? '',
            androidStoreUrl: extras['androidStoreUrl'] ?? '',
          );
        },
      ),
      GoRoute(
        path: RouteNames.welcome,
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        builder: (context, state) => const RegistrationScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.otp,
        name: 'otp',
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        builder: (context, state) => const HomeShell(),
      ),
      GoRoute(
        path: RouteNames.partnerServices,
        name: 'partnerServices',
        builder: (context, state) {
          return PartnerServiceSelectionScreen(
            onServiceSelected: (service) {
              switch (service) {
                case PartnerServiceType.cabBooking:
                  context.push(RouteNames.home);

                case PartnerServiceType.foodDelivery:
                  context.go(RouteNames.foodDeliveryHome);

                case PartnerServiceType.groceryDelivery:
                  context.go(RouteNames.groceryDeliveryHome);
              }
            },
          );
        },
      ),

//------------------------- FOOD_GROCERY_MODULE-----------------------------------------

      GoRoute(
        path: RouteNames.foodDeliveryHome,
        name: 'foodDeliveryHome',
        builder: (context, state) {
          return FoodGroceryDeliveryHomeScreen(
            serviceType: PartnerServiceType.foodDelivery,
            onChangeService: () {
              context.go(RouteNames.partnerServices);
            },
            onContinueDelivery: () {
              context.push(
                RouteNames.foodDeliveryJobDetails,
              );
            },
            onSimulateIncomingRequest: () {
              context.push(RouteNames.foodDeliveryRequest);
            },
            onNavigationSelected: (index) {
              switch (index) {
                case 1:
                  context.go(
                    RouteNames.foodDeliveryEarnings,
                  );

                case 2:
                  context.go(
                    RouteNames.foodDeliveryHistory,
                  );

                case 3:
                  context.go(
                    RouteNames.foodDeliveryAccount,
                  );

                default:
                  return;
              }
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.foodDeliveryRequest,
        name: 'foodDeliveryRequest',
        builder: (context, state) {
          return IncomingDeliveryRequestScreen(
            serviceType: PartnerServiceType.foodDelivery,
            onAccepted: () {
              context.go(RouteNames.foodDeliveryHome);
            },
            onDeclined: () {
              context.go(RouteNames.foodDeliveryHome);
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.groceryDeliveryHome,
        name: 'groceryDeliveryHome',
        builder: (context, state) {
          return FoodGroceryDeliveryHomeScreen(
            serviceType: PartnerServiceType.groceryDelivery,
            onChangeService: () {
              context.go(RouteNames.partnerServices);
            },
            onContinueDelivery: () {
              context.push(
                RouteNames.groceryDeliveryJobDetails,
              );
            },
            onSimulateIncomingRequest: () {
              context.push(RouteNames.groceryDeliveryRequest);
            },
            onNavigationSelected: (index) {
              switch (index) {
                case 1:
                  context.go(
                    RouteNames.groceryDeliveryEarnings,
                  );

                case 2:
                  context.go(
                    RouteNames.groceryDeliveryHistory,
                  );

                case 3:
                  context.go(
                    RouteNames.groceryDeliveryAccount,
                  );

                default:
                  return;
              }
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.groceryDeliveryRequest,
        name: 'groceryDeliveryRequest',
        builder: (context, state) {
          return IncomingDeliveryRequestScreen(
            serviceType: PartnerServiceType.groceryDelivery,
            onAccepted: () {
              context.go(RouteNames.groceryDeliveryHome);
            },
            onDeclined: () {
              context.go(RouteNames.groceryDeliveryHome);
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.foodDeliveryJobDetails,
        name: 'foodDeliveryJobDetails',
        builder: (context, state) {
          return DeliveryJobDetailsScreen(
            serviceType: PartnerServiceType.foodDelivery,
            onBackToHome: () {
              context.go(RouteNames.foodDeliveryHome);
            },
            onNavigateToPickup: () {
              ref
                  .read(
                    foodGroceryDeliverySessionProvider(
                      PartnerServiceType.foodDelivery,
                    ).notifier,
                  )
                  .updateStage(
                    DeliveryJobStage.navigatingToPickup,
                  );

              ref
                  .read(
                    foodGroceryDeliveryHomeProvider(
                      PartnerServiceType.foodDelivery,
                    ).notifier,
                  )
                  .updateActiveDeliveryStage(
                    DeliveryJobStage.navigatingToPickup,
                  );

              context.go(
                RouteNames.foodDeliveryNavigateToPickup,
              );
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.groceryDeliveryJobDetails,
        name: 'groceryDeliveryJobDetails',
        builder: (context, state) {
          return DeliveryJobDetailsScreen(
            serviceType: PartnerServiceType.groceryDelivery,
            onBackToHome: () {
              context.go(RouteNames.groceryDeliveryHome);
            },
            onNavigateToPickup: () {
              ref
                  .read(
                    foodGroceryDeliverySessionProvider(
                      PartnerServiceType.groceryDelivery,
                    ).notifier,
                  )
                  .updateStage(
                    DeliveryJobStage.navigatingToPickup,
                  );

              ref
                  .read(
                    foodGroceryDeliveryHomeProvider(
                      PartnerServiceType.groceryDelivery,
                    ).notifier,
                  )
                  .updateActiveDeliveryStage(
                    DeliveryJobStage.navigatingToPickup,
                  );

              context.go(
                RouteNames.groceryDeliveryNavigateToPickup,
              );
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.foodDeliveryNavigateToPickup,
        name: 'foodDeliveryNavigateToPickup',
        builder: (context, state) {
          return NavigateToPickupScreen(
            serviceType: PartnerServiceType.foodDelivery,
            onBack: () {
              context.go(
                RouteNames.foodDeliveryJobDetails,
              );
            },
            onArrivedAtPickup: () {
              ref
                  .read(
                    foodGroceryDeliverySessionProvider(
                      PartnerServiceType.foodDelivery,
                    ).notifier,
                  )
                  .updateStage(
                    DeliveryJobStage.arrivedAtPickup,
                  );

              ref
                  .read(
                    foodGroceryDeliveryHomeProvider(
                      PartnerServiceType.foodDelivery,
                    ).notifier,
                  )
                  .updateActiveDeliveryStage(
                    DeliveryJobStage.arrivedAtPickup,
                  );

              ref
                  .read(
                    deliveryPickupStatusProvider(
                      PartnerServiceType.foodDelivery,
                    ).notifier,
                  )
                  .reset();

              context.go(
                RouteNames.foodDeliveryPickup,
              );
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.groceryDeliveryNavigateToPickup,
        name: 'groceryDeliveryNavigateToPickup',
        builder: (context, state) {
          return NavigateToPickupScreen(
            serviceType: PartnerServiceType.groceryDelivery,
            onBack: () {
              context.go(
                RouteNames.groceryDeliveryJobDetails,
              );
            },
            onArrivedAtPickup: () {
              ref
                  .read(
                    foodGroceryDeliverySessionProvider(
                      PartnerServiceType.groceryDelivery,
                    ).notifier,
                  )
                  .updateStage(
                    DeliveryJobStage.arrivedAtPickup,
                  );

              ref
                  .read(
                    foodGroceryDeliveryHomeProvider(
                      PartnerServiceType.groceryDelivery,
                    ).notifier,
                  )
                  .updateActiveDeliveryStage(
                    DeliveryJobStage.arrivedAtPickup,
                  );

              ref
                  .read(
                    deliveryPickupStatusProvider(
                      PartnerServiceType.groceryDelivery,
                    ).notifier,
                  )
                  .reset();

              context.go(
                RouteNames.groceryDeliveryPickup,
              );
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.foodDeliveryPickup,
        name: 'foodDeliveryPickup',
        builder: (context, state) {
          return PickupAtBusinessScreen(
            serviceType: PartnerServiceType.foodDelivery,
            onBack: () {
              context.go(
                RouteNames.foodDeliveryNavigateToPickup,
              );
            },
            onVerifyPickup: () {
              ref
                  .read(
                    foodGroceryDeliverySessionProvider(
                      PartnerServiceType.foodDelivery,
                    ).notifier,
                  )
                  .updateStage(
                    DeliveryJobStage.pickupVerification,
                  );

              ref
                  .read(
                    foodGroceryDeliveryHomeProvider(
                      PartnerServiceType.foodDelivery,
                    ).notifier,
                  )
                  .updateActiveDeliveryStage(
                    DeliveryJobStage.pickupVerification,
                  );

              ref
                  .read(
                    pickupVerificationProvider(
                      PartnerServiceType.foodDelivery,
                    ).notifier,
                  )
                  .reset();

              context.go(
                RouteNames.foodDeliveryPickupVerification,
              );
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.groceryDeliveryPickup,
        name: 'groceryDeliveryPickup',
        builder: (context, state) {
          return PickupAtBusinessScreen(
            serviceType: PartnerServiceType.groceryDelivery,
            onBack: () {
              context.go(
                RouteNames.groceryDeliveryNavigateToPickup,
              );
            },
            onVerifyPickup: () {
              ref
                  .read(
                    foodGroceryDeliverySessionProvider(
                      PartnerServiceType.groceryDelivery,
                    ).notifier,
                  )
                  .updateStage(
                    DeliveryJobStage.pickupVerification,
                  );

              ref
                  .read(
                    foodGroceryDeliveryHomeProvider(
                      PartnerServiceType.groceryDelivery,
                    ).notifier,
                  )
                  .updateActiveDeliveryStage(
                    DeliveryJobStage.pickupVerification,
                  );

              ref
                  .read(
                    pickupVerificationProvider(
                      PartnerServiceType.groceryDelivery,
                    ).notifier,
                  )
                  .reset();

              context.go(
                RouteNames.groceryDeliveryPickupVerification,
              );
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.foodDeliveryPickupVerification,
        name: 'foodDeliveryPickupVerification',
        builder: (context, state) {
          return PickupVerificationScreen(
            serviceType: PartnerServiceType.foodDelivery,
            onBack: () {
              context.go(
                RouteNames.foodDeliveryPickup,
              );
            },
            onVerified: () {
              ref
                  .read(
                    foodGroceryDeliverySessionProvider(
                      PartnerServiceType.foodDelivery,
                    ).notifier,
                  )
                  .updateStage(
                    DeliveryJobStage.navigatingToCustomer,
                  );

              ref
                  .read(
                    foodGroceryDeliveryHomeProvider(
                      PartnerServiceType.foodDelivery,
                    ).notifier,
                  )
                  .updateActiveDeliveryStage(
                    DeliveryJobStage.navigatingToCustomer,
                  );

              context.go(
                RouteNames.foodDeliveryNavigateToCustomer,
              );
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.groceryDeliveryPickupVerification,
        name: 'groceryDeliveryPickupVerification',
        builder: (context, state) {
          return PickupVerificationScreen(
            serviceType: PartnerServiceType.groceryDelivery,
            onBack: () {
              context.go(
                RouteNames.groceryDeliveryPickup,
              );
            },
            onVerified: () {
              ref
                  .read(
                    foodGroceryDeliverySessionProvider(
                      PartnerServiceType.groceryDelivery,
                    ).notifier,
                  )
                  .updateStage(
                    DeliveryJobStage.navigatingToCustomer,
                  );

              ref
                  .read(
                    foodGroceryDeliveryHomeProvider(
                      PartnerServiceType.groceryDelivery,
                    ).notifier,
                  )
                  .updateActiveDeliveryStage(
                    DeliveryJobStage.navigatingToCustomer,
                  );

              context.go(
                RouteNames.groceryDeliveryNavigateToCustomer,
              );
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.foodDeliveryNavigateToCustomer,
        name: 'foodDeliveryNavigateToCustomer',
        builder: (context, state) {
          return NavigateToCustomerScreen(
            serviceType: PartnerServiceType.foodDelivery,
            onBack: () {
              context.go(
                RouteNames.foodDeliveryPickupVerification,
              );
            },
            onArrivedAtCustomer: () {
              ref
                  .read(
                    foodGroceryDeliverySessionProvider(
                      PartnerServiceType.foodDelivery,
                    ).notifier,
                  )
                  .updateStage(
                    DeliveryJobStage.handoverVerification,
                  );

              ref
                  .read(
                    foodGroceryDeliveryHomeProvider(
                      PartnerServiceType.foodDelivery,
                    ).notifier,
                  )
                  .updateActiveDeliveryStage(
                    DeliveryJobStage.handoverVerification,
                  );

              ref
                  .read(
                    handoverVerificationProvider(
                      PartnerServiceType.foodDelivery,
                    ).notifier,
                  )
                  .reset();

              context.go(
                RouteNames.foodDeliveryCustomerHandover,
              );
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.groceryDeliveryNavigateToCustomer,
        name: 'groceryDeliveryNavigateToCustomer',
        builder: (context, state) {
          return NavigateToCustomerScreen(
            serviceType: PartnerServiceType.groceryDelivery,
            onBack: () {
              context.go(
                RouteNames.groceryDeliveryPickupVerification,
              );
            },
            onArrivedAtCustomer: () {
              ref
                  .read(
                    foodGroceryDeliverySessionProvider(
                      PartnerServiceType.groceryDelivery,
                    ).notifier,
                  )
                  .updateStage(
                    DeliveryJobStage.handoverVerification,
                  );

              ref
                  .read(
                    foodGroceryDeliveryHomeProvider(
                      PartnerServiceType.groceryDelivery,
                    ).notifier,
                  )
                  .updateActiveDeliveryStage(
                    DeliveryJobStage.handoverVerification,
                  );

              ref
                  .read(
                    handoverVerificationProvider(
                      PartnerServiceType.groceryDelivery,
                    ).notifier,
                  )
                  .reset();

              context.go(
                RouteNames.groceryDeliveryCustomerHandover,
              );
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.foodDeliveryCustomerHandover,
        name: 'foodDeliveryCustomerHandover',
        builder: (context, state) {
          return CustomerHandoverScreen(
            serviceType: PartnerServiceType.foodDelivery,
            onBack: () {
              context.go(
                RouteNames.foodDeliveryNavigateToCustomer,
              );
            },
            onVerified: () {
              final session = ref.read(
                foodGroceryDeliverySessionProvider(
                  PartnerServiceType.foodDelivery,
                ),
              );

              final job = session.activeJob;

              if (job == null) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text(
                        'No active delivery was found.',
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                return;
              }

              if (job.paymentMethod.requiresCashCollection) {
                ref
                    .read(
                      cashCollectionProvider(
                        PartnerServiceType.foodDelivery,
                      ).notifier,
                    )
                    .reset();

                ref
                    .read(
                      foodGroceryDeliverySessionProvider(
                        PartnerServiceType.foodDelivery,
                      ).notifier,
                    )
                    .updateStage(
                      DeliveryJobStage.cashCollection,
                    );

                ref
                    .read(
                      foodGroceryDeliveryHomeProvider(
                        PartnerServiceType.foodDelivery,
                      ).notifier,
                    )
                    .updateActiveDeliveryStage(
                      DeliveryJobStage.cashCollection,
                    );

                context.go(
                  RouteNames.foodDeliveryCashCollection,
                );
                return;
              }

              ref
                  .read(
                    foodGroceryDeliverySessionProvider(
                      PartnerServiceType.foodDelivery,
                    ).notifier,
                  )
                  .updateStage(
                    DeliveryJobStage.completed,
                  );

              ref
                  .read(
                    foodGroceryDeliveryHomeProvider(
                      PartnerServiceType.foodDelivery,
                    ).notifier,
                  )
                  .updateActiveDeliveryStage(
                    DeliveryJobStage.completed,
                  );

              context.go(
                RouteNames.foodDeliveryCompleted,
              );
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.groceryDeliveryCustomerHandover,
        name: 'groceryDeliveryCustomerHandover',
        builder: (context, state) {
          return CustomerHandoverScreen(
            serviceType: PartnerServiceType.groceryDelivery,
            onBack: () {
              context.go(
                RouteNames.groceryDeliveryNavigateToCustomer,
              );
            },
            onVerified: () {
              final session = ref.read(
                foodGroceryDeliverySessionProvider(
                  PartnerServiceType.groceryDelivery,
                ),
              );

              final job = session.activeJob;

              if (job == null) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text(
                        'No active delivery was found.',
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                return;
              }

              if (job.paymentMethod.requiresCashCollection) {
                ref
                    .read(
                      cashCollectionProvider(
                        PartnerServiceType.groceryDelivery,
                      ).notifier,
                    )
                    .reset();

                ref
                    .read(
                      foodGroceryDeliverySessionProvider(
                        PartnerServiceType.groceryDelivery,
                      ).notifier,
                    )
                    .updateStage(
                      DeliveryJobStage.cashCollection,
                    );

                ref
                    .read(
                      foodGroceryDeliveryHomeProvider(
                        PartnerServiceType.groceryDelivery,
                      ).notifier,
                    )
                    .updateActiveDeliveryStage(
                      DeliveryJobStage.cashCollection,
                    );

                context.go(
                  RouteNames.groceryDeliveryCashCollection,
                );
                return;
              }

              ref
                  .read(
                    foodGroceryDeliverySessionProvider(
                      PartnerServiceType.groceryDelivery,
                    ).notifier,
                  )
                  .updateStage(
                    DeliveryJobStage.completed,
                  );

              ref
                  .read(
                    foodGroceryDeliveryHomeProvider(
                      PartnerServiceType.groceryDelivery,
                    ).notifier,
                  )
                  .updateActiveDeliveryStage(
                    DeliveryJobStage.completed,
                  );

              context.go(
                RouteNames.groceryDeliveryCompleted,
              );
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.foodDeliveryCashCollection,
        name: 'foodDeliveryCashCollection',
        builder: (context, state) {
          return CashCollectionScreen(
            serviceType: PartnerServiceType.foodDelivery,
            onBack: () {
              context.go(
                RouteNames.foodDeliveryCustomerHandover,
              );
            },
            onCashCollected: () {
              ref
                  .read(
                    foodGroceryDeliverySessionProvider(
                      PartnerServiceType.foodDelivery,
                    ).notifier,
                  )
                  .updateStage(
                    DeliveryJobStage.completed,
                  );

              ref
                  .read(
                    foodGroceryDeliveryHomeProvider(
                      PartnerServiceType.foodDelivery,
                    ).notifier,
                  )
                  .updateActiveDeliveryStage(
                    DeliveryJobStage.completed,
                  );
              context.go(
                RouteNames.foodDeliveryCompleted,
              );
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.groceryDeliveryCashCollection,
        name: 'groceryDeliveryCashCollection',
        builder: (context, state) {
          return CashCollectionScreen(
            serviceType: PartnerServiceType.groceryDelivery,
            onBack: () {
              context.go(
                RouteNames.groceryDeliveryCustomerHandover,
              );
            },
            onCashCollected: () {
              ref
                  .read(
                    foodGroceryDeliverySessionProvider(
                      PartnerServiceType.groceryDelivery,
                    ).notifier,
                  )
                  .updateStage(
                    DeliveryJobStage.completed,
                  );

              ref
                  .read(
                    foodGroceryDeliveryHomeProvider(
                      PartnerServiceType.groceryDelivery,
                    ).notifier,
                  )
                  .updateActiveDeliveryStage(
                    DeliveryJobStage.completed,
                  );
              context.go(
                RouteNames.groceryDeliveryCompleted,
              );
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.foodDeliveryCompleted,
        name: 'foodDeliveryCompleted',
        builder: (context, state) {
          return DeliveryCompletedScreen(
            serviceType: PartnerServiceType.foodDelivery,
            onReturnHome: () {
              final session = ref.read(
                foodGroceryDeliverySessionProvider(
                  PartnerServiceType.foodDelivery,
                ),
              );

              final job = session.activeJob;

              if (job != null) {
                ref
                    .read(
                      deliveryHistoryProvider(
                        PartnerServiceType.foodDelivery,
                      ).notifier,
                    )
                    .recordCompletedDelivery(job);

                ref
                    .read(
                      foodGroceryDeliveryHomeProvider(
                        PartnerServiceType.foodDelivery,
                      ).notifier,
                    )
                    .recordCompletedDelivery(
                      deliveryId: job.deliveryId,
                      deliveryEarning: job.estimatedEarning,
                      cashCollected: job.paymentMethod.requiresCashCollection
                          ? job.cashAmountToCollect ?? 0
                          : 0,
                    );

                ref
                    .read(
                      partnerAvailabilityProvider.notifier,
                    )
                    .completeActiveWork(
                      service: PartnerServiceType.foodDelivery,
                      workId: job.deliveryId,
                    );
              }
              ref
                  .read(
                    foodGroceryDeliverySessionProvider(
                      PartnerServiceType.foodDelivery,
                    ).notifier,
                  )
                  .clearActiveJob();

              ref
                  .read(
                    foodGroceryDeliveryHomeProvider(
                      PartnerServiceType.foodDelivery,
                    ).notifier,
                  )
                  .clearActiveDelivery();

              context.go(
                RouteNames.foodDeliveryHome,
              );
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.groceryDeliveryCompleted,
        name: 'groceryDeliveryCompleted',
        builder: (context, state) {
          return DeliveryCompletedScreen(
            serviceType: PartnerServiceType.groceryDelivery,
            onReturnHome: () {
              final session = ref.read(
                foodGroceryDeliverySessionProvider(
                  PartnerServiceType.groceryDelivery,
                ),
              );

              final job = session.activeJob;

              if (job != null) {
                ref
                    .read(
                      deliveryHistoryProvider(
                        PartnerServiceType.groceryDelivery,
                      ).notifier,
                    )
                    .recordCompletedDelivery(job);

                ref
                    .read(
                      foodGroceryDeliveryHomeProvider(
                        PartnerServiceType.groceryDelivery,
                      ).notifier,
                    )
                    .recordCompletedDelivery(
                      deliveryId: job.deliveryId,
                      deliveryEarning: job.estimatedEarning,
                      cashCollected: job.paymentMethod.requiresCashCollection
                          ? job.cashAmountToCollect ?? 0
                          : 0,
                    );

                ref
                    .read(
                      partnerAvailabilityProvider.notifier,
                    )
                    .completeActiveWork(
                      service: PartnerServiceType.groceryDelivery,
                      workId: job.deliveryId,
                    );
              }

              ref
                  .read(
                    foodGroceryDeliverySessionProvider(
                      PartnerServiceType.groceryDelivery,
                    ).notifier,
                  )
                  .clearActiveJob();

              ref
                  .read(
                    foodGroceryDeliveryHomeProvider(
                      PartnerServiceType.groceryDelivery,
                    ).notifier,
                  )
                  .clearActiveDelivery();

              context.go(
                RouteNames.groceryDeliveryHome,
              );
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.foodDeliveryHistory,
        name: 'foodDeliveryHistory',
        builder: (context, state) {
          return DeliveryHistoryEarningsScreen(
            serviceType: PartnerServiceType.foodDelivery,
            initialTabIndex: 0,
            onBack: () {
              context.go(
                RouteNames.foodDeliveryHome,
              );
            },
            onNavigationSelected: (index) {
              switch (index) {
                case 0:
                  context.go(RouteNames.foodDeliveryHome);
                case 1:
                  context.go(RouteNames.foodDeliveryEarnings);
                case 2:
                  context.go(RouteNames.foodDeliveryHistory);
                case 3:
                  context.go(RouteNames.foodDeliveryAccount);
                default:
                  return;
              }
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.foodDeliveryEarnings,
        name: 'foodDeliveryEarnings',
        builder: (context, state) {
          return DeliveryHistoryEarningsScreen(
            serviceType: PartnerServiceType.foodDelivery,
            initialTabIndex: 1,
            onBack: () {
              context.go(
                RouteNames.foodDeliveryHome,
              );
            },
            onNavigationSelected: (index) {
              switch (index) {
                case 0:
                  context.go(RouteNames.foodDeliveryHome);
                case 1:
                  context.go(RouteNames.foodDeliveryEarnings);
                case 2:
                  context.go(RouteNames.foodDeliveryHistory);
                case 3:
                  context.go(RouteNames.foodDeliveryAccount);
                default:
                  return;
              }
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.groceryDeliveryHistory,
        name: 'groceryDeliveryHistory',
        builder: (context, state) {
          return DeliveryHistoryEarningsScreen(
            serviceType: PartnerServiceType.groceryDelivery,
            initialTabIndex: 0,
            onBack: () {
              context.go(
                RouteNames.groceryDeliveryHome,
              );
            },
            onNavigationSelected: (index) {
              switch (index) {
                case 0:
                  context.go(RouteNames.groceryDeliveryHome);
                case 1:
                  context.go(RouteNames.groceryDeliveryEarnings);
                case 2:
                  context.go(RouteNames.groceryDeliveryHistory);
                case 3:
                  context.go(RouteNames.groceryDeliveryAccount);
                default:
                  return;
              }
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.groceryDeliveryEarnings,
        name: 'groceryDeliveryEarnings',
        builder: (context, state) {
          return DeliveryHistoryEarningsScreen(
            serviceType: PartnerServiceType.groceryDelivery,
            initialTabIndex: 1,
            onBack: () {
              context.go(
                RouteNames.groceryDeliveryHome,
              );
            },
            onNavigationSelected: (index) {
              switch (index) {
                case 0:
                  context.go(RouteNames.groceryDeliveryHome);
                case 1:
                  context.go(RouteNames.groceryDeliveryEarnings);
                case 2:
                  context.go(RouteNames.groceryDeliveryHistory);
                case 3:
                  context.go(RouteNames.groceryDeliveryAccount);
                default:
                  return;
              }
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.foodDeliveryCashActivity,
        name: 'foodDeliveryCashActivity',
        builder: (context, state) {
          return DeliveryCashActivityScreen(
            serviceType: PartnerServiceType.foodDelivery,
            onBack: () {
              context.go(
                RouteNames.foodDeliveryHome,
              );
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.groceryDeliveryCashActivity,
        name: 'groceryDeliveryCashActivity',
        builder: (context, state) {
          return DeliveryCashActivityScreen(
            serviceType: PartnerServiceType.groceryDelivery,
            onBack: () {
              context.go(
                RouteNames.groceryDeliveryHome,
              );
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.foodDeliveryAccount,
        name: 'foodDeliveryAccount',
        builder: (context, state) {
          return FoodGroceryPartnerAccountScreen(
            serviceType: PartnerServiceType.foodDelivery,
            onBack: () {
              context.go(
                RouteNames.foodDeliveryHome,
              );
            },
            onDeliveries: () {
              context.go(
                RouteNames.foodDeliveryHistory,
              );
            },
            onEarnings: () {
              context.go(
                RouteNames.foodDeliveryEarnings,
              );
            },
            onNavigationSelected: (index) {
              switch (index) {
                case 0:
                  context.go(RouteNames.foodDeliveryHome);
                case 1:
                  context.go(RouteNames.foodDeliveryEarnings);
                case 2:
                  context.go(RouteNames.foodDeliveryHistory);
                case 3:
                  return;
                default:
                  return;
              }
            },
          );
        },
      ),

      GoRoute(
        path: RouteNames.groceryDeliveryAccount,
        name: 'groceryDeliveryAccount',
        builder: (context, state) {
          return FoodGroceryPartnerAccountScreen(
            serviceType: PartnerServiceType.groceryDelivery,
            onBack: () {
              context.go(
                RouteNames.groceryDeliveryHome,
              );
            },
            onDeliveries: () {
              context.go(
                RouteNames.groceryDeliveryHistory,
              );
            },
            onEarnings: () {
              context.go(
                RouteNames.groceryDeliveryEarnings,
              );
            },
            onNavigationSelected: (index) {
              switch (index) {
                case 0:
                  context.go(RouteNames.groceryDeliveryHome);
                case 1:
                  context.go(RouteNames.groceryDeliveryEarnings);
                case 2:
                  context.go(RouteNames.groceryDeliveryHistory);
                case 3:
                  return;
                default:
                  return;
              }
            },
          );
        },
      ),

//-------------------------------------------------------------------------

      GoRoute(
        path: RouteNames.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: RouteNames.registrationStatus,
        name: 'registrationStatus',
        builder: (context, state) {
          bool isFleet = false;
          String? phone;
          if (state.extra is Map<String, dynamic>) {
            final extra = state.extra as Map<String, dynamic>;
            isFleet = extra['isFleet'] as bool? ?? false;
            phone = extra['phone'] as String?;
          } else if (state.extra is bool) {
            isFleet = state.extra as bool;
          }
          return RegistrationStatusScreen(isFleet: isFleet, phone: phone);
        },
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPasswordOtp,
        name: 'forgotPasswordOtp',
        builder: (context, state) {
          final driverId = state.extra as String? ?? '';
          return ForgotPasswordOtpScreen(driverId: driverId);
        },
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        name: 'resetPassword',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ResetPasswordScreen(
            driverId: extra['driverId'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: RouteNames.resetSuccess,
        name: 'resetSuccess',
        builder: (context, state) => const ResetSuccessScreen(),
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        backgroundColor: AppColors.backgroundPrimary,
        body: Center(
          child: Text(
            'Route not found: ${state.uri.path}',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ),
      );
    },
  );
});
