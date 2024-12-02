import 'package:flutter/material.dart';
import 'package:mindcare_app/services/api_service.dart';
import 'dart:convert';
import 'package:mindcare_app/screens/content/articleDetail_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mindcare_app/utils/text_scale_helper.dart';

class EducationalContentScreen extends StatefulWidget {
  const EducationalContentScreen({Key? key}) : super(key: key);

  @override
  _EducationalContentScreenState createState() =>
      _EducationalContentScreenState();
}

class _EducationalContentScreenState extends State<EducationalContentScreen> {
  List<Map<String, dynamic>> articles = [];
  bool isLoading = true;
  int currentPage = 1;
  final int articlesPerPage = 20;
  bool hasMoreArticles = true;

  @override
  void initState() {
    super.initState();
    _loadApprovedArticles();
  }

  Future<void> _loadApprovedArticles() async {
    if (!hasMoreArticles) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService().getApprovedArticles(
        page: currentPage,
        limit: articlesPerPage,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<Map<String, dynamic>> fetchedArticles =
            List<Map<String, dynamic>>.from(responseData['data']);

        setState(() {
          articles.addAll(fetchedArticles);
          isLoading = false;
          currentPage++;
          hasMoreArticles = fetchedArticles.length == articlesPerPage;
        });
      } else {
        throw Exception(
            "Erro ao carregar artigos. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erro ao carregar artigos.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onError,
                ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ScaledText(
          "Conteúdo Educativo",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: isLoading && articles.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          : articles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaledText(
                        "Erro ao carregar artigos ou nenhum artigo disponível.",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      SizedBox(height: 10.h),
                      ElevatedButton(
                        onPressed: _loadApprovedArticles,
                        child: ScaledText(
                          "Tentar novamente",
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (!isLoading &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                      _loadApprovedArticles();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    itemCount: articles.length + (hasMoreArticles ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == articles.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        );
                      }

                      final article = articles[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        margin: EdgeInsets.symmetric(
                            vertical: 10.h, horizontal: 15.w),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(10.w),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.network(
                              article['urlToImage'] ?? '',
                              width: 60.w,
                              height: 60.h,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: ScaledText(
                            article['title'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5.h),
                              ScaledText(
                                article['summary'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              SizedBox(height: 5.h),
                              ScaledText(
                                "Por ${article['author'] ?? 'Desconhecido'} - ${article['source'] ?? ''}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onBackground,
                                    ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ArticleDetailScreen(article: article),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
