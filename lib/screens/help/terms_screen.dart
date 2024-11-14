import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TermsScreen extends StatelessWidget {
  final String termsText = '''
Termos de Uso:

- O MindCare oferece suporte emocional, mas não substitui consultas com profissionais de saúde mental.
- O uso ético da Comunidade de Apoio é essencial. Discurso de ódio e assédio resultarão em suspensão.

Política de Privacidade:

- Em conformidade com a LGPD, protegemos seus dados com criptografia.
- Todos os dados coletados são utilizados para personalizar sua experiência no aplicativo.
- Você pode solicitar a exclusão de todos os seus dados a qualquer momento nas configurações.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Termos de Uso e Privacidade',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0.w),
        child: _buildTermsContent(context),
      ),
    );
  }

  Widget _buildTermsContent(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.onBackground,
            ),
        children: [
          TextSpan(
            text: 'Termos de Uso:\n\n',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          _buildBulletPoint(
            context,
            'O MindCare oferece suporte emocional, mas não substitui consultas com profissionais de saúde mental.',
          ),
          _buildBulletPoint(
            context,
            'O uso ético da Comunidade de Apoio é essencial. Discurso de ódio e assédio resultarão em suspensão.',
          ),
          TextSpan(
            text: '\nPolítica de Privacidade:\n\n',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          _buildBulletPoint(
            context,
            'Em conformidade com a LGPD, protegemos seus dados com criptografia.',
          ),
          _buildBulletPoint(
            context,
            'Todos os dados coletados são utilizados para personalizar sua experiência no aplicativo.',
          ),
          _buildBulletPoint(
            context,
            'Você pode solicitar a exclusão de todos os seus dados a qualquer momento nas configurações.',
          ),
        ],
      ),
    );
  }

  TextSpan _buildBulletPoint(BuildContext context, String text) {
    return TextSpan(
      text: '• $text\n\n',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 16.sp,
            height: 1.5,
            color: Theme.of(context).colorScheme.onBackground,
          ),
    );
  }
}
