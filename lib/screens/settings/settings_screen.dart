import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mindcare_app/screens/login/login_screen.dart';
import 'package:mindcare_app/screens/help/help_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mindcare_app/screens/settings/accessibility_screen.dart';
import 'package:mindcare_app/screens/settings/privacy_screen.dart';

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
      await _secureStorage.delete(key: 'authToken');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Você saiu da sua conta com sucesso.'),
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
        SnackBar(
          content: const Text('Erro ao sair da conta. Tente novamente.'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configurações',
          style: TextStyle(fontSize: 20.sp),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: FadeTransition(
        opacity:
            _isLoggingOut ? _fadeAnimation : const AlwaysStoppedAnimation(1),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Opção de Acessibilidade
              ListTile(
                title: Text(
                  'Acessibilidade',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                leading: Icon(Icons.accessibility_new, color: Colors.blueAccent),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccessibilityScreen(),
                    ),
                  );
                },
              ),
              const Divider(),

              // Adicionar opção de Privacidade
              ListTile(
                title: Text(
                  'Privacidade',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                leading: Icon(Icons.privacy_tip, color: Colors.blueAccent),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyScreen(),
                    ),
                  );
                },
              ),
              const Divider(),

              // Opção para o botão de Suporte ao Usuário
              ListTile(
                title: Text(
                  'Suporte ao Usuário',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                leading: Icon(Icons.help_outline, color: Colors.blueAccent),
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
                title: Text(
                  'Sair da Conta',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Sair da Conta',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
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
                            child: Text(
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
