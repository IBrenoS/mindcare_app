import 'package:flutter/material.dart';

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
            title: Text(faqItems[index]['question']!),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(faqItems[index]['answer']!),
              ),
            ],
          );
        },
      ),
    );
  }
}
