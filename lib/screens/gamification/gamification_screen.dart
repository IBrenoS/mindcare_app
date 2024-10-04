import 'package:flutter/material.dart';

class GamificationScreen extends StatelessWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Recompensas'),
        backgroundColor: Colors.lightBlue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seu Progresso:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildProgressBar(), // Função que constrói a barra de progresso
            const SizedBox(height: 30),
            const Text(
              'Desafios Disponíveis:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildChallengesList(), // Função que exibe a lista de desafios
          ],
        ),
      ),
    );
  }

  // Barra de progresso para indicar o nível ou pontos acumulados
  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nível 3', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: 0.7, // Exemplo de progresso (70%)
          backgroundColor: Colors.grey[300],
          color: Colors.lightBlue.shade700,
        ),
        const SizedBox(height: 10),
        const Text('70% para o próximo nível!', style: TextStyle(fontSize: 16)),
      ],
    );
  }

  // Lista de desafios que o usuário pode completar
  Widget _buildChallengesList() {
    final challenges = [
      {'title': 'Registrar humor por 7 dias consecutivos', 'points': 50},
      {'title': 'Fazer check-in diário por 3 dias', 'points': 30},
      {'title': 'Concluir 5 meditações', 'points': 40},
    ];

    return Expanded(
      child: ListView.builder(
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          final challenge = challenges[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              title: Text(challenge['title'] as String),
              trailing: Text('+${challenge['points']} pontos'),
              onTap: () {
                // SINAL DE ATENÇÃO: Integração para completar desafios e aumentar a pontuação
              },
            ),
          );
        },
      ),
    );
  }
}
