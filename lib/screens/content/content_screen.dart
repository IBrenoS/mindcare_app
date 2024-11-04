import 'package:flutter/material.dart';
import 'package:mindcare_app/services/api_service.dart';
import 'dart:convert';
import 'package:mindcare_app/screens/content/articleDetail_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EducationalContentScreen extends StatefulWidget {
  @override
  _EducationalContentScreenState createState() =>
      _EducationalContentScreenState();
}

class _EducationalContentScreenState extends State<EducationalContentScreen> {
  List<Map<String, dynamic>> articles = [];
  bool isLoading = true;
  int currentPage = 1;
  final int articlesPerPage = 20;
  bool hasMoreArticles = true; // Controle de artigos restantes para carregar

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
      print("Erro: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Conteúdo Educativo",
          style: TextStyle(fontSize: 20.sp), // Adjust font size responsively
        ),
      ),
      body: isLoading && articles.isEmpty
          ? Center(child: CircularProgressIndicator())
          : articles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Erro ao carregar artigos ou nenhum artigo disponível.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16.sp),
                      ),
                      SizedBox(height: 10.h),
                      ElevatedButton(
                        onPressed: _loadApprovedArticles,
                        child: Text(
                          "Tentar novamente",
                          style: TextStyle(fontSize: 14.sp),
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
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final article = articles[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
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
                          title: Text(
                            article['title'] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 5.h),
                              Text(
                                article['summary'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              SizedBox(height: 5.h),
                              Text(
                                "Por ${article['author'] ?? 'Desconhecido'} - ${article['source'] ?? ''}",
                                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
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
