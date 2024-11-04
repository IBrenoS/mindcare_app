import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mindcare_app/services/api_service.dart';
import 'package:mindcare_app/utils/time_formatter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CommunityScreen extends StatefulWidget {
  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> posts = [];
  bool isLoading = true;
  bool isLoadingMore = false; // Flag para controlar carregamento adicional
  int currentPage = 1; // Página atual de postagens
  final int postsPerPage = 10; // Número de postagens por página
  final ScrollController _scrollController = ScrollController();
  TextEditingController _commentController = TextEditingController();
  TextEditingController _captionController =
      TextEditingController(); // Controlador para legenda da postagem
  String userProfileImageUrl = 'https://via.placeholder.com/50';
  File? _selectedImage; // Armazena a imagem selecionada

  @override
  void initState() {
    super.initState();
    fetchPosts(); // Carrega a primeira página de postagens
    fetchUserProfile();

    // Adiciona listener ao ScrollController para detectar quando chegar no final da lista
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isLoadingMore) {
        fetchMorePosts(); // Carrega mais postagens quando chega ao final
      }
    });
  }

  Future<void> fetchUserProfile() async {
    try {
      final user = await apiService.fetchUserProfile();
      setState(() {
        userProfileImageUrl =
            user['photoUrl'] ?? 'https://via.placeholder.com/50';
      });
    } catch (e) {
      print('Erro ao buscar perfil do usuário: $e');
    }
  }

   Future<void> fetchPosts() async {
    try {
      setState(() {
        isLoading = true;
      });
      final fetchedPosts =
          await apiService.fetchPosts(currentPage, postsPerPage);
      setState(() {
        posts =
            fetchedPosts; // Inicializa a lista com a primeira página de postagens
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar postagens')),
      );
    }
  }

   // Função para carregar mais postagens ao rolar até o fim da lista
  Future<void> fetchMorePosts() async {
    try {
      setState(() {
        isLoadingMore = true; // Ativa a flag de carregamento adicional
      });
      currentPage++; // Incrementa o número da página
      final fetchedPosts =
          await apiService.fetchPosts(currentPage, postsPerPage);
      if (fetchedPosts.isNotEmpty) {
        setState(() {
          posts.addAll(
              fetchedPosts); // Adiciona mais postagens à lista existente
        });
      }
      setState(() {
        isLoadingMore = false; // Desativa a flag de carregamento adicional
      });
    } catch (e) {
      setState(() {
        isLoadingMore =
            false; // Garante que a flag seja desativada em caso de erro
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar mais postagens')),
      );
    }
  }

   Future<void> toggleLikePost(String postId, bool isLiked) async {
    try {
      await apiService.likePost(postId);
      setState(() {
        posts = posts.map((post) {
          if (post['_id'] == postId) {
            if (isLiked) {
              post['likes'].remove(apiService.currentUserId);
            } else {
              post['likes'].add(apiService.currentUserId);
            }
            post['isLikedByCurrentUser'] = !isLiked;
          }
          return post;
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar curtida')),
      );
    }
  }

  Future<void> _addComment(String postId) async {
    if (_commentController.text.isEmpty) return;
    try {
      await apiService.addComment(postId, _commentController.text);
      _commentController.clear();
      fetchPosts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao adicionar comentário')),
      );
    }
    FocusScope.of(context).unfocus();
  }

  void _showCommentsModal(BuildContext context, List comments, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(top: 8, bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                                comment["userId"] is Map
                                    ? comment["userId"]["photoUrl"] ?? ""
                                    : ""),
                          ),
                          title: Text(
                            comment["userId"] is Map
                                ? comment["userId"]["name"] ?? "Usuário"
                                : "Usuário Desconhecido",
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            comment["comment"] ?? "",
                            style: TextStyle(color: Colors.white70),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.favorite_border,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(userProfileImageUrl),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'Adicione um comentário...',
                              hintStyle: TextStyle(color: Colors.white60),
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Colors.grey[800],
                            ),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send, color: Colors.blue),
                          onPressed: () {
                            _addComment(postId);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Função para selecionar, editar e recortar a imagem antes de compartilhar
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Abre o editor de recorte de imagem
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(
            ratioX: 1, ratioY: 1), // Exemplo de proporção 1:1 (quadrado)
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Editar Imagem',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            hideBottomControls: false,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            minimumAspectRatio: 1.0,
            aspectRatioLockEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _selectedImage = File(croppedFile.path);
        });
        _showCreatePostModal();
      } else {
        _showCreatePostModal();
      }
    }
  }

  // Modal inicial para escolher criar postagem com ou sem imagem
  void _showCreatePostOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Selecionar Imagem da Galeria'),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage(); // Abre a galeria para selecionar imagem
              },
            ),
            ListTile(
              leading: Icon(Icons.text_fields),
              title: Text('Postar Somente Texto'),
              onTap: () {
                Navigator.pop(context);
                _showCreatePostModal(); // Abre o modal direto para texto
              },
            ),
          ],
        );
      },
    );
  }

  // Modal para criar a postagem com a imagem selecionada ou somente texto
  void _showCreatePostModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20.h,
            left: 20.w,
            right: 20.w,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: AspectRatio(
                    aspectRatio:
                        1, // Define uma proporção consistente para o feed
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover, // Ajusta a imagem para cobrir a área
                      width: double.infinity,
                      height: 200.h,
                    ),
                  ),
                ),
              SizedBox(height: 10.h),
              TextField(
                controller: _captionController,
                decoration: InputDecoration(
                  hintText: 'Escreva uma legenda...',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10.h),
              ElevatedButton(
                onPressed: _createPost,
                child: Text(
                  'Compartilhar',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Função para criar a postagem com a imagem e legenda ou apenas legenda
  Future<void> _createPost() async {
    try {
      await apiService.createPostWithImage(
        _captionController.text,
        _selectedImage,
      );
      _clearCreatePostData(); // Limpa após a criação
      fetchPosts(); // Atualiza as postagens após a criação
      Navigator.pop(context); // Fecha o modal
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao criar postagem')),
      );
    }
  }

  // Função para limpar os dados de criação de postagem ao sair do modal
  void _clearCreatePostData() {
    setState(() {
      _selectedImage = null;
      _captionController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Comunidade',
          style: TextStyle(fontSize: 20.sp),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed:
                _showCreatePostOptions, // Exibe o modal para criar postagem
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                currentPage = 1; // Reseta a página para 1 ao fazer refresh
                await fetchPosts(); // Recarrega as postagens
              },
              child: ListView.builder(
                controller: _scrollController, // Controlador de rolagem
                itemCount: posts.length +
                    (isLoadingMore ? 1 : 0), // Adiciona item de carregamento
                itemBuilder: (context, index) {
                  if (index == posts.length) {
                    return Center(
                      child:
                          CircularProgressIndicator(), // Mostra um indicador de carregamento ao final da lista
                    );
                  }
                  final post = posts[index];
                  bool isLiked = post['isLikedByCurrentUser'] ?? false;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(post["userId"]["photoUrl"] ?? ''),
                          radius: 24.r,
                        ),
                        title: Text(
                          post["userId"]["name"] ?? 'Usuário',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                        subtitle: Text(
                          formatarTempoEmPortugues(
                            DateTime.parse(post["createdAt"]),
                          ),
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                      if (post["imageUrl"] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Image.network(
                              post["imageUrl"],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200.h,
                            ),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        child: Text(
                          post["content"] ?? '',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.favorite,
                                    color: isLiked ? Colors.pink : Colors.grey,
                                    size: 24.sp,
                                  ),
                                  onPressed: () {
                                    toggleLikePost(post['_id'], isLiked);
                                  },
                                ),
                                Text(
                                  '${post["likes"]?.length ?? 0}',
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.mode_comment_outlined,
                                size: 24.sp,
                              ),
                              onPressed: () {
                                _showCommentsModal(
                                    context, post["comments"], post["_id"]);
                              },
                            ),
                            Text(
                              '${post["comments"]?.length ?? 0} comentários',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }
}
