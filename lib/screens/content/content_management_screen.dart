import 'package:flutter/material.dart';
import 'package:mindcare_app/services/api_service.dart';
import 'package:mindcare_app/screens/functions/article_preview_screen.dart';
import 'package:mindcare_app/screens/functions/video_preview_screen.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContentManagementScreen extends StatefulWidget {
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
          content: Text(
              'Acesso negado. Você não tem permissão para acessar esta tela.')),
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
      // Modifique as requisições para incluir paginação
      final videosResponse = await apiService.getPendingVideos(
          page: currentPage, limit: itemsPerPage);
      final articlesResponse = await apiService.getPendingArticles(
          page: currentPage, limit: itemsPerPage);

      setState(() {
        if (currentPage == 1) {
          // Primeira página: substitui as listas
          pendingVideos = _parseResponse(videosResponse);
          pendingArticles = _parseResponse(articlesResponse);
        } else {
          // Páginas adicionais: adiciona novos itens
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

// Função para carregar a próxima página
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
      SnackBar(content: Text(message)),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: 'Vídeos Pendentes'),
                      Tab(text: 'Artigos Pendentes'),
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
      title: Text('Gerenciamento de Conteúdo'),
      actions: isAdmin
          ? [
              IconButton(
                icon: Icon(Icons.settings),
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
        ? Center(child: Text('Nenhum vídeo pendente.'))
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
                color: Colors.grey,
                child: Icon(Icons.image, color: Colors.white),
              ),
        title: Text(title, style: TextStyle(fontSize: 16.sp)),
        subtitle: Text('Autor: $channelTitle', style: TextStyle(fontSize: 14.sp)),
        trailing: _buildActionButtons(video, true),
        onTap: () => _viewVideo(video),
      ),
    );
  }

  Widget _buildPendingArticles() {
    return pendingArticles.isEmpty
        ? Center(child: Text('Nenhum artigo pendente.'))
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
                color: Colors.grey,
                child: Icon(Icons.article, color: Colors.white),
              ),
        title: Text(title, style: TextStyle(fontSize: 16.sp)),
        subtitle: Text('Autor: $author', style: TextStyle(fontSize: 14.sp)),
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
          icon: Icon(Icons.check, color: Colors.green),
          tooltip: 'Aprovar',
          onPressed: () => _approveContent(item['_id'], isVideo),
        ),
        IconButton(
          icon: Icon(Icons.close, color: Colors.red),
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
              .timeout(Duration(seconds: 10));

          if (response.statusCode == 200) {
            _showSuccess('Vídeo aprovado com sucesso.');
          } else {
            throw Exception('Falha ao aprovar o vídeo.');
          }
        }
      } else {
        final response = await apiService
            .approveArticle(contentId)
            .timeout(Duration(seconds: 10));

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
              .timeout(Duration(seconds: 10))
          : await apiService
              .rejectArticle(contentId)
              .timeout(Duration(seconds: 10));

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
          title: Text('Selecione a Categoria'),
          content: DropdownButtonFormField<String>(
            items: ['Meditação', 'Relaxamento', 'Saúde']
                .map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ))
                .toList(),
            onChanged: (value) {
              tempCategory = value;
            },
            decoration: InputDecoration(
              labelText: 'Categoria',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                selectedCategory = null;
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                selectedCategory = tempCategory;
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
    return selectedCategory;
  }
}
