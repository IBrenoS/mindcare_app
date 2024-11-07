import 'package:flutter/material.dart';
import 'package:mindcare_app/services/api_service.dart';
import 'package:mindcare_app/screens/functions/article_preview_screen.dart';
import 'package:mindcare_app/screens/functions/video_preview_screen.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mindcare_app/theme/theme.dart';

class ContentManagementScreen extends StatefulWidget {
  const ContentManagementScreen({Key? key}) : super(key: key);

  @override
  _ContentManagementScreenState createState() =>
      _ContentManagementScreenState();
}

class _ContentManagementScreenState extends State<ContentManagementScreen> {
  final ApiService apiService = ApiService();
  bool isAdmin = false;
  bool isModerator = false;
  List<dynamic> pendingVideos = [];
  List<dynamic> pendingArticles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _checkUserRole();
    await _loadContent();
  }

  Future<void> _checkUserRole() async {
    try {
      final userProfile = await apiService.fetchUserProfile();
      final userRole = userProfile['role']
          .toString()
          .toUpperCase(); // Converte para maiúsculas
      setState(() {
        isAdmin = userRole == 'ADMIN';
        isModerator = userRole == 'MODERATOR';
      });

      if (!isAdmin && !isModerator) {
        _showAccessDenied();
      }
    } catch (e) {
      _showAccessDenied();
    }
  }

  void _showAccessDenied() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        content: Text(
          'Acesso negado. Você não tem permissão para acessar esta tela.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onError,
              ),
        ),
      ),
    );
    Navigator.pop(context);
  }

  int currentPage = 1;
  int itemsPerPage = 100;

  Future<void> _loadContent() async {
    setState(() {
      isLoading = true;
    });
    try {
      final videosResponse = await apiService.getPendingVideos(
          page: currentPage, limit: itemsPerPage);
      final articlesResponse = await apiService.getPendingArticles(
          page: currentPage, limit: itemsPerPage);

      setState(() {
        if (currentPage == 1) {
          pendingVideos = _parseResponse(videosResponse);
          pendingArticles = _parseResponse(articlesResponse);
        } else {
          pendingVideos.addAll(_parseResponse(videosResponse));
          pendingArticles.addAll(_parseResponse(articlesResponse));
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Erro ao carregar conteúdos pendentes.');
    }
  }

  void _loadNextPage() {
    setState(() {
      currentPage++;
    });
    _loadContent();
  }

  List<dynamic> _parseResponse(dynamic response) {
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      return [];
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: errorColorLight,
              ),
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: successColorLight,
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: msg,
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: Theme.of(context).colorScheme.primary,
                    unselectedLabelColor:
                        Theme.of(context).colorScheme.onSurface,
                    indicatorColor: Theme.of(context).colorScheme.primary,
                    tabs: [
                      Tab(
                        child: Text(
                          'Vídeos Pendentes',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      Tab(
                        child: Text(
                          'Artigos Pendentes',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildPendingVideos(),
                        _buildPendingArticles(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'Gerenciamento de Conteúdo',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      iconTheme: IconThemeData(
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      actions: isAdmin
          ? [
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () {
                  // Navegar para outras funções administrativas
                },
              )
            ]
          : [],
    );
  }

  Widget _buildPendingVideos() {
    return pendingVideos.isEmpty
        ? Center(
            child: Text(
              'Nenhum vídeo pendente.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          )
        : ListView.builder(
            itemCount: pendingVideos.length,
            itemBuilder: (context, index) {
              final video = pendingVideos[index];
              return _buildVideoCard(video);
            },
          );
  }

  Widget _buildVideoCard(dynamic video) {
    final thumbnailUrl = video['thumbnail'] ?? '';
    final title = video['title'] ?? 'Sem título';
    final channelTitle = video['channelName'] ?? 'Autor desconhecido';

    return Card(
      margin: EdgeInsets.all(8.w),
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        leading: thumbnailUrl.isNotEmpty
            ? Image.network(
                thumbnailUrl,
                width: 100.w,
                height: 56.h,
                fit: BoxFit.cover,
              )
            : Container(
                width: 100.w,
                height: 56.h,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                child: Icon(
                  Icons.image,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        subtitle: Text(
          'Autor: $channelTitle',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: _buildActionButtons(video, true),
        onTap: () => _viewVideo(video),
      ),
    );
  }

  Widget _buildPendingArticles() {
    return pendingArticles.isEmpty
        ? Center(
            child: Text(
              'Nenhum artigo pendente.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          )
        : ListView.builder(
            itemCount: pendingArticles.length,
            itemBuilder: (context, index) {
              final article = pendingArticles[index];
              return _buildArticleCard(article);
            },
          );
  }

  Widget _buildArticleCard(dynamic article) {
    final title = article['title'] ?? 'Sem título';
    final author = article['author'] ?? 'Autor desconhecido';
    final thumbnailUrl = article['urlToImage'] ?? '';

    return Card(
      margin: EdgeInsets.all(8.w),
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        leading: thumbnailUrl.isNotEmpty
            ? Image.network(
                thumbnailUrl,
                width: 100.w,
                height: 56.h,
                fit: BoxFit.cover,
              )
            : Container(
                width: 100.w,
                height: 56.h,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                child: Icon(
                  Icons.article,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        subtitle: Text(
          'Autor: $author',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        trailing: _buildActionButtons(article, false),
        onTap: () => _viewArticle(article),
      ),
    );
  }

  Widget _buildActionButtons(dynamic item, bool isVideo) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.check,
            color: Theme.of(context).colorScheme.primary,
          ),
          tooltip: 'Aprovar',
          onPressed: () => _approveContent(item['_id'], isVideo),
        ),
        IconButton(
          icon: Icon(
            Icons.close,
            color: Theme.of(context).colorScheme.error,
          ),
          tooltip: 'Rejeitar',
          onPressed: () => _rejectContent(item['_id'], isVideo),
        ),
      ],
    );
  }

  void _viewVideo(dynamic video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPreviewScreen(video: video),
      ),
    );
  }

  void _viewArticle(dynamic article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticlePreviewScreen(article: article),
      ),
    );
  }

  Future<void> _approveContent(String contentId, bool isVideo) async {
    setState(() {
      isLoading = true;
    });
    try {
      if (isVideo) {
        String? category = await _selectCategory();
        if (category != null) {
          final response = await apiService
              .approveVideo(contentId, category)
              .timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            _showSuccess('Vídeo aprovado com sucesso.');
          } else {
            throw Exception('Falha ao aprovar o vídeo.');
          }
        }
      } else {
        final response = await apiService
            .approveArticle(contentId)
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          _showSuccess('Artigo aprovado com sucesso.');
        } else {
          throw Exception('Falha ao aprovar o artigo.');
        }
      }
      await _loadContent();
    } catch (e) {
      _showError('Erro ao aprovar conteúdo: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _rejectContent(String contentId, bool isVideo) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = isVideo
          ? await apiService
              .rejectVideo(contentId)
              .timeout(const Duration(seconds: 10))
          : await apiService
              .rejectArticle(contentId)
              .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        _showSuccess(isVideo
            ? 'Vídeo rejeitado com sucesso.'
            : 'Artigo rejeitado com sucesso.');
        await _loadContent();
      } else {
        throw Exception('Falha ao rejeitar conteúdo.');
      }
    } catch (e) {
      _showError('Erro ao rejeitar conteúdo: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String?> _selectCategory() async {
    String? selectedCategory;
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String? tempCategory;
        return AlertDialog(
          title: Text(
            'Selecione a Categoria',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: DropdownButtonFormField<String>(
            items: ['Meditação', 'Relaxamento', 'Saúde']
                .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(
                        category,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              tempCategory = value;
            },
            decoration: InputDecoration(
              labelText: 'Categoria',
              labelStyle: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                selectedCategory = null;
              },
              child: Text(
                'Cancelar',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                selectedCategory = tempCategory;
              },
              child: Text(
                'Confirmar',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        );
      },
    );
    return selectedCategory;
  }
}
