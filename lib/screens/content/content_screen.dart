import 'package:flutter/material.dart';

class ContentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conteúdo Educativo'),
        backgroundColor: Colors.lightBlue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aprenda mais sobre Saúde Mental:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: educationalContent
                    .length, // Lista fictícia de conteúdos educativos
                itemBuilder: (context, index) {
                  final content = educationalContent[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      leading: Icon(Icons.article,
                          size: 40, color: Colors.blueAccent),
                      title: Text(content['title']!),
                      subtitle: Text(content['description']!),
                      trailing:
                          Icon(Icons.arrow_forward, color: Colors.blueAccent),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EducationalDetailScreen(content: content)),
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

  // Lista fictícia de artigos ou vídeos educativos
  final List<Map<String, String>> educationalContent = [
    {
      'title': 'Como cuidar da sua saúde mental',
      'description': 'Dicas e estratégias para manter sua mente saudável.',
      'type': 'article',
    },
    {
      'title': 'Meditação para reduzir o estresse',
      'description':
          'Vídeo sobre práticas de meditação para aliviar o estresse.',
      'type': 'video',
    },
    {
      'title': 'Entendendo a ansiedade',
      'description': 'Artigo explicando as causas e sintomas da ansiedade.',
      'type': 'article',
    },
  ];
}

// Tela de detalhe do conteúdo educativo
class EducationalDetailScreen extends StatelessWidget {
  final Map<String, String> content;

  const EducationalDetailScreen({Key? key, required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(content['title']!),
        backgroundColor: Colors.lightBlue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              content['title']!,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            if (content['type'] == 'article') ...[
              Text(
                'Aqui vai o conteúdo completo do artigo...',
                style: TextStyle(fontSize: 16),
              ),
            ] else ...[
              Container(
                height: 250,
                color: Colors.grey[300],
                child: Center(
                  child: Text('Aqui vai o vídeo educativo...'),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Descrição do vídeo: ${content['description']}',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
