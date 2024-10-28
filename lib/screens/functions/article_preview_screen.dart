import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticlePreviewScreen extends StatefulWidget {
  final dynamic article;

  ArticlePreviewScreen({required this.article});

  @override
  _ArticlePreviewScreenState createState() => _ArticlePreviewScreenState();
}

class _ArticlePreviewScreenState extends State<ArticlePreviewScreen> {
  bool _isExpanded = false;

  void _toggleReadMore() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Não foi possível abrir o link do artigo.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.article['title'] ?? 'Título não disponível';
    final author = widget.article['author'] ?? 'Autor desconhecido';
    final content = widget.article['content'] ?? 'Conteúdo indisponível';
    final imageUrl = widget.article['urlToImage'] ?? '';
    final articleUrl = widget.article['url'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do artigo
            if (imageUrl.isNotEmpty)
              Container(
                margin: EdgeInsets.only(bottom: 16.0),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      height: 200,
                      child: Center(
                        child: Icon(Icons.broken_image,
                            size: 50, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
            // Título do artigo
            Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            // Autor do artigo
            Text(
              'Autor: $author',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 16.0),
            // Conteúdo do artigo com opção de expandir
            Text(
              _isExpanded ? content : '${content.substring(0, 200)}...',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            SizedBox(height: 8.0),
            // Botão de "Leia Mais" para expandir o conteúdo completo
            TextButton(
              onPressed: _toggleReadMore,
              child: Text(_isExpanded ? "Mostrar menos" : "Leia mais"),
            ),
            SizedBox(height: 16.0),
            // Botão para abrir o artigo na web, se a URL estiver disponível
            if (articleUrl.isNotEmpty)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _launchURL(articleUrl),
                  icon: Icon(Icons.open_in_browser),
                  label: Text("Abrir Artigo Original"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
