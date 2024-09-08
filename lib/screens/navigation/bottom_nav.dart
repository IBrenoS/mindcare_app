import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex; // Index atual (útil para mudar o estado de fora)
  final Function(int)
      onTap; // Função que será chamada quando o item for clicado

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex, // Gerencia qual aba está selecionada
      selectedItemColor: Colors.lightBlue.shade700, // Cor do item selecionado
      unselectedItemColor: Colors.grey, // Cor do item não selecionado
      type: BottomNavigationBarType.fixed, // Fixado para 5 ou menos itens
      onTap: widget.onTap, // Função que será passada para os outros widgets
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
    );
  }
}
