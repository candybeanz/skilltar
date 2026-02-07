import 'package:flutter/material.dart';

import 'screens/role_selection_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_nav_shell.dart';
import 'screens/workshop_details_screen.dart';
import 'screens/verify_account_screen.dart';
import 'screens/new_workshop_listing_screen.dart';
import 'models/workshop.dart';

class Routes {
  static const roleSelection = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const shell = '/shell';
  static const workshopDetails = '/workshop-details';
  static const hostVerifyPlaceholder = '/host-verify';
  static const newWorkshopListing = '/new-workshop-listing';
}

class LoginArgs {
  final UserRole role;
  const LoginArgs(this.role);
}

class SignupArgs {
  final UserRole role;
  const SignupArgs(this.role);
}

class WorkshopDetailsArgs {
  final Workshop workshop;
  const WorkshopDetailsArgs(this.workshop);
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.roleSelection:
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());

      case Routes.login: {
        final args = settings.arguments as LoginArgs?;
        return MaterialPageRoute(
          builder: (_) => LoginScreen(role: args?.role ?? UserRole.client),
        );
      }

      case Routes.signup: {
        final args = settings.arguments as SignupArgs?;
        return MaterialPageRoute(
          builder: (_) => SignupScreen(role: args?.role ?? UserRole.client),
        );
      }

      case Routes.shell:
        return MaterialPageRoute(builder: (_) => const MainNavShell());

      case Routes.workshopDetails: {
        final args = settings.arguments as WorkshopDetailsArgs;
        return MaterialPageRoute(
          builder: (_) => WorkshopDetailsScreen(workshopId: args.workshop.id),
        );
      }

      case Routes.hostVerifyPlaceholder:
        return MaterialPageRoute(builder: (_) => const VerifyAccountScreen());

      case Routes.newWorkshopListing:
        return MaterialPageRoute(builder: (_) => const NewWorkshopListingScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: SafeArea(child: Center(child: Text('Route not found'))),
          ),
        );
    }
  }
}
