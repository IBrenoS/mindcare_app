import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Importando flutter_screenutil

import './screens/home/home_screen.dart'; // Importe a tela Home
import './screens/login/login_screen.dart'; // Importe a tela de Login
import './screens/onboarding/onboarding_screen.dart'; // Importe a tela de Onboarding
import './screens/password_recovery/password_recovery_screen.dart'; // Importe a tela de Recuperação de Senha
import './screens/register/register_screen.dart'; // Importe a tela de Registro

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize:
          const Size(360, 800), // Definindo a base de referência para Android
      minTextAdapt: true, // Adapta o tamanho do texto
      splitScreenMode: true, // Suporte ao modo de tela dividida
      builder: (context, child) {
        return MaterialApp(
          title: 'MindCare',
          theme: ThemeData(
            primarySwatch: Colors.lightBlue,
            fontFamily: 'Poppins', // Aplica Poppins globalmente
            textTheme: TextTheme(
              bodyLarge: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.normal), // Tamanho de fonte adaptado
              bodyMedium: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.normal), // Tamanho de fonte adaptado
              titleLarge: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold), // Títulos adaptados
              labelLarge: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600), // Botões adaptados
            ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          initialRoute:
              '/login', // Define a tela inicial (pode ser /onboarding se preferir)
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/password-recovery': (context) => PasswordRecoveryScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/home': (context) => HomeScreen(),
          },
        );
      },
    );
  }
}
