import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  final String termsText = '''
    Termos de Uso:
    - Este aplicativo não substitui consultas com profissionais de saúde mental.
    - O usuário é responsável pelo uso adequado das funcionalidades.

    Política de Privacidade:
    - Todos os dados são protegidos e seguem as normas da LGPD e GDPR.
    - O app coleta informações apenas para personalização da experiência.
    ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Termos de Uso e Privacidade'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          termsText,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

