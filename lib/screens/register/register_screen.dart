import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:mindcare_app/screens/login/login_screen.dart';
import 'package:mindcare_app/theme/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  // Função de cadastro
  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse(
              'https://mindcare-bb0ea3046931.herokuapp.com/auth/register'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'name': _nameController.text,
            'email': _emailController.text,
            'phone': _phoneController.text,
            'password': _passwordController.text,
            'passwordConfirmation': _confirmPasswordController.text,
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            _isLoading = false;
          });

          // Exibir um diálogo de sucesso
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Sucesso'),
                content: const Text(
                    'Registro bem-sucedido! Agora você pode fazer login.'),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                  ),
                ],
              );
            },
          );
        } else {
          setState(() {
            _isLoading = false;
          });
          _showError('Erro no registro: ${jsonDecode(response.body)['msg']}');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showError('Erro de rede. Tente novamente mais tarde.');
      }
    }
  }

  // Função para exibir mensagens de erro
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.onError),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Criar Conta', style: TextStyle(fontSize: 18.sp)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.w), // Use ScreenUtil for padding
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 350.w, // Adjusted width for responsiveness
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          labelText: 'Nome Completo',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira seu nome completo';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h), // Responsive spacing
                        _buildTextField(
                          controller: _emailController,
                          labelText: 'E-mail',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira seu e-mail';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return 'Por favor, insira um e-mail válido';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h), // Responsive spacing
                        _buildTextField(
                          controller: _phoneController,
                          labelText: 'Telefone',
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira seu número de telefone';
                            }
                            if (!RegExp(r'^\d{10,15}$').hasMatch(value)) {
                              return 'Por favor, insira um número de telefone válido';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h), // Responsive spacing
                        _buildPasswordField(
                          controller: _passwordController,
                          labelText: 'Senha',
                          obscureText: _obscurePassword,
                          onTapSuffix: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        SizedBox(height: 16.h), // Responsive spacing
                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          labelText: 'Confirmação de Senha',
                          obscureText: _obscureConfirmPassword,
                          onTapSuffix: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'As senhas não correspondem';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 24.h), // Responsive spacing
                        _buildRegisterButton(),
                        SizedBox(height: 16.h), // Responsive spacing
                        _buildLoginLink(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Function()? onTapSuffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: labelText,
        fillColor: Theme.of(context).colorScheme.surface,
        filled: true,
        labelStyle: TextStyle(
            fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        suffixIcon: onTapSuffix != null
            ? IconButton(
                icon:
                    Icon(obscureText ? Icons.visibility_off : Icons.visibility),
                onPressed: onTapSuffix,
              )
            : null,
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    Function()? onTapSuffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: labelText,
        fillColor: Theme.of(context).colorScheme.surface,
        filled: true,
        labelStyle: TextStyle(
            fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: onTapSuffix,
        ),
      ),
      validator: validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira sua senha';
            }
            if (value.length < 6) {
              return 'A senha deve ter pelo menos 6 caracteres';
            }
            return null;
          },
    );
  }

  Widget _buildRegisterButton() {
    return _isLoading
        ? const CircularProgressIndicator()
        : SizedBox(
            width: 210.w, // Adjusted for responsiveness
            height: 50.h,
            child: ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: bottomColor,
                padding: EdgeInsets.symmetric(
                  horizontal: 50.w, // Responsive horizontal padding
                  vertical: 15.h,   // Responsive vertical padding
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r), // Responsive radius
                ),
              ),
              child: Text(
                'Criar Conta',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontSize: 18.sp, // Responsive font size
                ),
              ),
            ),
          );
  }

  Widget _buildLoginLink() {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const LoginScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      },
      child: Text(
        'Já tem uma conta? Faça login',
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontSize: 14.sp,
        ),
      ),
    );
  }
}
