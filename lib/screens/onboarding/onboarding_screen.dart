import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Widget> _onboardingSlides = [
    OnboardingSlide(
      imageAsset: 'assets/images/meditation.png',
      title: 'Meditações Guiadas',
      description: 'Aproveite meditações para relaxar e acalmar sua mente.',
    ),
    OnboardingSlide(
      imageAsset: 'assets/images/check_in.png',
      title: 'Check-ins Emocionais',
      description: 'Registre como você se sente diariamente.',
    ),
    OnboardingSlide(
      imageAsset: 'assets/images/diary.png',
      title: 'Diário Pessoal',
      description: 'Anote seus pensamentos e reflexões.',
    ),
  ];

  void _onNextPage() {
    if (_currentPage < _onboardingSlides.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
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
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _onSkip,
                  child: Text(
                    'Pular',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: _onNextPage,
                  child: Text(
                    _currentPage == _onboardingSlides.length - 1
                        ? 'Começar'
                        : 'Próximo',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      width: _currentPage == index ? 12.0 : 8.0,
      height: _currentPage == index ? 12.0 : 8.0,
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
    required this.imageAsset,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imageAsset,
            height: 200.0,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    );
  }
}
