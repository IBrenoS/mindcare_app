import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Bem-vindo'),
        backgroundColor: Colors.lightBlue.shade700,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carrossel de Conteúdo
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: SizedBox(
              height: 200.0,
              child: PageView(
                children: [
                  ContentCard(
                    imagePath: 'assets/images/meditation.png',
                    title: 'Meditações Guiadas',
                    description: 'Encontre paz com nossas meditações guiadas.',
                  ),
                  ContentCard(
                    imagePath: 'assets/images/check_in.png',
                    title: 'Check-ins Emocionais',
                    description: 'Registre como você está se sentindo hoje.',
                  ),
                  ContentCard(
                    imagePath: 'assets/images/diary.png',
                    title: 'Diário Pessoal',
                    description: 'Anote seus pensamentos e reflexões diárias.',
                  ),
                ],
              ),
            ),
          ),
          // Botões de Acesso Rápido
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
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
          // Lógica de navegação entre as seções
          switch (index) {
            case 0:
              // já estamos na Home
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
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 100.0,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 12.0),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.0,
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
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(16.0),
        backgroundColor: Colors.lightBlue.shade700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36.0, color: Colors.white),
          SizedBox(height: 8.0),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }
}
