import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mindcare_app/utils/text_scale_helper.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Map<String, dynamic> article;

  const ArticleDetailScreen({Key? key, required this.article})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ScaledText(
          article['title'] ?? "Artigo",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.bookmark_border,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () {
              // Lógica para favoritar o artigo
            },
          ),
          IconButton(
            icon: Icon(
              Icons.share,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () {
              // Compartilha o link do artigo
              Share.share(article['url'] ?? '');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article['urlToImage'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  article['urlToImage'] ?? '',
                  width: double.infinity,
                  height: 200.h,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 10.h),
            ScaledText(
              article['title'] ?? '',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 10.h),
            ScaledText(
              "Por ${article['author'] ?? 'Autor desconhecido'} - ${article['source'] ?? 'Fonte desconhecida'}",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
            SizedBox(height: 20.h),
            ScaledText(
              article['content'] ??
                  "Este é um resumo. Para ler o artigo completo, acesse o link abaixo.",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              icon: Icon(
                Icons.link,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              label: ScaledText(
                "Leia o artigo completo",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () async {
                final url = article['url'];
                if (url != null && await canLaunch(url)) {
                  await launch(url);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: ScaledText(
                        "Não foi possível abrir o link.",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onError,
                            ),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
