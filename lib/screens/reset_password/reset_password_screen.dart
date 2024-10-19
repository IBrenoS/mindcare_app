import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:mindcare_app/screens/login/login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String code;

  const ResetPasswordScreen({Key? key, required this.email, required this.code})
      : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  late String receivedEmail = widget.email.isNotEmpty ? widget.email : '';
  late String receivedCode = widget.code.isNotEmpty ? widget.code : '';

  @override
  void initState() {
    super.initState();
    // Apenas logs para depuração (pode ser removido em produção)
    print('E-mail recebido: $receivedEmail');
    print('Código de verificação recebido: $receivedCode');
  }

  // Função para redefinir a senha
  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final email = receivedEmail.trim();
        final code = receivedCode.trim();
        final newPassword = _passwordController.text.trim();

        // Envio da nova senha para o backend
        final response = await http
            .post(
              Uri.parse(
                  'https://mindcare-bb0ea3046931.herokuapp.com/auth/resetPassword'),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8'
              },
              body: jsonEncode(<String, String>{
                'email': email,
                'code': code,
                'newPassword': newPassword
              }),
            )
            .timeout(const Duration(seconds: 15));

        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          setState(() {
            _isLoading = false;
          });

          _passwordController.clear();
          _confirmPasswordController.clear();
          _showSuccessDialog(); // Mostra o sucesso
        } else {
          final String errorMessage = responseData['msg'] ??
              'Erro inesperado. Verifique e tente novamente.';
          _showError(errorMessage);
        }
      } on TimeoutException catch (_) {
        setState(() {
          _isLoading = false;
        });
        _showError(
            'Tempo de conexão esgotado. Verifique sua conexão e tente novamente.');
      } on SocketException catch (_) {
        setState(() {
          _isLoading = false;
        });
        _showError('Sem conexão com a internet. Verifique sua conexão.');
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showError('Ocorreu um erro inesperado. Tente novamente mais tarde.');
      }
    }
  }

  // Função para exibir mensagens de erro
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Erro', style: TextStyle(color: Colors.red)),
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
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

  // Função para exibir diálogo de sucesso
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sucesso', style: TextStyle(color: Colors.green)),
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Expanded(child: Text('Senha redefinida com sucesso!')),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                ); // Navega para a tela de login
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Redefinir Senha', style: TextStyle(fontSize: 18.sp)),
        backgroundColor: Colors.lightBlue.shade700,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 50.h),
                Text(
                  'Digite sua nova senha para redefinir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.sp),
                ),
                SizedBox(height: 20.h),

                // Campo de Nova Senha
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Nova Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua nova senha';
                    }
                    if (value.length < 8) {
                      return 'A senha deve ter pelo menos 8 caracteres';
                    }
                    if (!RegExp(r'(?=.*?[A-Z])').hasMatch(value)) {
                      return 'A senha deve ter pelo menos uma letra maiúscula';
                    }
                    if (!RegExp(r'(?=.*?[a-z])').hasMatch(value)) {
                      return 'A senha deve ter pelo menos uma letra minúscula';
                    }
                    if (!RegExp(r'(?=.*?[0-9])').hasMatch(value)) {
                      return 'A senha deve ter pelo menos um número';
                    }
                    if (!RegExp(r'(?=.*?[!@#\$&*~.])').hasMatch(value)) {
                      return 'A senha deve ter pelo menos um caractere especial';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                // Campo de Confirmação de Nova Senha
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    labelText: 'Confirme a Nova Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, confirme sua nova senha';
                    }
                    if (value != _passwordController.text) {
                      return 'As senhas não correspondem';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),

                // Botão para redefinir senha
                ElevatedButton(
                  onPressed: _isLoading ? null : _resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue.shade700,
                    padding:
                        EdgeInsets.symmetric(horizontal: 50.w, vertical: 15.h),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white))
                      : Text('Redefinir Senha',
                          style:
                              TextStyle(color: Colors.white, fontSize: 18.sp)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
