import 'package:flutter/material.dart';
import 'package:mindcare_app/services/api_service.dart';
import 'dart:convert';
import 'package:mindcare_app/screens/exercises/videoPlayer_screen.dart';
import 'package:flutter/services.dart';

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
      print("Erro: ${e.toString()}");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Erro ao carregar vídeos.")));
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
        title: Text('Exercícios de Meditação'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: Colors.blueAccent))
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
                    : Center(child: Text("Nenhum vídeo encontrado")),
          ),
        ],
      ),
    );
  }

  // Widget para exibir as opções de categoria
  Widget _buildCategoryFilter() {
    final categories = ['Todos', 'Meditação', 'Relaxamento', 'Saúde'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            return GestureDetector(
              onTap: () {
                _filterVideosByCategory(category == 'Todos' ? '' : category);
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8.0),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedCategory == category
                      ? Colors.blueAccent
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: _selectedCategory == category
                        ? Colors.white
                        : Colors.black,
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
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: InkWell(
        onTap: () {
          // Usar Navigator.push normalmente para empilhar a tela de vídeo sobre a de Meditação
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(videoUrl: videoUrl),
            ),
          ).then((_) {
            // Redefine a orientação para retrato ao retornar
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
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                thumbnailUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.broken_image, size: 100),
              ),
            ),
            SizedBox(height: 8),
            // Informações do vídeo (Título e categoria)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
