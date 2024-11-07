import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mindcare_app/screens/settings/settings_screen.dart';
import 'package:mindcare_app/screens/content/content_management_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  File? _selectedImage;
  bool isEditing = false;
  bool isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  String userRole = "user";
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? token = await _secureStorage.read(key: 'authToken');
      if (token == null) {
        _showError('Erro de autenticação. Faça login novamente.');
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.get(
        Uri.parse('https://mindcare-bb0ea3046931.herokuapp.com/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        nameController.text = data['name'] ?? '';
        emailController.text = data['email'] ?? '';
        bioController.text = data['bio'] ?? '';
        userRole = data['role'] ?? 'user';

        setState(() {
          profileImageUrl = data['photoUrl'];
        });
      } else {
        _showError('Erro ao carregar o perfil. Tente novamente.');
      }
    } catch (e) {
      _showError('Erro de rede. Tente novamente mais tarde.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  Future<void> pickAndCropImage() async {
    setState(() {
      isLoading = true;
    });

    try {
      final XFile? pickedImage =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        final CroppedFile? croppedImage = await ImageCropper().cropImage(
          sourcePath: pickedImage.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Editar Imagem',
              toolbarColor: Theme.of(context).colorScheme.primary,
              toolbarWidgetColor: Theme.of(context).colorScheme.onPrimary,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
            ),
          ],
        );

        if (croppedImage != null) {
          setState(() {
            _selectedImage = File(croppedImage.path);
          });
        }
      }
    } catch (e) {
      _showError('Erro ao adicionar foto. Tente novamente.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      String? token = await _secureStorage.read(key: 'authToken');
      if (token == null) {
        _showError('Erro de autenticação. Faça login novamente.');
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final requestBody = {
        'name': nameController.text,
        'email': emailController.text,
        'bio': bioController.text,
        'currentPassword': currentPasswordController.text,
        'newPassword': newPasswordController.text,
      };

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await uploadImage(_selectedImage!, token);
      }

      if (imageUrl != null) {
        requestBody['profileImage'] = imageUrl;
      }

      final response = await http.put(
        Uri.parse('https://mindcare-bb0ea3046931.herokuapp.com/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            content: Text(
              'Perfil atualizado com sucesso!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
            ),
          ),
        );
        toggleEditMode();
      } else {
        final message =
            jsonDecode(response.body)['msg'] ?? 'Erro ao atualizar o perfil.';
        _showError(message);
      }
    } catch (e) {
      _showError('Erro de rede. Tente novamente mais tarde.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String?> uploadImage(File image, String token) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://mindcare-bb0ea3046931.herokuapp.com/auth/upload'),
      );

      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      request.headers['Authorization'] = 'Bearer $token';

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final decodedResponse = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        return decodedResponse['imageUrl'];
      } else {
        _showError(decodedResponse['msg'] ?? 'Erro ao fazer upload da imagem.');
      }
    } catch (e) {
      _showError('Erro ao fazer upload da imagem. Tente novamente.');
    }

    return null;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.error,
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onError,
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar Perfil' : 'Perfil do Usuário',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.menu,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onSelected: (value) {
              if (value == 'edit') {
                toggleEditMode();
              } else if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'edit',
                child: ListTile(
                  leading: Icon(
                    Icons.edit,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  title: Text(
                    'Editar Informações',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  title: Text(
                    'Configurações',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: isEditing ? pickAndCropImage : null,
                  child: CircleAvatar(
                    radius: 50.r,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (profileImageUrl != null
                                ? NetworkImage(profileImageUrl!)
                                : const AssetImage(
                                    'assets/images/default_avatar.png'))
                            as ImageProvider,
                  ),
                ),
                SizedBox(height: 16.h),
                if (!isEditing)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            nameController.text,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          SizedBox(width: 8.w),
                          if (userRole == 'moderator')
                            _buildBadge('Moderador', Colors.red),
                          if (userRole == 'admin')
                            _buildBadge('Administrador', Colors.amber),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        bioController.text,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.h),
                      if (userRole == 'moderator' || userRole == 'admin')
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ContentManagementScreen()),
                            );
                          },
                          child: Text(
                            'Gerenciar Conteúdos',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                          ),
                        ),
                    ],
                  ),
                if (isEditing)
                  Column(
                    children: [
                      _buildTextField(
                        controller: nameController,
                        label: 'Nome',
                      ),
                      _buildTextField(
                        controller: bioController,
                        label: 'Bio',
                      ),
                      _buildTextField(
                        controller: emailController,
                        label: 'Email',
                      ),
                      _buildTextField(
                        controller: currentPasswordController,
                        label: 'Senha Atual',
                        obscureText: true,
                      ),
                      _buildTextField(
                        controller: newPasswordController,
                        label: 'Nova Senha',
                        obscureText: true,
                      ),
                      SizedBox(height: 20.h),
                      ElevatedButton(
                        onPressed: saveProfile,
                        child: Text(
                          'Salvar Alterações',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                        ),
                      ),
                      TextButton(
                        onPressed: toggleEditMode,
                        child: Text(
                          'Cancelar',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: Theme.of(context).textTheme.bodyMedium,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
