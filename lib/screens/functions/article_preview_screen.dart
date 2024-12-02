import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mindcare_app/utils/text_scale_helper.dart';

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
        SnackBar(
          content: ScaledText(
            "Não foi possível abrir o link do artigo.",
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Theme.of(context).colorScheme.onError),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
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
        title: ScaledText(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do artigo
            if (imageUrl.isNotEmpty)
              Container(
                margin: EdgeInsets.only(bottom: 16.0.h),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200.h,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Theme.of(context).colorScheme.surface,
                      height: 200.h,
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ),
            // Título do artigo
            ScaledText(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
            SizedBox(height: 8.0.h),
            // Autor do artigo
            ScaledText(
              'Autor: $author',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            SizedBox(height: 16.0.h),
            // Conteúdo do artigo com opção de expandir
            ScaledText(
              _isExpanded ? content : '${content.substring(0, 200)}...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
            SizedBox(height: 8.0.h),
            // Botão de "Leia Mais" para expandir o conteúdo completo
            TextButton(
              onPressed: _toggleReadMore,
              child: ScaledText(
                _isExpanded ? "Mostrar menos" : "Leia mais",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            SizedBox(height: 16.0.h),
            // Botão para abrir o artigo na web, se a URL estiver disponível
            if (articleUrl.isNotEmpty)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _launchURL(articleUrl),
                  icon: Icon(Icons.open_in_browser),
                  label: ScaledText(
                    "Abrir Artigo Original",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
