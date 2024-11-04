import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mindcare_app/screens/theme/theme_provider.dart';
import 'package:mindcare_app/screens/login/login_screen.dart';
import 'package:mindcare_app/screens/help/help_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
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

    // Define a animação de fade de 1 (opaco) para 0 (transparente)
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // Listener para navegação após o fade
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

  Future<void> _performLogout(BuildContext context) async {
    try {
      // Remove o token de autenticação
      await _secureStorage.delete(key: 'authToken');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você saiu da sua conta com sucesso.'),
          backgroundColor: Colors.green,
        ),
      );

      // Redireciona para a tela de login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao sair da conta. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _logoutWithAnimation() {
    setState(() {
      _isLoggingOut = true;
    });
    _controller.forward();
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
          padding: EdgeInsets.all(16.w), // Adjust padding for responsiveness
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tema',
                style: TextStyle(
                  fontSize: 20.sp, // Adjust font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.h), // Adjust height for responsiveness
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Modo Escuro',
                    style: TextStyle(fontSize: 16.sp), // Adjust font size
                  ),
                  Switch(
                    value: themeProvider.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                  ),
                ],
              ),
              const Divider(),

              // Opção para o botão de Suporte ao Usuário
              ListTile(
                title: const Text('Suporte ao Usuário'),
                leading:
                    const Icon(Icons.help_outline, color: Colors.blueAccent),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HelpScreen()),
                  );
                },
              ),
              const Divider(),

              // Opção de Sair da Conta com animação
              ListTile(
                title: const Text('Sair da Conta'),
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                onTap: () {
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
                              Navigator.of(context).pop();
                              _logoutWithAnimation();
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
