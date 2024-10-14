import 'dart:convert';
import 'dart:io';
import 'dart:async'; // Para TimeoutException
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:logger/logger.dart';

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
  final logger = Logger();

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
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      return response;
    } on SocketException {
      throw Exception('Falha na conexão. Verifique sua internet.');
    } on TimeoutException {
      throw Exception(
          'Tempo de resposta esgotado. Tente novamente mais tarde.');
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
      }).timeout(const Duration(seconds: 10));
      return response;
    } on SocketException {
      throw Exception('Falha na conexão. Verifique sua internet.');
    } on TimeoutException {
      throw Exception(
          'Tempo de resposta esgotado. Tente novamente mais tarde.');
    } catch (e) {
      rethrow;
    }
  }

  // Função genérica para requisição POST
  Future<http.Response> postRequest(
      Endpoint endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl${endpoint.value}');
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));
      return response;
    } on SocketException {
      throw Exception('Falha na conexão. Verifique sua internet.');
    } on TimeoutException {
      throw Exception(
          'Tempo de resposta esgotado. Tente novamente mais tarde.');
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
      final response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer ${token.value}',
              'Content-Type': 'application/json'
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));
      return response;
    } on SocketException {
      throw Exception('Falha na conexão. Verifique sua internet.');
    } on TimeoutException {
      throw Exception(
          'Tempo de resposta esgotado. Tente novamente mais tarde.');
    } catch (e) {
      rethrow;
    }
  }

  // Função genérica para requisição PUT com autenticação
  Future<http.Response> putRequestWithAuth(
      Endpoint endpoint, Map<String, dynamic> data, AuthToken token) async {
    final url = Uri.parse('$baseUrl${endpoint.value}');
    try {
      final response = await http
          .put(
            url,
            headers: {
              'Authorization': 'Bearer ${token.value}',
              'Content-Type': 'application/json'
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));
      return response;
    } on SocketException {
      throw Exception('Falha na conexão. Verifique sua internet.');
    } on TimeoutException {
      throw Exception(
          'Tempo de resposta esgotado. Tente novamente mais tarde.');
    } catch (e) {
      rethrow;
    }
  }

  // Função genérica para requisição DELETE com autenticação
  Future<http.Response> deleteRequestWithAuth(
      Endpoint endpoint, AuthToken token) async {
    final url = Uri.parse('$baseUrl${endpoint.value}');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer ${token.value}',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      return response;
    } on SocketException {
      throw Exception('Falha na conexão. Verifique sua internet.');
    } on TimeoutException {
      throw Exception(
          'Tempo de resposta esgotado. Tente novamente mais tarde.');
    } catch (e) {
      rethrow;
    }
  }

  // Função para buscar pontos de apoio próximos
  Future<Map<String, dynamic>> getNearbySupportPoints({
    required double latitude,
    required double longitude,
    List<String>? queries,
    int page = 1,
    int limit = 20,
    String? type,
    String? sortBy,
  }) async {
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
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        logger.i('Resposta recebida: ${response.body}');
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        logger.e('Erro: ${response.statusCode}');
        throw Exception('Falha ao carregar pontos de apoio');
      }
    } on SocketException {
      throw Exception('Falha na conexão. Verifique sua internet.');
    } on TimeoutException {
      throw Exception(
          'Tempo de resposta esgotado. Tente novamente mais tarde.');
    } catch (e) {
      logger.e('Erro ao buscar pontos de apoio: $e');
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

  // Função para enviar post com imagem
  Future<void> createPostWithImage(String content, File? image) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/community/createPost');

    try {
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer ${token.value}';

      request.fields['content'] = content;

      if (image != null) {
        final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';
        final mimeParts = mimeType.split('/');

        final imageFile = await http.MultipartFile.fromPath(
          'image',
          image.path,
          contentType: MediaType(mimeParts[0], mimeParts[1]),
        );
        request.files.add(imageFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 201) {
        throw Exception('Erro ao criar postagem: ${response.body}');
      }
    } catch (e) {
      logger.e('Erro ao enviar imagem: $e');
      throw Exception('Erro ao criar postagem.');
    }
  }

  // Função para curtir uma postagem
  Future<void> likePost(String postId) async {
    final token = await _getToken();
    final response = await postRequestWithAuth(
        Endpoint('/community/likePost'), {'postId': postId}, token);

    if (response.statusCode != 200) {
      throw Exception('Erro ao curtir postagem.');
    }
  }

  // Função para descurtir uma postagem
  Future<void> unlikePost(String postId) async {
    final token = await _getToken();
    final response = await postRequestWithAuth(
        Endpoint('/community/unlikePost'), {'postId': postId}, token);

    if (response.statusCode != 200) {
      throw Exception('Erro ao remover curtida.');
    }
  }

  // Função para adicionar comentário a uma postagem
  Future<void> addComment(String postId, String comment) async {
    if (comment.isEmpty) return;

    final token = await _getToken();
    final response = await postRequestWithAuth(
        Endpoint('/community/addComment'),
        {'postId': postId, 'comment': comment},
        token);

    if (response.statusCode != 200) {
      throw Exception('Erro ao adicionar comentário.');
    }
  }

  // Função para criar uma nova entrada no Diário de Humor
  Future<void> createDiaryEntry(String moodEmoji, String entry) async {
    final token = await _getToken();
    final response = await postRequestWithAuth(
      Endpoint('/diary/entries'),
      {
        'moodEmoji': moodEmoji,
        'entry': entry,
      },
      token,
    );

    if (response.statusCode != 201) {
      logger.e('Erro ao criar entrada: ${response.body}');
      throw Exception('Erro ao criar entrada no diário de humor.');
    }
  }

  // Função para buscar entradas de humor com filtros (daily, weekly, monthly)
  Future<Map<String, dynamic>> fetchDiaryEntries(String filter,
      {int page = 1, int limit = 10}) async {
    final token = await _getToken();

    // Construir os parâmetros de consulta
    Map<String, String> queryParams = {
      'filter': filter,
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final uri =
        Uri.parse('$baseUrl/diary/entries').replace(queryParameters: queryParams);

    final response =
        await getRequestWithAuth(Endpoint(uri.path + '?' + uri.query), token);

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } else {
      logger.e('Erro ao carregar entradas: ${response.body}');
      throw Exception('Erro ao carregar entradas do diário de humor.');
    }
  }

  // Função para obter uma entrada específica do Diário de Humor
  Future<Map<String, dynamic>> fetchDiaryEntryById(String entryId) async {
    final token = await _getToken();
    final response =
        await getRequestWithAuth(Endpoint('/diary/entries/$entryId'), token);

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } else if (response.statusCode == 404) {
      throw Exception('Entrada não encontrada.');
    } else {
      logger.e('Erro ao carregar a entrada: ${response.body}');
      throw Exception('Erro ao carregar a entrada do diário de humor.');
    }
  }

  // Função para atualizar uma entrada existente no Diário de Humor
  Future<void> updateDiaryEntry(String entryId,
      {String? moodEmoji, String? entry}) async {
    final token = await _getToken();

    // Construir o corpo da requisição com os campos atualizados
    Map<String, dynamic> data = {};
    if (moodEmoji != null) data['moodEmoji'] = moodEmoji;
    if (entry != null) data['entry'] = entry;

    if (data.isEmpty) {
      throw Exception('Nada para atualizar.');
    }

    final response = await putRequestWithAuth(
      Endpoint('/diary/entries/$entryId'),
      data,
      token,
    );

    if (response.statusCode != 200) {
      logger.e('Erro ao atualizar a entrada: ${response.body}');
      throw Exception('Erro ao atualizar a entrada do diário de humor.');
    }
  }

  // Função para deletar uma entrada do Diário de Humor
  Future<void> deleteDiaryEntry(String entryId) async {
    final token = await _getToken();
    final response =
        await deleteRequestWithAuth(Endpoint('/diary/entries/$entryId'), token);

    if (response.statusCode != 200) {
      logger.e('Erro ao deletar a entrada: ${response.body}');
      throw Exception('Erro ao deletar a entrada do diário de humor.');
    }
  }

  // Função para buscar o perfil do usuário logado
  Future<Map<String, dynamic>> fetchUserProfile() async {
    final token = await _getToken();
    final response = await getRequestWithAuth(Endpoint('/auth/profile'), token);

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final data = jsonDecode(response.body);
      currentUserId = data['id'];
      return data;
    } else {
      throw Exception('Erro ao carregar perfil do usuário.');
    }
  }
}
