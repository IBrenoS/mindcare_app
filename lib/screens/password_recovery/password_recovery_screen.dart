import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mindcare_app/screens/theme/theme_screen.dart';
import 'package:mindcare_app/screens/verify_code/verify_code_screen.dart';
import 'package:http/http.dart' as http;

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  _PasswordRecoveryScreenState createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isButtonDisabled = true; // Controla se o botão está desabilitado
  bool _isLoading = false; // Controla o estado de carregamento

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_checkEmailValidity);
  }

  void _checkEmailValidity() {
    setState(() {
      _isButtonDisabled =
          _emailController.text.isEmpty || !_emailController.text.contains('@');
    });
  }

  // Função para enviar e-mail de recuperação de senha ao backend
  Future<void> _sendRecoveryEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final email = _emailController.text.trim();

        // Enviar o e-mail para o endpoint de recuperação de senha
        final response = await http.post(
          Uri.parse(
              'https://mindcare-bb0ea3046931.herokuapp.com/auth/forgotPassword'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': email,
          }),
        );

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Se o e-mail estiver cadastrado, um código de verificação será enviado.',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
              backgroundColor: successColor,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyCodeScreen(
                email: _emailController.text.trim(),
              ),
            ),
          );
        } else {
          final message = jsonDecode(response.body)['msg'] ?? 'Erro inesperado';
          _showError(message);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showError('Erro de rede. Tente novamente mais tarde.');
      }
    }
  }

  // Função para exibir erros
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Recuperação de Senha',
          style: TextStyle(
            fontSize: 20.sp,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Insira seu e-mail cadastrado para recuperar sua senha.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 24.h),
              TextFormField(
                controller: _emailController,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  labelStyle:
                      TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  fillColor: Theme.of(context).colorScheme.surface,
                  filled: true,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide:
                        BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu e-mail';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Por favor, insira um e-mail válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.h),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _isButtonDisabled ? null : _sendRecoveryEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isButtonDisabled
                            ? Theme.of(context).disabledColor
                            : Theme.of(context).colorScheme.primary,
                        padding: EdgeInsets.symmetric(
                          horizontal: 50.w,
                          vertical: 15.h,
                        ),
                        textStyle: TextStyle(fontSize: 18.sp),
                      ),
                      child: Text(
                        'Recuperar Senha',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
