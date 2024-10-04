import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; 
import 'package:http/http.dart' as http;
import 'package:mindcare_app/screens/home/home_screen.dart';
import 'package:mindcare_app/screens/password_recovery/password_recovery_screen.dart';
import 'package:mindcare_app/screens/register/register_screen.dart';
import 'package:mindcare_app/screens/theme/theme_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Instância para armazenar o token de forma segura
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Função de login que faz a requisição ao backend
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final String email = _emailController.text;
      final String password = _passwordController.text;

      try {
        final response = await http.post(
          Uri.parse('https://mindcare-bb0ea3046931.herokuapp.com/auth/login'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': email,
            'password': password,
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            _isLoading = false;
          });

          final Map<String, dynamic> data = jsonDecode(response.body);
          final String token = data['token'];
          await _secureStorage.write(key: 'authToken', value: token);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Login bem-sucedido!'),
              backgroundColor: successColor,
            ),
          );

          await Future.delayed(const Duration(seconds: 1));

          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const HomeScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            ),
          );
        } else {
          setState(() {
            _isLoading = false;
          });

          final Map<String, dynamic> errorData = jsonDecode(response.body);
          final String errorMessage =
              errorData['message'] ?? 'E-mail ou senha inválidos';

          _showError('Login falhou: $errorMessage');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showError('Erro de rede. Tente novamente mais tarde.');
      }
    }
  }

  // Função para mostrar uma mensagem de erro
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Erro'),
          content: Text(
            message,
            style: TextStyle(
              color:
                  Theme.of(context).colorScheme.error, // Texto de erro adaptado
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, // Adaptação ao tema
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildLogo(),
                SizedBox(height: 20.h),
                _buildForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo.png',
      height: 250.h,
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          _buildEmailField(),
          SizedBox(height: 20.h),
          _buildPasswordField(),
          SizedBox(height: 20.h),
          _buildLoginButton(),
          SizedBox(height: 10.h),
          _buildForgotPasswordLink(),
          SizedBox(height: 10.h),
          _buildRegisterLink(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, insira o e-mail';
        }
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Insira um e-mail válido';
        }
        return null;
      },
      style: TextStyle(
          color: Theme.of(context)
              .colorScheme
              .onSurface), // Cor do texto ajustada ao tema
      decoration: InputDecoration(
        labelText: 'E-mail',
        fillColor:
            Theme.of(context).colorScheme.surface, // Fundo adaptado ao tema
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        hintStyle: TextStyle(
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withOpacity(0.6), // Placeholder ajustado
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, insira sua senha';
        } else if (value.length < 6) {
          return 'A senha deve ter no mínimo 6 caracteres';
        }
        return null;
      },
      style: TextStyle(
          color: Theme.of(context)
              .colorScheme
              .onSurface), // Cor do texto ajustada ao tema
      decoration: InputDecoration(
        labelText: 'Senha',
        fillColor:
            Theme.of(context).colorScheme.surface, // Fundo adaptado ao tema
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        hintStyle: TextStyle(
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withOpacity(0.6), // Placeholder ajustado
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color:
                Theme.of(context).iconTheme.color, // Adaptação da cor do ícone
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return _isLoading
        ? const CircularProgressIndicator()
        : ElevatedButton(
            onPressed: _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: bottomColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 55.w, vertical: 15.h),
            ),
            child: Text(
              'Login',
              style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                  ),
            ),
          );
  }

  void _navigateToScreen(Widget screen, int duration) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
        transitionDuration: Duration(milliseconds: duration),
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return GestureDetector(
      onTap: () {
        _navigateToScreen(const PasswordRecoveryScreen(), 500);
      },
      child: Text(
        'Esqueceu a senha?',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return GestureDetector(
      onTap: () {
        _navigateToScreen(const RegisterScreen(), 600);
      },
      child: Text(
        'Criar nova Conta',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
      ),
    );
  }
}
