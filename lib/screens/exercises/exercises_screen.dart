import 'package:flutter/material.dart';

class ExercisesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercícios de Relaxamento'),
        backgroundColor: Colors.lightBlue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Escolha um exercício:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: exercises.length, // Lista fictícia de exercícios
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: Icon(Icons.self_improvement,
                          size: 40, color: Colors.blueAccent),
                      title: Text(exercise['title']!),
                      subtitle: Text(exercise['description']!),
                      trailing:
                          Icon(Icons.play_arrow, color: Colors.blueAccent),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ExerciseDetailScreen(exercise: exercise)),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Exemplo de lista fictícia de exercícios
  final List<Map<String, String>> exercises = [
    {
      'title': 'Meditação Guiada - Respiração Profunda',
      'description': 'Encontre calma com esta meditação guiada...',
    },
    {
      'title': 'Exercício de Relaxamento - Mente Sã',
      'description': 'Uma prática de relaxamento mental e físico...',
    },
    {
      'title': 'Meditação para Dormir Melhor',
      'description': 'Uma sessão para ajudar você a ter uma noite tranquila...',
    },
  ];
}

// Tela de detalhe do exercício
class ExerciseDetailScreen extends StatelessWidget {
  final Map<String, String> exercise;

  const ExerciseDetailScreen({Key? key, required this.exercise})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(exercise['title']!),
        backgroundColor: Colors.lightBlue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise['title']!,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              exercise['description']!,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            // SINAL DE ATENÇÃO: Aqui integramos o player de vídeo com YouTube ou outra API
            Container(
              height: 250,
              color: Colors.grey[300],
              child: Center(
                child: Text('Aqui vai o vídeo do exercício...'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
