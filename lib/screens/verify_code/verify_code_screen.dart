import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mindcare_app/screens/reset_password/reset_password_screen.dart';
import 'package:http/http.dart' as http;

class VerifyCodeScreen extends StatefulWidget {
  final String email;

  const VerifyCodeScreen({Key? key, required this.email}) : super(key: key);

  @override
  _VerifyCodeScreenState createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  late String receivedEmail;

  @override
  void initState() {
    super.initState();
    receivedEmail = widget.email.isNotEmpty
        ? widget.email
        : (ModalRoute.of(context)?.settings.arguments as String?) ?? '';
    print('E-mail recebido na tela de verificação: $receivedEmail');
  }

  // Função para verificar o código de recuperação
  Future<void> _verifyCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final email = receivedEmail.trim();
        final code = _codeController.text.trim();
        print('Verificando código: $code para o e-mail: $email');

        final response = await http.post(
          Uri.parse(
              'https://mindcare-bb0ea3046931.herokuapp.com/auth/verifyCode'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({
            'email': email,
            'code': code,
          }),
        );

        setState(() {
          _isLoading = false;
        });

        print('Resposta do backend: ${response.statusCode} - ${response.body}');

        if (response.statusCode == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(
                email: widget.email,
                code: _codeController.text.trim(),
              ),
            ),
          );
        } else {
          final message =
              jsonDecode(response.body)['msg'] ?? 'Código inválido.';
          _showError(message);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print('Erro ao verificar o código: $e');
        _showError('Erro de rede. Tente novamente mais tarde.');
      }
    }
  }

  // Função para exibir mensagens de erro
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
        title: Text('Verificar Código', style: TextStyle(fontSize: 18.sp)),
        backgroundColor: Colors.lightBlue.shade700,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Insira o código enviado para o e-mail ${receivedEmail.isNotEmpty ? receivedEmail : "não informado"}.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp),
              ),
              SizedBox(height: 20.h),
              TextFormField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Código de Verificação',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o código de verificação';
                  }
                  if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                    return 'O código deve ter 6 dígitos numéricos';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _verifyCode,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 50.w,
                          vertical: 15.h,
                        ),
                        textStyle: TextStyle(fontSize: 16.sp),
                      ),
                      child: const Text('Verificar Código'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
