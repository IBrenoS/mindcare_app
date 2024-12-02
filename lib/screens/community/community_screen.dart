import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:mindcare_app/services/api_service.dart';
import 'package:mindcare_app/utils/time_formatter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mindcare_app/theme/theme.dart';
import 'package:mindcare_app/utils/text_scale_helper.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final ApiService apiService = ApiService();
  List<dynamic> posts = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  int currentPage = 1;
  final int postsPerPage = 10;
  final ScrollController _scrollController = ScrollController();
  TextEditingController _commentController = TextEditingController();
  TextEditingController _captionController = TextEditingController();
  String userProfileImageUrl = 'https://via.placeholder.com/50';
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    fetchPosts();
    fetchUserProfile();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isLoadingMore) {
        fetchMorePosts();
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
        posts = fetchedPosts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(
            'Erro ao carregar postagens',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onError,
                ),
          ),
        ),
      );
    }
  }

  Future<void> fetchMorePosts() async {
    try {
      setState(() {
        isLoadingMore = true;
      });
      currentPage++;
      final fetchedPosts =
          await apiService.fetchPosts(currentPage, postsPerPage);
      if (fetchedPosts.isNotEmpty) {
        setState(() {
          posts.addAll(fetchedPosts);
        });
      }
      setState(() {
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(
            'Erro ao carregar mais postagens',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onError,
                ),
          ),
        ),
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
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(
            'Erro ao atualizar curtida',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onError,
                ),
          ),
        ),
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
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(
            'Erro ao adicionar comentário',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onError,
                ),
          ),
        ),
      );
    }
    FocusScope.of(context).unfocus();
  }

  void _showCommentsModal(BuildContext context, List comments, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
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
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40.w,
                    height: 4.h,
                    margin: EdgeInsets.only(top: 8.h, bottom: 10.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface,
                      borderRadius: BorderRadius.circular(2.r),
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
                          title: ScaledText(
                            comment["userId"] is Map
                                ? comment["userId"]["name"] ?? "Usuário"
                                : "Usuário Desconhecido",
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          subtitle: ScaledText(
                            comment["comment"] ?? "",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.favorite_border,
                              color: Theme.of(context).iconTheme.color,
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
                          padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(userProfileImageUrl),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: 'Adicione um comentário...',
                              hintStyle: Theme.of(context).textTheme.bodyMedium,
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                            ),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.send,
                            color: Theme.of(context).colorScheme.primary,
                          ),
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

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Editar Imagem',
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Theme.of(context).colorScheme.onPrimary,
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

  void _showCreatePostOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: Theme.of(context).iconTheme.color,
              ),
              title: Text(
                'Selecionar Imagem da Galeria',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              onTap: () async {
                Navigator.pop(context);
                await _pickImage();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.text_fields,
                color: Theme.of(context).iconTheme.color,
              ),
              title: Text(
                'Postar Somente Texto',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              onTap: () {
                Navigator.pop(context);
                _showCreatePostModal();
              },
            ),
          ],
        );
      },
    );
  }

  void _showCreatePostModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
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
                    aspectRatio: 1,
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
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
                  hintStyle: Theme.of(context).textTheme.bodyMedium,
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                ),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 10.h),
              ElevatedButton(
                onPressed: _createPost,
                child: Text(
                  'Compartilhar',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createPost() async {
    try {
      await apiService.createPostWithImage(
        _captionController.text,
        _selectedImage,
      );
      _clearCreatePostData();
      fetchPosts();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(
            'Erro ao criar postagem',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onError,
                ),
          ),
        ),
      );
    }
  }

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
        title: ScaledText(
          'Comunidade',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: _showCreatePostOptions,
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                currentPage = 1;
                await fetchPosts();
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: posts.length + (isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == posts.length) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final post = posts[index];
                  bool isLiked = post['isLikedByCurrentUser'] ?? false;
                  return _buildPost(post, isLiked);
                },
              ),
            ),
    );
  }

  Widget _buildPost(dynamic post, bool isLiked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(post["userId"]["photoUrl"] ?? ''),
            radius: 24.r,
          ),
          title: ScaledText(
            post["userId"]["name"] ?? 'Usuário',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: ScaledText(
            formatarTempoEmPortugues(DateTime.parse(post["createdAt"])),
            style: Theme.of(context).textTheme.bodyMedium,
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
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: ScaledText(
            post["content"] ?? '',
            style: Theme.of(context).textTheme.bodyLarge,
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
                      color: isLiked
                          ? likeColor // Usa a constante likeColor importada do theme.dart
                          : Theme.of(context).iconTheme.color,
                      size: 24.sp,
                    ),
                    onPressed: () {
                      toggleLikePost(post['_id'], isLiked);
                    },
                  ),
                  ScaledText(
                    '${post["likes"]?.length ?? 0}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.mode_comment_outlined,
                  color: Theme.of(context).iconTheme.color,
                  size: 24.sp,
                ),
                onPressed: () {
                  _showCommentsModal(context, post["comments"], post["_id"]);
                },
              ),
              ScaledText(
                '${post["comments"]?.length ?? 0} comentários',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
