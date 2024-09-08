import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Responsividade

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  _PasswordRecoveryScreenState createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isButtonDisabled = true; // Controla se o botão está desabilitado

  @override
  void initState() {
    super.initState();
    _emailController.addListener(
        _checkEmailValidity); // Listener para habilitar/desabilitar o botão
  }

  void _checkEmailValidity() {
    setState(() {
      _isButtonDisabled =
          _emailController.text.isEmpty || !_emailController.text.contains('@');
    });
  }

  void _sendRecoveryEmail() {
    if (_formKey.currentState!.validate()) {
      // Simulação do envio de e-mail de recuperação
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-mail de recuperação enviado!'),
          backgroundColor: Colors.green,
        ),
      );
      // Redirecionar para a tela de login após o envio do e-mail
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Recuperação de Senha',
          style: TextStyle(fontSize: 20.sp), // Fonte adaptada
        ),
        backgroundColor: Colors.lightBlue.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Colors.white), // Ícone customizado
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w), // Padding adaptado
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Insira seu e-mail cadastrado para recuperar sua senha.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp), // Fonte adaptada
              ),
              SizedBox(height: 24.h), // Espaçamento adaptado
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 12.h, horizontal: 16.w), // Padding ajustado
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r), // Borda adaptada
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
              SizedBox(height: 24.h), // Espaçamento adaptado
              ElevatedButton(
                onPressed: _isButtonDisabled
                    ? null
                    : _sendRecoveryEmail, // Desabilita o botão quando inválido
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isButtonDisabled
                      ? Colors.grey.shade400
                      : Colors.lightBlue
                          .shade700, // Cor do botão desabilitada/habilitada
                  foregroundColor:
                      Colors.white, // Cor do texto definida como branca
                  padding: EdgeInsets.symmetric(
                    horizontal: 50.w, // Padding adaptado
                    vertical: 15.h, // Padding adaptado
                  ),
                  textStyle: TextStyle(fontSize: 18.sp), // Fonte adaptada
                ),
                child: const Text('Recuperar Senha'),
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
