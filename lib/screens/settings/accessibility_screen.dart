import 'package:flutter/material.dart';
import 'package:mindcare_app/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mindcare_app/theme/theme_provider.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Acessibilidade',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção de Tema
            _buildSectionTitle(context, 'Tema'),
            SizedBox(height: 10.h),
            _buildDarkModeSwitch(context, themeProvider),

            const Divider(),

            // Seção de Tamanho da Fonte
            _buildSectionTitle(context, 'Tamanho da Fonte'),
            SizedBox(height: 10.h),
            _buildFontSizeSlider(context, themeProvider),

            const Divider(),

            // Exemplo de texto com o tamanho atual
            SizedBox(height: 20.h),
            Text(
              'Exemplo de texto',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16.sp * themeProvider.fontScale,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Título de Seção
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onBackground,
          ),
    );
  }

  /// Switch para alternar entre tema claro e escuro
  Widget _buildDarkModeSwitch(
      BuildContext context, ThemeProvider themeProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Modo Escuro',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        Switch(
          value: themeProvider.themeMode == ThemeMode.dark,
          onChanged: (value) {
            themeProvider.toggleTheme(value);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  value ? 'Modo escuro ativado' : 'Modo claro ativado',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary),
                ),
                backgroundColor: successColorLight,
              ),
            );
          },
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  /// Slider para ajustar o tamanho da fonte
  Widget _buildFontSizeSlider(
      BuildContext context, ThemeProvider themeProvider) {
    return Column(
      children: [
        Slider(
          value: themeProvider.fontScale,
          min: 0.8,
          max: 1.4,
          divisions: 3,
          label: _getFontSizeLabel(themeProvider.fontScale),
          onChanged: (value) {
            themeProvider.setFontScale(value);
          },
          activeColor: Theme.of(context).colorScheme.primary,
          inactiveColor: Theme.of(context).colorScheme.surfaceVariant,
        ),
        Center(
          child: Text(
            _getFontSizeLabel(themeProvider.fontScale),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ),
      ],
    );
  }

  /// Rótulos para o tamanho da fonte
  String _getFontSizeLabel(double scale) {
    if (scale <= 0.8) return 'Pequeno';
    if (scale <= 1.0) return 'Normal';
    if (scale <= 1.2) return 'Grande';
    return 'Muito Grande';
  }
}
