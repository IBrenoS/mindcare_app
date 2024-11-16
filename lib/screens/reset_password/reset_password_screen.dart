import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:mindcare_app/screens/login/login_screen.dart';
import 'package:mindcare_app/theme/theme.dart';

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

  // Variáveis para verificar as regras da senha
  bool _isMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordRules);
  }

  void _checkPasswordRules() {
    final password = _passwordController.text;

    setState(() {
      _isMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#\$&*~\.\-_\+]'));
    });
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
          title: Text('Erro',
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
          content: Row(
            children: [
              Icon(Icons.error, color: Theme.of(context).colorScheme.error),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
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
          title: Text('Sucesso',
              style: TextStyle(color: successColorLight)),
          content: Row(
            children: [
              Icon(Icons.check_circle,
                  color: successColorLight),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Senha redefinida com sucesso!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
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
    _passwordController.removeListener(_checkPasswordRules);
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Método para construir o campo de senha
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      enabled: !_isLoading,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
      decoration: InputDecoration(
        labelText: 'Nova Senha',
        labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: Theme.of(context).colorScheme.primary,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
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
          return 'Por favor, insira sua nova senha';
        }
        if (!_isMinLength ||
            !_hasUppercase ||
            !_hasLowercase ||
            !_hasNumber ||
            !_hasSpecialChar) {
          return 'A senha não atende aos requisitos';
        }
        return null;
      },
    );
  }

  // Método para construir o campo de confirmação de senha
  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      enabled: !_isLoading,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
      decoration: InputDecoration(
        labelText: 'Confirme a Nova Senha',
        labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: Theme.of(context).colorScheme.primary,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
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
          return 'Por favor, confirme sua nova senha';
        }
        if (value != _passwordController.text) {
          return 'As senhas não correspondem';
        }
        return null;
      },
    );
  }

  // Método para construir o card com as regras da senha
  Widget _buildPasswordRulesCard() {
    return Card(
      color: Theme.of(context).colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A senha deve conter:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            SizedBox(height: 10.h),
            _buildRuleItem('Pelo menos 8 caracteres', _isMinLength),
            _buildRuleItem('Uma letra maiúscula (A-Z)', _hasUppercase),
            _buildRuleItem('Uma letra minúscula (a-z)', _hasLowercase),
            _buildRuleItem('Um número (0-9)', _hasNumber),
            _buildRuleItem(
                'Um caractere especial (!@#\$&*~.-_+)', _hasSpecialChar),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isValid
              ? Colors.green
              : Theme.of(context).colorScheme.onSurfaceVariant,
          size: 20.sp,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isValid
                      ? Colors.green
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }

  // Método para construir o botão de redefinir senha
  Widget _buildResetButton() {
    return SizedBox(
      width: 180.w,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _resetPassword,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.r),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
            : Text('Redefinir Senha',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 18.sp,
                    )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Redefinir Senha',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 20.h),
                Icon(
                  Icons.lock_reset,
                  size: 80.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(height: 20.h),
                Text(
                  'Digite sua nova senha para redefinir.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16.sp,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                ),
                SizedBox(height: 20.h),
                _buildPasswordField(),
                SizedBox(height: 10.h),
                _buildPasswordRulesCard(),
                SizedBox(height: 20.h),
                _buildConfirmPasswordField(),
                SizedBox(height: 30.h),
                _buildResetButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
