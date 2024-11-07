import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mindcare_app/screens/community/community_screen.dart';
import 'package:mindcare_app/screens/exercises/exercises_screen.dart';
import 'package:mindcare_app/screens/map/map_screen.dart';
import 'package:mindcare_app/screens/diary/diarioHumor_screen.dart';
import 'package:mindcare_app/screens/profile/profile_screen.dart';
import 'package:mindcare_app/screens/content/educationalContent_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Lista de páginas para exibição dentro do IndexedStack
  final List<Widget> _pages = [
    EducationalContentScreen(), // Conteúdo educativo como nova Home
    ExercisesScreen(), // Tela de meditação ou exercícios
    MapScreen(), // Tela do mapa substituindo gamificação
    DiarioHumorScreen(), // Tela de diário
    CommunityScreen(), // Tela de comunidade
    UserProfileScreen(), // Tela de perfil do usuário
  ];

  // Função para alternar entre as páginas
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Captura o tema atual

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text(
          'Olá, [Nome]!', // Bem-vindo com nome do usuário
          style: theme.textTheme.headlineLarge!.copyWith(
            fontSize: 18.sp,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            color: theme.colorScheme.onPrimary,
            onPressed: () {
              // Lógica para abrir notificações
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // Função para construir a barra de navegação inferior
  Widget _buildBottomNavigationBar(BuildContext context) {
    final theme = Theme.of(context);

    return BottomNavigationBar(
      backgroundColor: theme.bottomNavigationBarTheme.backgroundColor ??
          theme.colorScheme.surface,
      selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor ??
          theme.colorScheme.primary,
      unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor ??
          theme.colorScheme.onSurface.withOpacity(0.7),
      selectedFontSize: 14.sp,
      unselectedFontSize: 12.sp,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.self_improvement),
          label: 'Meditações',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.map),
          label: 'Mapa',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.book),
          label: 'Diário',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.chat_bubble_outline),
          label: 'Comunidade',
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}
