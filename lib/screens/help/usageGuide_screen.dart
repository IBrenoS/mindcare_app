import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil

class UsageGuideScreen extends StatelessWidget {
  final List<String> guideSteps = [
    'Acesse a tela inicial para ver as principais opções.',
    'Use o Diário de Humor para registrar como você se sente diariamente.',
    'Acesse a Comunidade de Apoio para compartilhar experiências.',
    // Adicione mais instruções
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guia de Uso do App'),
      ),
      body: ListView.builder(
        itemCount: guideSteps.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(
              Icons.check_circle_outline,
              size: 24.sp, // Adjust icon size
            ),
            title: Text(
              guideSteps[index],
              style: TextStyle(fontSize: 16.sp), // Adjust text size
            ),
          );
        },
      ),
    );
  }
}
