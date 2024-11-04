import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil

class FAQScreen extends StatelessWidget {
  final List<Map<String, String>> faqItems = [
    {
      'question': 'Como faço o cadastro no MindCare?',
      'answer':
          'Para se cadastrar, acesse a tela de cadastro e insira suas informações pessoais.'
    },
    {
      'question': 'Como redefino minha senha?',
      'answer':
          'Acesse a opção "Esqueci minha senha" na tela de login e siga as instruções.'
    },
    // Adicione mais perguntas e respostas aqui
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perguntas Frequentes (FAQ)'),
      ),
      body: ListView.builder(
        itemCount: faqItems.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(
              faqItems[index]['question']!,
              style: TextStyle(fontSize: 16.sp), // Adjust text size
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0.r), // Adjust padding
                child: Text(
                  faqItems[index]['answer']!,
                  style: TextStyle(fontSize: 14.sp), // Adjust text size
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
