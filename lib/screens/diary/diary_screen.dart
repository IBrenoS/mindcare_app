import 'package:fl_chart/fl_chart.dart'; // Para gráficos de barras
import 'package:flutter/material.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário de Humor'),
        backgroundColor: Colors.lightBlue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumo de Humor',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildMoodChart(), // Função para construir o gráfico de barras

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // SINAL DE ATENÇÃO: Integração para adicionar nova entrada de humor
              },
              child: const Text('Adicionar Nova Entrada'),
            ),
          ],
        ),
      ),
    );
  }

  // Função que constrói o gráfico de barras
  Widget _buildMoodChart() {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
                x: 0, barRods: [BarChartRodData(toY: 3, color: Colors.green)]),
            BarChartGroupData(
                x: 1, barRods: [BarChartRodData(toY: 4, color: Colors.blue)]),
            BarChartGroupData(
                x: 2, barRods: [BarChartRodData(toY: 2, color: Colors.orange)]),
            BarChartGroupData(
                x: 3, barRods: [BarChartRodData(toY: 5, color: Colors.red)]),
          ],
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text('Seg');
                    case 1:
                      return const Text('Ter');
                    case 2:
                      return const Text('Qua');
                    case 3:
                      return const Text('Qui');
                    default:
                      return const Text('');
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
