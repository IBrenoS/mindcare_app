import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Map<String, dynamic> article;

  ArticleDetailScreen({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          article['title'] ?? "Artigo",
          style: TextStyle(fontSize: 20.sp),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark_border),
            onPressed: () {
              // Lógica para favoritar o artigo
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
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
            Text(
              article['title'] ?? '',
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            Text(
              "Por ${article['author'] ?? 'Autor desconhecido'} - ${article['source'] ?? 'Fonte desconhecida'}",
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
            SizedBox(height: 20.h),
            Text(
              article['content'] ??
                  "Este é um resumo. Para ler o artigo completo, acesse o link abaixo.",
              style: TextStyle(fontSize: 16.sp, height: 1.5),
            ),
            SizedBox(height: 20.h),
            // Link para o artigo completo
            ElevatedButton.icon(
              icon: Icon(Icons.link),
              label: Text(
                "Leia o artigo completo",
                style: TextStyle(fontSize: 14.sp),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final url = article['url'];
                if (url != null && await canLaunch(url)) {
                  await launch(url);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Não foi possível abrir o link.")),
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
