import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  // Chave para salvar a preferência do tema no SharedPreferences
  static const String _themeKey = 'isDarkTheme';

  // Define o tema inicial como claro
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  // Construtor para carregar o tema salvo na inicialização
  ThemeProvider() {
    _loadTheme();
  }

  // Alterna entre os temas claro e escuro
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _saveTheme(isDark);
    notifyListeners();
  }

  // Carrega o tema salvo do SharedPreferences
  Future<void> _loadTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isDark =
        prefs.getBool(_themeKey) ?? false; // Padrão é tema claro
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Salva a escolha do tema no SharedPreferences
  Future<void> _saveTheme(bool isDark) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }
}
