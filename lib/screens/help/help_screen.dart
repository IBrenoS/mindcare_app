import 'package:flutter/material.dart';
import 'package:mindcare_app/screens/help/FAQ_screen.dart';
import 'package:mindcare_app/screens/help/support_screen.dart';
import 'package:mindcare_app/screens/help/terms_screen.dart';
import 'package:mindcare_app/screens/help/usageGuide_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil

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
            leading: Icon(
              Icons.question_answer,
              size: 24.sp, // Adjust icon size
            ),
            title: Text(
              'Perguntas Frequentes (FAQ)',
              style: TextStyle(fontSize: 16.sp), // Adjust text size
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
              size: 24.sp, // Adjust icon size
            ),
            title: Text(
              'Suporte e Contato',
              style: TextStyle(fontSize: 16.sp), // Adjust text size
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
              size: 24.sp, // Adjust icon size
            ),
            title: Text(
              'Guia de Uso do App',
              style: TextStyle(fontSize: 16.sp), // Adjust text size
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
              size: 24.sp, // Adjust icon size
            ),
            title: Text(
              'Termos de Uso e Privacidade',
              style: TextStyle(fontSize: 16.sp), // Adjust text size
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
