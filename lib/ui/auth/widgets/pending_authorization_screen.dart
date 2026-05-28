import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/auth_viewmodel.dart';
import '../../projects/view_models/project_viewmodel.dart';

class PendingAuthorizationScreen extends StatefulWidget {
  const PendingAuthorizationScreen({super.key});

  @override
  State<PendingAuthorizationScreen> createState() => _PendingAuthorizationScreenState();
}

class _PendingAuthorizationScreenState extends State<PendingAuthorizationScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    
    // Desloga automaticamente após 5 segundos
    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        context.read<ProjectViewModel>().clear();
        context.read<AuthViewModel>().logout();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aguardando Aprovação'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _timer?.cancel();
              context.read<ProjectViewModel>().clear();
              context.read<AuthViewModel>().logout();
            },
          )
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: const Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.hourglass_empty_rounded,
                  size: 64,
                  color: Colors.orange,
                ),
                SizedBox(height: 24),
                Text(
                  'Cadastro em Análise',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Sua conta foi criada com sucesso, mas o seu acesso precisa ser liberado por um administrador.\n\nVocê será redirecionado para a tela de login em alguns segundos.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
