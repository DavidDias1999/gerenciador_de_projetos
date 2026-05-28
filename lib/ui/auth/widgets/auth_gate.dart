import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_viewmodel.dart';
import '../../app/widgets/app.dart';
import 'login_screen.dart';
import 'complete_profile_screen.dart';
import 'pending_authorization_screen.dart';
import 'deactivated_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().checkSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    switch (authViewModel.authState) {
      case AuthState.authenticated:
        final user = authViewModel.currentUser;
        if (user == null) {
           return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        if (!user.isActive) {
          return const DeactivatedScreen();
        }

        if (!authViewModel.isAuthorized && !authViewModel.isAdmin) {
          return const PendingAuthorizationScreen();
        }

        if (user.name == null || user.name!.trim().isEmpty) {
          return const CompleteProfileScreen();
        }

        return const AppGDP();
      case AuthState.unauthenticated:
        return const LoginScreen();
      case AuthState.unknown:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
    }
  }
}
