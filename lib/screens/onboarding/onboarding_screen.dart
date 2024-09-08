import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Importando flutter_screenutil

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Widget> _onboardingSlides = [
    const OnboardingSlide(
      imageAsset: 'assets/images/meditation.png',
      title: 'Meditações Guiadas',
      description: 'Aproveite meditações para relaxar e acalmar sua mente.',
    ),
    const OnboardingSlide(
      imageAsset: 'assets/images/mental_health.png',
      title: 'Check-ins Emocionais',
      description: 'Registre como você se sente diariamente.',
    ),
    const OnboardingSlide(
      imageAsset: 'assets/images/writing.png',
      title: 'Diário Pessoal',
      description: 'Anote seus pensamentos e reflexões.',
    ),
  ];

  void _onNextPage() {
    if (_currentPage < _onboardingSlides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      // Redirecionar para a tela de registro/login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _onSkip() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _onboardingSlides.length,
              itemBuilder: (context, index) {
                return _onboardingSlides[index];
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _onboardingSlides.length,
              (index) => _buildPageIndicator(index),
            ),
          ),
          SizedBox(height: 20.h), // Espaçamento adaptado
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w), // Padding adaptado
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _onSkip,
                  child: Text(
                    'Pular',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.sp), // Tamanho de fonte adaptado
                  ),
                ),
                ElevatedButton(
                  onPressed: _onNextPage,
                  child: Text(
                    _currentPage == _onboardingSlides.length - 1
                        ? 'Começar'
                        : 'Próximo',
                    style: TextStyle(fontSize: 16.sp), // Fonte adaptada
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h), // Espaçamento adaptado
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w), // Margem adaptada
      width: _currentPage == index ? 12.w : 8.w, // Largura adaptada
      height: _currentPage == index ? 12.h : 8.h, // Altura adaptada
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.blue : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}

class OnboardingSlide extends StatelessWidget {
  final String imageAsset;
  final String title;
  final String description;

  const OnboardingSlide({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w), // Padding adaptado
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imageAsset,
            height: 200.h, // Altura da imagem adaptada
            fit: BoxFit.contain,
          ),
          SizedBox(height: 20.h), // Espaçamento adaptado
          Text(
            title,
            style: TextStyle(
              fontSize: 24.sp, // Tamanho da fonte adaptado
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.h), // Espaçamento adaptado
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp, // Tamanho da fonte adaptado
            ),
          ),
        ],
      ),
    );
  }
}
