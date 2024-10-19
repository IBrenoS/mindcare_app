import 'package:flutter/material.dart';

class ArticlePreviewScreen extends StatelessWidget {
  final dynamic article;

  ArticlePreviewScreen({required this.article});

  @override
  Widget build(BuildContext context) {
    final content = article['content'] ?? 'Sem conteúdo disponível.';
    return Scaffold(
      appBar: AppBar(
        title: Text(article['title'] ?? 'Sem título'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          content,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

