import 'package:flutter/material.dart';
import 'package:mindcare_app/services/api_service.dart';
import 'dart:convert';
import 'package:mindcare_app/screens/exercises/videoPlayer_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExercisesScreen extends StatefulWidget {
  @override
  _ExercisesScreenState createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  final ApiService _apiService = ApiService(); // Instância do serviço de API
  List<dynamic> _videos = []; // Lista completa de vídeos
  List<dynamic> _filteredVideos =
      []; // Lista para armazenar os vídeos filtrados
  String _selectedCategory = ''; // Categoria selecionada para filtragem
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVideos(); // Carregar vídeos ao iniciar
  }

  Future<void> _fetchVideos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _apiService.getApprovedVideos();

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _videos = data['data']; // Armazena todos os vídeos
          _filteredVideos = _videos; // Inicialmente, exibe todos os vídeos
        });
      } else {
        throw Exception('Erro ao buscar vídeos: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erro ao carregar vídeos.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onError,
                ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Função para filtrar vídeos pela categoria selecionada
  void _filterVideosByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category.isEmpty) {
        _filteredVideos = _videos; // Exibe todos os vídeos se não houver filtro
      } else {
        _filteredVideos = _videos
            .where((video) => video['category'] == category)
            .toList(); // Filtra os vídeos por categoria
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Exercícios de Meditação',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : _filteredVideos.isNotEmpty
                    ? ListView.builder(
                        itemCount: _filteredVideos.length,
                        itemBuilder: (context, index) {
                          return _buildVideoCard(
                            context,
                            _filteredVideos[index]['title'],
                            _filteredVideos[index]['description'],
                            _filteredVideos[index]['thumbnail'],
                            _filteredVideos[index]['category'],
                            _filteredVideos[index]
                                ['url'], // Passa a URL do vídeo
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          "Nenhum vídeo encontrado",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  // Widget para exibir as opções de categoria
  Widget _buildCategoryFilter() {
    final categories = ['Todos', 'Meditação', 'Relaxamento', 'Saúde'];
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0.h), // Responsive padding
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            return GestureDetector(
              onTap: () {
                _filterVideosByCategory(category == 'Todos' ? '' : category);
              },
              child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: 8.0.w), // Responsive margin
                padding: EdgeInsets.symmetric(
                    horizontal: 12.0.w, vertical: 8.0.h), // Responsive padding
                decoration: BoxDecoration(
                  color: _selectedCategory == category
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Text(
                  category,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _selectedCategory == category
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Widget para construir cada card de vídeo
  Widget _buildVideoCard(BuildContext context, String title, String description,
      String thumbnailUrl, String category, String videoUrl) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: 8.0.h, horizontal: 16.0.w), // Responsive padding
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(videoUrl: videoUrl),
            ),
          ).then((_) {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
            ]);
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail do vídeo
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(8.r), // Responsive border radius
              child: Image.network(
                thumbnailUrl,
                width: double.infinity,
                height: 200.h, // Responsive height
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.broken_image, size: 100),
              ),
            ),
            SizedBox(height: 8.h), // Responsive spacing
            // Informações do vídeo (Título e categoria)
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: 8.0.w), // Responsive padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h), // Responsive spacing
                  Text(
                    category,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  SizedBox(height: 4.h), // Responsive spacing
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Divider(
              color: Theme.of(context).colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}
