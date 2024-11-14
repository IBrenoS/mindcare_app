import 'package:flutter/material.dart';
import 'package:mindcare_app/screens/help/FAQ_screen.dart';
import 'package:mindcare_app/screens/help/support_screen.dart';
import 'package:mindcare_app/screens/help/terms_screen.dart';
import 'package:mindcare_app/screens/help/usageGuide_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Suporte ao Usuário',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(
              Icons.question_answer,
              size: 24.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              'Perguntas Frequentes (FAQ)',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FAQScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.contact_support,
              size: 24.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              'Suporte e Contato',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SupportScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.book,
              size: 24.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              'Guia de Uso do App',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UsageGuideScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.privacy_tip,
              size: 24.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              'Termos de Uso e Privacidade',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TermsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
