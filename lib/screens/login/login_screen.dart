import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Importando flutter_screenutil
import 'package:mindcare_app/screens/home/home_screen.dart';
import 'package:mindcare_app/screens/password_recovery/password_recovery_screen.dart';
import 'package:mindcare_app/screens/register/register_screen.dart';

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

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        if (_emailController.text.isNotEmpty &&
            _passwordController.text.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  HomeScreen(),
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
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.w), // Adaptado para responsividade
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/logo.png',
                  height: 250.h, // Altura adaptada para telas menores
                ),
                SizedBox(height: 20.h), // Espaçamento adaptado
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      // Campo de E-mail
                      TextFormField(
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
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10.r), // Responsivo
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h), // Espaçamento adaptado

                      // Campo de Senha
                      TextFormField(
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
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(10.r), // Responsivo
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h), // Espaçamento adaptado

                      // Botão de Login
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightBlue.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(25.r), // Responsivo
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 55.w,
                                    vertical: 15.h), // Adaptado
                              ),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp, // Fonte adaptada
                                ),
                              ),
                            ),
                      SizedBox(height: 10.h), // Espaçamento adaptado

                      // Link "Esqueceu a senha?"
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      PasswordRecoveryScreen(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
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
                              transitionDuration: const Duration(
                                  milliseconds: 500), // Mantido em 500ms
                            ),
                          );
                        },
                        child: Text(
                          'Esqueceu a senha?',
                          style: TextStyle(
                            color: const Color(0xFF007AFF),
                            fontSize: 14.sp, // Fonte adaptada
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h), // Espaçamento adaptado

                      // Link "Criar nova Conta"
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const RegisterScreen(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
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
                              transitionDuration: const Duration(
                                  milliseconds: 600), // Mantido em 600ms
                            ),
                          );
                        },
                        child: Text(
                          'Criar nova Conta',
                          style: TextStyle(
                            color: const Color(0xFF007AFF),
                            fontSize: 14.sp, // Fonte adaptada
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
