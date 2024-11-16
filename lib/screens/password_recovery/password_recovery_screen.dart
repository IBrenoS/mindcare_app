import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mindcare_app/screens/verify_code/verify_code_screen.dart';
import 'package:http/http.dart' as http;
import 'package:mindcare_app/theme/theme.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  _PasswordRecoveryScreenState createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isButtonDisabled = true;
  bool _isLoading = false;

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
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: msg),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Se o e-mail estiver cadastrado, um código de verificação será enviado.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: msg,
                          ),
                    ),
                  ),
                ],
              ),
              backgroundColor: successColorLight,
            ),
          );

          // Navegar para a tela de verificação de código
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
        content: Row(
          children: [
            Icon(Icons.error, color: Theme.of(context).colorScheme.onError),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onError,
                    ),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  // Método para construir o campo de e-mail
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
      decoration: InputDecoration(
        labelText: 'E-mail',
        labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: EdgeInsets.symmetric(
          vertical: 12.h,
          horizontal: 16.w,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
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
    );
  }

  // Método para construir o botão de recuperação
  Widget _buildRecoveryButton() {
    return SizedBox(
      width: 180.w,
      child: ElevatedButton(
        onPressed: _isButtonDisabled ? null : _sendRecoveryEmail,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.r),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          disabledBackgroundColor: Theme.of(context).disabledColor,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
            : Text(
                'Recuperar Senha',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 18.sp,
                    ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.removeListener(_checkEmailValidity);
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recuperação de Senha',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 80.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Insira seu e-mail cadastrado para recuperar sua senha.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 16.sp,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                  ),
                  SizedBox(height: 24.h),
                  _buildEmailField(),
                  SizedBox(height: 24.h),
                  _buildRecoveryButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
