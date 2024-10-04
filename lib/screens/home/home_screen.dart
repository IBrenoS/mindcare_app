import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mindcare_app/screens/community/community_screen.dart';
import 'package:mindcare_app/screens/exercises/exercises_screen.dart';
import 'package:mindcare_app/screens/map/map_screen.dart';
import 'package:mindcare_app/screens/diary/diary_screen.dart';
import 'package:mindcare_app/screens/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Lista de páginas para exibição dentro do IndexedStack
  final List<Widget> _pages = [
    Container(color: Colors.white), // Tela Home vazia por enquanto
    ExercisesScreen(), // Tela de meditação ou exercícios
    MapScreen(), // Tela do mapa substituindo gamificação
    DiaryScreen(), // Tela de diário
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
    final theme = Theme.of(context); // Captura o tema atual para uso

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor, // Usa a cor primária do tema
        title: Text(
          'Olá, [Nome]!',
          style: theme.textTheme.bodyLarge!
              .copyWith(fontSize: 18.sp), // Aplica o tema ao texto
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            color: theme.iconTheme.color, // Usa a cor do ícone do tema
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
    final theme = Theme.of(context); // Captura o tema atual

    return BottomNavigationBar(
      backgroundColor: theme.bottomNavigationBarTheme
          .backgroundColor, // Usa a cor de fundo do tema
      selectedItemColor: theme.bottomNavigationBarTheme
          .selectedItemColor, // Cor dos itens selecionados
      unselectedItemColor: theme.bottomNavigationBarTheme
          .unselectedItemColor, // Cor dos itens não selecionados
      selectedFontSize: 14.sp,
      unselectedFontSize: 12.sp,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed, // Mantém a barra de navegação fixa
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.self_improvement),
          label: 'Meditações',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map), // Ícone que representa o mapa
          label: 'Mapa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book),
          label: 'Diário',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline), // Ícone de balão de diálogo
          label: 'Comunidade',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}
