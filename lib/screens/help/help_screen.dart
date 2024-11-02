import 'package:flutter/material.dart';
import 'package:mindcare_app/screens/help/FAQ_screen.dart';
import 'package:mindcare_app/screens/help/support_screen.dart';
import 'package:mindcare_app/screens/help/terms_screen.dart';
import 'package:mindcare_app/screens/help/usageGuide_screen.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajuda e Suporte'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.question_answer),
            title: const Text('Perguntas Frequentes (FAQ)'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FAQScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_support),
            title: const Text('Suporte e Contato'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SupportScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Guia de Uso do App'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UsageGuideScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Termos de Uso e Privacidade'),
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
