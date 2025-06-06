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
import 'package:mindcare_app/services/api_service.dart';
import 'package:mindcare_app/theme/theme.dart'; // Adicione a importação do ApiService
import 'package:mindcare_app/utils/text_scale_helper.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final ApiService _apiService = ApiService(); // Instancie o ApiService
  File? _selectedImage;
  bool isEditing = false;
  bool isLoading = false;
  bool _isCurrentPasswordObscured = true;
  bool _isNewPasswordObscured = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
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
    // modo de edição seja encerrado ao sair da tela
    if (isEditing) {
      setState(() {
        isEditing = false;
      });
    }
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
        phoneController.text = data['phone'] ?? ''; // Add this line
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

  void didChangeDependencies() {
    super.didChangeDependencies();

    // Verificar se a tela ainda está ativa e, se não estiver, desativar o modo de edição
    if (!ModalRoute.of(context)!.isCurrent && isEditing) {
      setState(() {
        isEditing = false;
      });
    }
  }

  void toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
      // Fechar o teclado virtual ao sair do modo de edição
      FocusScope.of(context).unfocus();
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
      await _apiService.updateProfile(
        name: nameController.text,
        bio: bioController.text,
        phone: phoneController.text,
        email: emailController.text,
        password: currentPasswordController.text,
        newPassword: newPasswordController.text,
        image: _selectedImage,
      );

      currentPasswordController.clear();
      newPasswordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: successColorLight,
          content: ScaledText(
            'Perfil atualizado com sucesso!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:msg,
                ),
          ),
        ),
      );
      toggleEditMode();
    } catch (e) {
      _showError('Erro ao atualizar o perfil. Tente novamente.');
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
        content: ScaledText(
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
        title: ScaledText(
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
                  title: ScaledText(
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
                  title: ScaledText(
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
                          ScaledText(
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
                      ScaledText(
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
                          child: ScaledText(
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
                        controller: phoneController,
                        label: 'Telefone',
                      ),
                      _buildTextField(
                        controller: currentPasswordController,
                        label: 'Senha Atual',
                        obscureText: _isCurrentPasswordObscured,
                        toggleObscureText: () {
                          setState(() {
                            _isCurrentPasswordObscured =
                                !_isCurrentPasswordObscured;
                          });
                        },
                      ),
                      _buildTextField(
                        controller: newPasswordController,
                        label: 'Nova Senha',
                        obscureText: _isNewPasswordObscured,
                        toggleObscureText: () {
                          setState(() {
                            _isNewPasswordObscured = !_isNewPasswordObscured;
                          });
                        },
                      ),
                      SizedBox(height: 20.h),
                      ElevatedButton(
                        onPressed: saveProfile,
                        child: ScaledText(
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
                        child: ScaledText(
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
    VoidCallback? toggleObscureText,
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
          suffixIcon: toggleObscureText != null
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: toggleObscureText,
                )
              : null,
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
      child: ScaledText(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
