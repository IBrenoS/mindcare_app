import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0; // Para manter a aba selecionada no BottomNavigationBar
  final PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Bem-vindo',
          style: TextStyle(fontSize: 18.sp),
        ),
        backgroundColor: Colors.lightBlue.shade700,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carrossel de Conteúdo
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: SizedBox(
              height: 200.h,
              child: Stack(
                children: [
                  PageView(
                    controller: pageController,
                    children: const [
                      ContentCard(
                        imagePath: 'assets/images/meditation.png',
                        title: 'Meditações Guiadas',
                        description:
                            'Encontre paz com nossas meditações guiadas.',
                      ),
                      ContentCard(
                        imagePath: 'assets/images/check_in.png',
                        title: 'Check-ins Emocionais',
                        description:
                            'Registre como você está se sentindo hoje.',
                      ),
                      ContentCard(
                        imagePath: 'assets/images/diary.png',
                        title: 'Diário Pessoal',
                        description:
                            'Anote seus pensamentos e reflexões diárias.',
                      ),
                    ],
                  ),
                  // Indicador de página
                  Positioned(
                    bottom: 8.h,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: pageController,
                        count: 3,
                        effect: WormEffect(
                          dotHeight: 8.h,
                          dotWidth: 8.w,
                          activeDotColor: Colors.lightBlue.shade700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Botões de Acesso Rápido
          Padding(
            padding: EdgeInsets.all(16.w),
            child: GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
              ),
              children: [
                QuickAccessButton(
                  icon: Icons.self_improvement,
                  label: 'Meditações',
                  onPressed: () {
                    Navigator.pushNamed(context, '/meditacoes');
                  },
                ),
                QuickAccessButton(
                  icon: Icons.sentiment_satisfied_alt,
                  label: 'Check-ins',
                  onPressed: () {
                    Navigator.pushNamed(context, '/checkins');
                  },
                ),
                QuickAccessButton(
                  icon: Icons.book,
                  label: 'Diário',
                  onPressed: () {
                    Navigator.pushNamed(context, '/diario');
                  },
                ),
                QuickAccessButton(
                  icon: Icons.favorite,
                  label: 'Autocuidado',
                  onPressed: () {
                    Navigator.pushNamed(context, '/autocuidado');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
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
            icon: Icon(Icons.sentiment_satisfied_alt),
            label: 'Check-ins',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Diário',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        selectedItemColor: Colors.lightBlue.shade700,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, '/meditacoes');
              break;
            case 2:
              Navigator.pushNamed(context, '/checkins');
              break;
            case 3:
              Navigator.pushNamed(context, '/diario');
              break;
            case 4:
              Navigator.pushNamed(context, '/perfil');
              break;
          }
        },
      ),
    );
  }
}

class ContentCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const ContentCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r), // Borda responsiva
      ),
      elevation: 4.0,
      margin: EdgeInsets.symmetric(horizontal: 16.w), // Margin responsiva
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 100.h, // Altura responsiva
            fit: BoxFit.contain,
          ),
          SizedBox(height: 12.h), // Espaçamento responsivo
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp, // Tamanho do texto responsivo
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h), // Espaçamento responsivo
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp, // Tamanho do texto responsivo
            ),
          ),
        ],
      ),
    );
  }
}

class QuickAccessButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const QuickAccessButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(16.r), // Padding responsivo
        backgroundColor: Colors.lightBlue.shade700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r), // Borda responsiva
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36.sp, color: Colors.white), // Ícone responsivo
          SizedBox(height: 8.h), // Espaçamento responsivo
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp, // Tamanho do texto responsivo
            ),
          ),
        ],
      ),
    );
  }
}
