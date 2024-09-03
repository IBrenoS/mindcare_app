import 'package:flutter/material.dart';
import './screens/home/home_screen.dart'; // Importe a tela Home
import './screens/login/login_screen.dart'; // Importe a tela de Login
import './screens/register/register_screen.dart'; // Importe a tela de Registro
import './screens/password_recovery/password_recovery_screen.dart'; // Importe a tela de Recuperação de Senha
import './screens/onboarding/onboarding_screen.dart'; // Importe a tela de Onboarding

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu Aplicativo',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute:
          '/login', // Define a tela inicial (pode ser /onboarding se preferir)
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/password-recovery': (context) => PasswordRecoveryScreen(),
        '/onboarding': (context) => OnboardingScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
