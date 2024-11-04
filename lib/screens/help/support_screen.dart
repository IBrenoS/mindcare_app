import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil

class SupportScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  void _submitForm(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mensagem enviada com sucesso!')),
      );
      // Lógica de envio da mensagem para o backend aqui
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suporte e Contato'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.r), // Adjust padding
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Seu E-mail'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Insira um e-mail válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(labelText: 'Mensagem'),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Escreva uma mensagem';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h), // Adjust spacing
              ElevatedButton(
                onPressed: () => _submitForm(context),
                child: Text(
                  'Enviar',
                  style: TextStyle(fontSize: 16.sp), // Adjust button text size
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
