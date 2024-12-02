import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mindcare_app/screens/community/community_screen.dart';
import 'package:mindcare_app/screens/exercises/exercises_screen.dart';
import 'package:mindcare_app/screens/map/map_screen.dart';
import 'package:mindcare_app/screens/diary/diarioHumor_screen.dart';
import 'package:mindcare_app/screens/profile/profile_screen.dart';
import 'package:mindcare_app/screens/content/educationalContent_screen.dart';
import 'package:mindcare_app/services/api_service.dart';
import 'package:mindcare_app/utils/text_scale_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String userName = '';
  String greeting = '';
  final ApiService _apiService = ApiService();
  Timer? _timer;

  final List<Widget> _pages = [
    EducationalContentScreen(),
    ExercisesScreen(),
    MapScreen(),
    DiarioHumorScreen(),
    CommunityScreen(),
    UserProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _updateGreeting();
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      _updateGreeting();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profileData = await _apiService.fetchUserProfile();
      setState(() {
        userName = profileData['name'] ?? 'Usuário';
      });
    } catch (e) {
      print('Erro ao carregar o perfil do usuário: $e');
    }
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    setState(() {
      if (hour >= 6 && hour < 12) {
        greeting = 'Bom dia ☀️';
      } else if (hour >= 12 && hour < 18) {
        greeting = 'Boa tarde 🌞';
      } else if (hour >= 18 && hour < 24) {
        greeting = 'Boa noite 🌜';
      } else {
        greeting = 'Boa madrugada 🌌';
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: ScaledText(
          '$greeting, $userName!',
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

  Widget _buildBottomNavigationBar(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: Theme.of(context).copyWith(
        // Isso garante que os labels do BottomNavigationBar também escalarão
        textTheme: Theme.of(context).textTheme.copyWith(
          bodySmall: TextStyle(fontSize: 12.sp),
        ),
      ),
      child: BottomNavigationBar(
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
      ),
    );
  }
}
