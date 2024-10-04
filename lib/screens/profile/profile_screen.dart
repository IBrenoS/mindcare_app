import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mindcare_app/screens/settings/settings_screen.dart'; 

class UserProfileScreen extends StatefulWidget {
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
              toolbarColor: Colors.black,
              toolbarWidgetColor: Colors.white,
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
          SnackBar(content: Text('Perfil atualizado com sucesso!')),
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
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Perfil' : 'Perfil do Usuário'),
        actions: [
          // Ícone de menu com opções de editar e configurações
          PopupMenuButton<String>(
            icon: Icon(Icons.menu), // Ícone de menu
            onSelected: (value) {
              if (value == 'edit') {
                toggleEditMode(); // Alterna para o modo de edição
              } else if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const SettingsScreen()), // Navega para a tela de configurações
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Editar Informações'),
                ),
              ),
              PopupMenuItem<String>(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Configurações'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: isEditing ? pickAndCropImage : null,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (profileImageUrl != null
                                ? NetworkImage(profileImageUrl!)
                                : AssetImage(
                                    'assets/images/default_avatar.png'))
                            as ImageProvider,
                  ),
                ),
                SizedBox(height: 16),
                if (!isEditing)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            nameController.text,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          if (userRole == 'moderator')
                            _buildBadge('Moderador', Colors.red),
                          if (userRole == 'admin')
                            _buildBadge('Administrador', Colors.amber),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        bioController.text,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      if (userRole == 'moderator' || userRole == 'admin')
                        ElevatedButton(
                          onPressed: () {
                            print('Gerenciar Conteúdos');
                          },
                          child: Text('Gerenciar Conteúdos'),
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
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: saveProfile,
                        child: Text('Salvar Alterações'),
                      ),
                      TextButton(
                        onPressed: toggleEditMode,
                        child: Text('Cancelar'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
