import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  // Chave para salvar a preferência do tema no SharedPreferences
  static const String _themeKey = 'isDarkTheme';

  // Define o tema inicial como claro
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  // Chave para salvar a escala da fonte
  static const String _fontScaleKey = 'fontScale';

  // Valor padrão da escala da fonte
  double _fontScale = 1.0;

  // Getter para obter o valor atual da escala da fonte
  double get fontScale => _fontScale;

  // Construtor atualizado para carregar tanto o tema quanto a escala da fonte
  ThemeProvider() {
    _loadTheme();
    _loadFontScale();
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

  // Método para definir nova escala de fonte
  Future<void> setFontScale(double scale) async {
    _fontScale = scale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontScaleKey, scale);
    notifyListeners();
  }

  // Método para carregar a escala da fonte salva
  Future<void> _loadFontScale() async {
    final prefs = await SharedPreferences.getInstance();
    _fontScale = prefs.getDouble(_fontScaleKey) ?? 1.0;
    notifyListeners();
  }
}
