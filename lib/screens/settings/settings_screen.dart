import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mindcare_app/screens/theme/theme_provider.dart';
import 'package:mindcare_app/screens/login/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  bool _isLoggingOut = false;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Inicializa o AnimationController para controlar a animação de fade
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Define a animação de fade de 1 (totalmente opaco) para 0 (totalmente transparente)
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Adiciona um listener para a animação para navegar após o fade
    _fadeAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _performLogout(context);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Função que lida com o logout e redireciona para a tela de login
  Future<void> _performLogout(BuildContext context) async {
    try {
      // Remove o token do armazenamento seguro
      await _secureStorage.delete(key: 'authToken');

      // Exibe uma mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você saiu da sua conta com sucesso.'),
          backgroundColor: Colors.green,
        ),
      );

      // Redireciona o usuário para a tela de login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Exibe uma mensagem de erro em caso de falha
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao sair da conta. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Função para iniciar a animação de fade ao realizar o logout
  void _logoutWithAnimation() {
    setState(() {
      _isLoggingOut = true;
    });
    _controller.forward(); // Inicia a animação de fade
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: FadeTransition(
        opacity:
            _isLoggingOut ? _fadeAnimation : const AlwaysStoppedAnimation(1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tema',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Modo Escuro', style: TextStyle(fontSize: 16)),
                  Switch(
                    value: themeProvider.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                  ),
                ],
              ),
              const Divider(),
              ListTile(
                title: const Text('Sair da Conta'),
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                onTap: () {
                  // Confirmação antes de sair
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Sair da Conta'),
                        content: const Text(
                            'Você realmente deseja sair da sua conta?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Fecha o diálogo
                              _logoutWithAnimation(); // Inicia o logout com animação
                            },
                            child: const Text(
                              'Sair',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
