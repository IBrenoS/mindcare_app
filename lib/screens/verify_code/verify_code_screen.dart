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
        _showError('Erro de rede. Tente novamente mais tarde.');
      }
    }
  }

  // Função para exibir mensagens de erro
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline,
                color: Theme.of(context).colorScheme.onError),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Theme.of(context).colorScheme.onError),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verificar Código',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
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
                    Icons.lock_open,
                    size: 80.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Insira o código enviado para o e-mail:',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 16.sp,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    receivedEmail.isNotEmpty
                        ? receivedEmail
                        : "E-mail não informado",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  SizedBox(height: 20.h),
                  _buildCodeField(),
                  SizedBox(height: 20.h),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : _buildVerifyButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCodeField() {
    return TextFormField(
      controller: _codeController,
      keyboardType: TextInputType.number,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
      decoration: InputDecoration(
        labelText: 'Código de Verificação',
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
        prefixIcon: Icon(
          Icons.vpn_key_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, insira o código de verificação';
        }
        if (!RegExp(r'^\d{6}$').hasMatch(value)) {
          return 'O código deve ter 6 dígitos numéricos';
        }
        return null;
      },
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: 180.w,
      child: ElevatedButton(
        onPressed: _verifyCode,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.r),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        child: Text(
          'Verificar Código',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 18.sp,
              ),
        ),
      ),
    );
  }
}
