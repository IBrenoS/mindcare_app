import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mindcare_app/services/api_service.dart';

class DiarioHumorScreen extends StatefulWidget {
  @override
  _DiarioHumorScreenState createState() => _DiarioHumorScreenState();
}

class _DiarioHumorScreenState extends State<DiarioHumorScreen> {
  final TextEditingController _entryController = TextEditingController();
  String _selectedEmoji = '';
  bool _isLoading = false;
  bool _isRegistered = false;
  List<Map<String, dynamic>> _entradas = [];
  bool _isFetchingMore = false;
  int _page = 1;
  final int _limit = 5;
  ApiService apiService = ApiService();

  final List<String> emojis = ['😀', '😁', '🥹', '😔', '😡', '😫'];

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  void _registrarHumor() async {
    if (_selectedEmoji.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selecione um emoji que representa seu humor")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await apiService.createDiaryEntry(_selectedEmoji, _entryController.text);
      setState(() {
        _isRegistered = true;
        _page = 1;
      });
      _carregarHistorico();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text("Entrada de humor registrada com sucesso!"),
            ],
          ),
        ),
      );
      _entryController.clear();
      setState(() {
        _selectedEmoji = '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao registrar entrada: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
        Future.delayed(Duration(seconds: 2), () {
          setState(() {
            _isRegistered = false;
          });
        });
      });
    }
  }

  void _carregarHistorico() async {
    setState(() {
      _isFetchingMore = true;
    });

    try {
      List<Map<String, dynamic>> novasEntradas = await apiService
          .fetchDiaryEntries('daily', page: _page, limit: _limit);
      setState(() {
        _entradas = novasEntradas;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao carregar histórico: $e")),
      );
    } finally {
      setState(() {
        _isFetchingMore = false;
      });
    }
  }

  String formatarData(DateTime data) {
    return DateFormat.yMMMMd().format(data);
  }

  String formatarHora(DateTime data) {
    return DateFormat.Hm().format(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Diário de Humor")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Como você está se sentindo?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              // Scroll horizontal para emojis
              Container(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: emojis.length,
                  itemBuilder: (context, index) {
                    final emoji = emojis[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedEmoji = emoji;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _selectedEmoji == emoji
                              ? Colors.blue
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          emoji,
                          style: TextStyle(fontSize: 32),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),

              // Campo de texto para descrever o humor
              TextField(
                controller: _entryController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Descreva seu humor (opcional)",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),

              // Botão "Registrar Humor" com largura ajustada
              Center(
                child: SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registrarHumor,
                    child: _isLoading
                        ? SpinKitCircle(color: Colors.white, size: 30)
                        : Text("Registrar Humor"),
                  ),
                ),
              ),
              SizedBox(height: 20),

              _isRegistered
                  ? AnimatedOpacity(
                      opacity: _isRegistered ? 1.0 : 0.0,
                      duration: Duration(seconds: 1),
                      child: Text(
                        "Humor registrado com sucesso!",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Container(),

              Divider(),
              Text(
                "Histórico de Humor",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              // Histórico de humor com botões ajustados
              _entradas.isEmpty
                  ? Center(child: Text("Nenhum registro encontrado."))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _entradas.length,
                      itemBuilder: (context, index) {
                        final entrada = _entradas[index];
                        final DateTime createdAt =
                            DateTime.parse(entrada['createdAt']);
                        final String moodEmoji = entrada['moodEmoji'];
                        final String texto = entrada['entry'];

                        return ListTile(
                          leading:
                              Text(moodEmoji, style: TextStyle(fontSize: 32)),
                          title: Text(texto),
                          subtitle:
                              Text("Registrado às ${formatarHora(createdAt)}"),
                          trailing: Text(formatarData(createdAt)),
                        );
                      },
                    ),

              Center(
                child: SizedBox(
                  width: 200,
                  child: _isFetchingMore
                      ? SpinKitCircle(color: Colors.blue, size: 30)
                      : ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _page++;
                            });
                            _carregarHistorico();
                          },
                          child: Text("Carregar Mais"),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
