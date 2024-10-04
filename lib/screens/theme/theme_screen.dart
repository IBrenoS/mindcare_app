import 'package:flutter/material.dart';

// Definindo a cor de sucesso fora do ColorScheme
const Color successColor = Color(0xFF28A745); // Cor para sucesso
const Color bottomColor = Color.fromARGB(255, 2, 136, 209); // Cor para botões

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF3D5A80),
  scaffoldBackgroundColor: const Color(0xFFF2F5F8),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF3D5A80),
    secondary: Color(0xFF007AFF),
    surface: Color(0xFFF2F5F8),
    error: Color(0xFFE63946),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
        color: Color(0xFF293241), fontSize: 24, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(color: Color(0xFF293241), fontSize: 16),
    bodyMedium: TextStyle(color: Color(0xFF7B8794), fontSize: 14),
  ),
  cardColor: Colors.white,
  dividerColor: const Color(0xFFE0E4E8),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(
        0xFFFFFFFF), // Cor de fundo para o BottomNavigationBar no tema claro
    selectedItemColor: Color(0xFF3D5A80), // Cor dos itens selecionados
    unselectedItemColor: Color(0xFF7B8794), // Cor dos itens não selecionados
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF457B9D),
  scaffoldBackgroundColor: const Color(0xFF1D3557),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF457B9D),
    secondary: Color(0xFF98C1D9),
    surface: Color(0xFF1D3557),
    error: Color(0xFFE63946),
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
        color: Color(0xFFF1FAEE), fontSize: 24, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(color: Color(0xFFF1FAEE), fontSize: 16),
    bodyMedium: TextStyle(color: Color(0xFFA8DADC), fontSize: 14),
  ),
  cardColor: const Color(0xFF2C3E50),
  dividerColor: const Color(0xFF2C3E50),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(
        0xFF2C3E50), // Cor de fundo para o BottomNavigationBar no tema escuro
    selectedItemColor: Color(0xFF98C1D9), // Cor dos itens selecionados
    unselectedItemColor: Color(0xFFA8DADC), // Cor dos itens não selecionados
  ),
);
