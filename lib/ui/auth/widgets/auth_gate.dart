import 'package:flutter/material.dart';
import 'package:gerenciador_de_projetos/data/services/updater_service.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_viewmodel.dart';
import '../../app/widgets/app.dart';
import 'login_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () => checkForUpdates(context));
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    switch (authViewModel.authState) {
      case AuthState.authenticated:
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
