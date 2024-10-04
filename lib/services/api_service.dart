import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class AuthToken {
  final String value;
  AuthToken(this.value);
}

class Endpoint {
  final String value;
  Endpoint(this.value);
}

class ApiService {
  final String baseUrl =
      "https://mindcare-bb0ea3046931.herokuapp.com"; // URL do seu backend
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? currentUserId; // Armazena o ID do usuário logado

  // Função para recuperar o token de autenticação do armazenamento seguro
  Future<AuthToken> _getToken() async {
    String? token = await _secureStorage.read(key: 'authToken');
    return AuthToken(token ?? '');
  }

  // Função genérica para requisição GET
  Future<http.Response> getRequest(Endpoint endpoint) async {
    final url = Uri.parse('$baseUrl${endpoint.value}');
    try {
      final response = await http.get(url);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Função genérica para requisição GET com autenticação
  Future<http.Response> getRequestWithAuth(
      Endpoint endpoint, AuthToken token) async {
    final url = Uri.parse('$baseUrl${endpoint.value}');

    if (token.value.isEmpty) {
      return http.Response('{"msg":"Acesso negado. Sem token."}', 401);
    }

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer ${token.value}',
        'Content-Type': 'application/json',
      });

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Função genérica para requisição POST
  Future<http.Response> postRequest(
      Endpoint endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl${endpoint.value}');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Função genérica para requisição POST com autenticação
  Future<http.Response> postRequestWithAuth(
      Endpoint endpoint, Map<String, dynamic> data, AuthToken token) async {
    final url = Uri.parse(
        '${baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'}${endpoint.value.startsWith('/') ? endpoint.value.substring(1) : endpoint.value}');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${token.value}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(data),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

 Future<Map<String, dynamic>> getNearbySupportPoints({
    required double latitude,
    required double longitude,
    List<String>? queries,
    int page = 1,
    int limit = 20,
    String? type,
    String? sortBy,
  }) async {
    // Construir os parâmetros da query string
    Map<String, String> queryParams = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (queries != null && queries.isNotEmpty) {
      queryParams['query'] = queries.join(',');
    } else {
      queryParams['query'] = 'CRAS,Clínicas de Saúde Mental';
    }

    if (type != null) {
      queryParams['type'] = type;
    }

    if (sortBy != null) {
      queryParams['sortBy'] = sortBy;
    }

    final uri =
        Uri.parse('$baseUrl/geo/nearby').replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        print('Resposta recebida: ${response.body}');
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        print('Erro: ${response.statusCode}');
        throw Exception('Falha ao carregar pontos de apoio');
      }
    } catch (e) {
      print('Erro ao buscar pontos de apoio: $e');
      rethrow;
    }
  }

  // Função para buscar postagens com paginação
  Future<List<dynamic>> fetchPosts(int page, int limit) async {
    final token = await _getToken();
    final response = await getRequestWithAuth(
        Endpoint('/community/posts?page=$page&limit=$limit'), token);

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final data = jsonDecode(response.body);
      return data['posts'];
    } else {
      throw Exception('Erro ao carregar postagens.');
    }
  }

  // Função atualizada para lidar com o envio de imagens de forma mais robusta
  Future<void> createPostWithImage(String content, File? image) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/community/createPost');

    try {
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer ${token.value}';

      // Adiciona a legenda como campo obrigatório
      request.fields['content'] = content;

      // Verifica se a imagem foi fornecida e adiciona ao request
      if (image != null) {
        final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
        final mimeParts = mimeType.split('/');

        final imageFile = await http.MultipartFile.fromPath(
          'image', // Certifique-se de que este campo corresponde ao backend
          image.path,
          contentType: MediaType(mimeParts[0], mimeParts[1]),
        );
        request.files.add(imageFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Verificação de sucesso na criação da postagem
      if (response.statusCode != 201) {
        throw Exception('Erro ao criar postagem: ${response.body}');
      }
    } catch (e) {
      print('Erro ao enviar imagem: $e');
      throw Exception(
          'Erro ao criar postagem.'); // Retorna o erro para o frontend
    }
  }

  // Função para curtir uma postagem
  Future<void> likePost(String postId) async {
    final token = await _getToken();
    final response = await postRequestWithAuth(
        Endpoint('/community/likePost'),
        {
          'postId': postId,
        },
        token);

    if (response.statusCode != 200) {
      throw Exception('Erro ao curtir postagem.');
    }
  }

  // Função para descurtir uma postagem
  Future<void> unlikePost(String postId) async {
    final token = await _getToken();
    final response = await postRequestWithAuth(
      Endpoint('/community/unlikePost'),
      {'postId': postId},
      token,
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao remover curtida.');
    }
  }

  // Função para adicionar um comentário a uma postagem
  Future<void> addComment(String postId, String comment) async {
    if (comment.isEmpty) {
      return;
    }

    final token = await _getToken();
    final response = await postRequestWithAuth(
        Endpoint('/community/addComment'),
        {
          'postId': postId,
          'comment': comment,
        },
        token);

    if (response.statusCode != 200) {
      throw Exception('Erro ao adicionar comentário.');
    }
  }

  // Função para buscar o perfil do usuário logado
  Future<Map<String, dynamic>> fetchUserProfile() async {
    final token = await _getToken();
    final response = await getRequestWithAuth(Endpoint('/auth/profile'), token);

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final data = jsonDecode(response.body);
      currentUserId = data['id']; // Atualiza o ID do usuário logado
      return data;
    } else {
      throw Exception('Erro ao carregar perfil do usuário.');
    }
  }
}
