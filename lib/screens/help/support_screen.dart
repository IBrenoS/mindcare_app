import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mindcare_app/services/api_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final ApiService apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  String _selectedSubject = 'Dúvida';

  final List<String> subjects = [
    'Dúvida',
    'Problema Técnico',
    'Feedback',
    'Sugestão',
    'Outros'
  ];

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await apiService.sendContactMessage(
          name: _nameController.text,
          email: _emailController.text,
          subject: _selectedSubject,
          message: _messageController.text,
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Mensagem enviada com sucesso!',
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
              backgroundColor: Colors.green,
            ),
          );
          _nameController.clear();
          _emailController.clear();
          _messageController.clear();
          setState(() {
            _selectedSubject = 'Dúvida';
          });
        } else {
          final errorMsg =
              jsonDecode(response.body)['message'] ?? 'Erro ao enviar mensagem';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorMsg,
                style: TextStyle(color: Theme.of(context).colorScheme.onError),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
              style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contato com Suporte',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Título
              Text(
                'Como podemos ajudar?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 20.h),
              // Campo Nome
              _buildTextField(
                controller: _nameController,
                labelText: 'Nome (opcional)',
                icon: Icons.person_outline,
              ),
              SizedBox(height: 16.h),
              // Campo E-mail
              _buildTextField(
                controller: _emailController,
                labelText: 'E-mail',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Por favor, insira um e-mail válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              // Campo Assunto
              _buildDropdownField(),
              SizedBox(height: 16.h),
              // Campo Mensagem
              _buildTextField(
                controller: _messageController,
                labelText: 'Mensagem',
                icon: Icons.message_outlined,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, escreva uma mensagem';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.h),
              // Botão Enviar
              SizedBox(
                 width: 200.w,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: Text(
                    'Enviar',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 18.sp,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método para construir os campos de texto
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
        prefixIcon: Icon(
          icon,
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
      validator: validator,
    );
  }

  // Método para construir o campo Dropdown
  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _selectedSubject,
      items: subjects
          .map((subject) => DropdownMenuItem(
                value: subject,
                child: Text(subject),
              ))
          .toList(),
      onChanged: (value) => setState(() => _selectedSubject = value!),
      decoration: InputDecoration(
        labelText: 'Assunto',
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
        prefixIcon: Icon(
          Icons.subject,
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
    );
  }
}
