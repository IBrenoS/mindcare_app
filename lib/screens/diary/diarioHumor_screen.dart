import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mindcare_app/services/api_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  final int _limit = 10;
  ApiService apiService = ApiService();

  final List<String> defaultEmojis = ['😀', '😁', '🥹', '😔', '😡', '😫'];
  List<String> customEmojis = [];
  List<String> allEmojis = [];

  // Controladores para análise de sentimento (simples)
  List<String> _keywords = [];

  // Variável para a busca
  String _searchQuery = '';

  // Variável para o filtro
  String _selectedFilter = 'Todas';

  @override
  void initState() {
    super.initState();
    _loadCustomEmojis();
    _initializeLocalization();
    allEmojis = [...defaultEmojis];
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  void _loadCustomEmojis() async {
    try {
      List<String> emojis = await apiService.fetchCustomEmojis();
      setState(() {
        customEmojis = emojis;
        allEmojis = [...defaultEmojis, ...customEmojis];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao carregar emojis personalizados: $e")),
      );
    }
  }

  void _adicionarEmojiPersonalizado(String emoji) async {
    if (customEmojis.length < 6) {
      setState(() {
        customEmojis.add(emoji);
        allEmojis = [...defaultEmojis, ...customEmojis];
      });
      try {
        await apiService.updateCustomEmojis(customEmojis);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao atualizar emojis personalizados: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Você pode personalizar até 6 emojis.")),
      );
    }
  }

  void _removerEmojiPersonalizado(String emoji) async {
    setState(() {
      customEmojis.remove(emoji);
      allEmojis = [...defaultEmojis, ...customEmojis];
    });
    try {
      await apiService.updateCustomEmojis(customEmojis);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao atualizar emojis personalizados: $e")),
      );
    }
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
      await apiService.createDiaryEntry(
        _selectedEmoji,
        _entryController.text,
      );
      setState(() {
        _isRegistered = true;
        _page = 1;
      });
      _carregarHistorico(refresh: true);
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
        _keywords.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao registrar entrada: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _isRegistered = false;
        });
      });
    }
  }

  void _carregarHistorico({bool refresh = false}) async {
    setState(() {
      _isFetchingMore = true;
    });

    if (refresh) {
      _page = 1;
      _entradas.clear();
    }

    try {
      String filter;
      if (_selectedFilter == 'Diário') {
        filter = 'daily';
      } else if (_selectedFilter == 'Semanal') {
        filter = 'weekly';
      } else if (_selectedFilter == 'Mensal') {
        filter = 'monthly';
      } else {
        filter = '';
      }

      Map<String, dynamic> response = await apiService.fetchDiaryEntries(filter,
          page: _page, limit: _limit);
      List<dynamic> novasEntradas = response['entries'];

      setState(() {
        _entradas.addAll(List<Map<String, dynamic>>.from(novasEntradas));
        _page++;
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

  Future<void> _initializeLocalization() async {
    try {
      await initializeDateFormatting('pt_BR', null);
    } catch (e) {
      // Adicionar uma verificação ou log em caso de falha
      print("Erro ao inicializar a formatação de data: $e");
    }
    _carregarHistorico(); // Agora carregue o histórico após garantir a inicialização.
  }

  String formatarData(DateTime data) {
    // Converte a data para o horário local antes de formatar
    DateTime dataLocal = data.toLocal();
    return DateFormat.yMMMMd('pt_BR').format(dataLocal);
  }

  String formatarHora(DateTime data) {
    // Converte a data para o horário local antes de formatar
    DateTime dataLocal = data.toLocal();
    return DateFormat.Hm().format(dataLocal);
  }

  void _analisarSentimento(String text) {
    // Implementação simples: extrair palavras-chave
    List<String> palavras = text.split(' ');
    setState(() {
      _keywords = palavras.where((palavra) => palavra.length > 4).toList();
    });
  }

  void _mostrarDialogoAdicionarEmoji() {
    TextEditingController emojiController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Adicionar Emoji Personalizado"),
          content: TextField(
            controller: emojiController,
            decoration: InputDecoration(hintText: "Digite ou cole o emoji"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                String novoEmoji = emojiController.text.trim();
                if (novoEmoji.isNotEmpty) {
                  _adicionarEmojiPersonalizado(novoEmoji);
                  Navigator.pop(context);
                }
              },
              child: Text("Adicionar"),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoRemoverEmoji(String emoji) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Remover Emoji"),
          content: Text("Tem certeza de que deseja remover este emoji?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (defaultEmojis.contains(emoji)) {
                  setState(() {
                    defaultEmojis.remove(emoji);
                    allEmojis = [...defaultEmojis, ...customEmojis];
                  });
                } else {
                  _removerEmojiPersonalizado(emoji);
                }
                Navigator.pop(context);
              },
              child: Text("Remover"),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDetalhesEntrada(Map<String, dynamic> entrada) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Detalhes do Humor"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entrada['moodEmoji'] ?? '',
                style: TextStyle(fontSize: 48),
              ),
              SizedBox(height: 10),
              Text(entrada['entry'] ?? ''),
              SizedBox(height: 10),
              Text(
                  "Registrado em ${formatarData(DateTime.parse(entrada['createdAt']))} às ${formatarHora(DateTime.parse(entrada['createdAt']))}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Fechar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _mostrarDialogoEditarEntrada(entrada);
              },
              child: Text("Editar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _confirmarExcluirEntrada(entrada['_id']);
              },
              child: Text("Excluir"),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDialogoEditarEntrada(Map<String, dynamic> entrada) {
    TextEditingController editEntryController =
        TextEditingController(text: entrada['entry']);
    String editSelectedEmoji = entrada['moodEmoji'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Editar Entrada"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Emojis para seleção
                Wrap(
                  spacing: 8,
                  children: defaultEmojis.map((emoji) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          editSelectedEmoji = emoji;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: editSelectedEmoji == emoji
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
                  }).toList(),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: editEntryController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "Editar descrição",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await apiService.updateDiaryEntry(
                    entrada['_id'],
                    moodEmoji: editSelectedEmoji,
                    entry: editEntryController.text,
                  );
                  Navigator.pop(context);
                  _carregarHistorico(refresh: true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Entrada atualizada com sucesso!")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Erro ao atualizar entrada: $e")),
                  );
                }
              },
              child: Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  void _confirmarExcluirEntrada(String entryId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Excluir Entrada"),
          content: Text("Tem certeza de que deseja excluir esta entrada?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await apiService.deleteDiaryEntry(entryId);
                  Navigator.pop(context);
                  _carregarHistorico(refresh: true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Entrada excluída com sucesso!")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Erro ao excluir entrada: $e")),
                  );
                }
              },
              child: Text("Excluir"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Combinar emojis padrão com personalizados
    allEmojis = [...defaultEmojis, ...customEmojis];

    // Filtrar entradas com base na busca
    List<Map<String, dynamic>> displayedEntries = _entradas.where((entrada) {
      String entryText = entrada['entry'].toString().toLowerCase();
      return entryText.contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Diário de Humor"),
        actions: [
          IconButton(
            icon: Icon(Icons.show_chart),
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        GraficoHumorScreen(entradas: _entradas)),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _carregarHistorico(refresh: true);
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16.0.w), // Responsive padding
            child: Column(
              children: [
                // Seção de Registro de Emoções
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Como você está se sentindo?",
                    style: TextStyle(
                      fontSize: 18.sp, // Responsive font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10.h), // Responsive spacing

                // Scroll horizontal para emojis com botão de adicionar
                Container(
                  height: 70.h, // Responsive height
                  child: Row(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: allEmojis.length,
                          itemBuilder: (context, index) {
                            final emoji = allEmojis[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedEmoji = emoji;
                                });
                              },
                              onLongPress: () {
                                _mostrarDialogoRemoverEmoji(emoji);
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                margin: EdgeInsets.symmetric(horizontal: 4),
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
                              ).animate().fadeIn(),
                            );
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: _mostrarDialogoAdicionarEmoji,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h), // Responsive spacing

                // Campo de texto para descrever o humor com prompt de reflexão
                TextField(
                  controller: _entryController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "Descreva seu humor (opcional)",
                    hintText: "O que aconteceu hoje que influenciou seu humor?",
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(fontSize: 16.sp), // Responsive font size
                    hintStyle: TextStyle(fontSize: 14.sp), // Responsive font size
                  ),
                  style: TextStyle(fontSize: 14.sp), // Responsive font size
                  onChanged: (text) {
                    _analisarSentimento(text);
                  },
                ),
                SizedBox(height: 10.h), // Responsive spacing

                // Exibição de palavras-chave (análise de sentimento simples)
                _keywords.isNotEmpty
                    ? Wrap(
                        spacing: 8,
                        children: _keywords
                            .map((keyword) => Chip(label: Text(keyword)))
                            .toList(),
                      )
                    : Container(),

                SizedBox(height: 10.h), // Responsive spacing

                // Botão "Registrar Humor" com animação
                Center(
                  child: SizedBox(
                    width: 200.w, // Responsive width
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _registrarHumor,
                      child: _isLoading
                          ? SpinKitCircle(color: Colors.white, size: 30.w) // Responsive size
                          : Text("Registrar Humor", style: TextStyle(fontSize: 16.sp)), // Responsive font size
                    ).animate().scale(),
                  ),
                ),
                SizedBox(height: 20.h), // Responsive spacing

                // Mensagem de sucesso
                _isRegistered
                    ? AnimatedOpacity(
                        opacity: _isRegistered ? 1.0 : 0.0,
                        duration: Duration(seconds: 1),
                        child: Text(
                          "Humor registrado com sucesso!",
                          style: TextStyle(
                            fontSize: 16.sp, // Responsive font size
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Container(),

                Divider(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Histórico de Humor",
                    style: TextStyle(
                      fontSize: 18.sp, // Responsive font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10.h), // Responsive spacing

                // Adicionar o filtro
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Filtrar:'),
                    SizedBox(width: 10.w), // Responsive spacing
                    DropdownButton<String>(
                      value: _selectedFilter,
                      items: ['Todas', 'Diário', 'Semanal', 'Mensal']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedFilter = newValue!;
                          _carregarHistorico(refresh: true);
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10.h), // Responsive spacing

                // Campo de busca por palavras-chave
                TextField(
                  decoration: InputDecoration(
                    labelText: "Buscar no histórico",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (text) {
                    setState(() {
                      _searchQuery = text.toLowerCase();
                    });
                  },
                ),
                SizedBox(height: 10.h), // Responsive spacing

                // Histórico de humor com animações
                displayedEntries.isEmpty
                    ? Center(child: Text("Nenhum registro encontrado."))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: displayedEntries.length,
                        itemBuilder: (context, index) {
                          final entrada = displayedEntries[index];
                          final DateTime createdAt =
                              DateTime.parse(entrada['createdAt']);
                          final String moodEmoji = entrada['moodEmoji'];
                          final String texto = entrada['entry'];

                          return ListTile(
                            leading:
                                Text(moodEmoji, style: TextStyle(fontSize: 32)),
                            title: Text(texto),
                            subtitle: Text(
                                "Registrado em ${formatarData(createdAt)} às ${formatarHora(createdAt)}"),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              // Ao tocar, exibir detalhes ou opções de edição
                              _mostrarDetalhesEntrada(entrada);
                            },
                          ).animate().slide();
                        },
                      ),

                // Botão "Carregar Mais" com animação
                Center(
                  child: SizedBox(
                    width: 200.w, // Responsive width
                    child: _isFetchingMore
                        ? SpinKitCircle(color: Colors.blue, size: 30.w) // Responsive size
                        : ElevatedButton(
                            onPressed: () {
                              _carregarHistorico();
                            },
                            child: Text("Carregar Mais", style: TextStyle(fontSize: 16.sp)), // Responsive font size
                          ).animate().scale(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Classe para o Gráfico de Humor
class GraficoHumorScreen extends StatelessWidget {
  final List<Map<String, dynamic>> entradas;

  GraficoHumorScreen({required this.entradas});

  // Converter o emoji em valor numérico
  int getMoodValue(String emoji) {
    switch (emoji) {
      case '😀':
        return 5;
      case '😁':
        return 4;
      case '🥹':
        return 3;
      case '😔':
        return 2;
      case '😡':
        return 1;
      case '😫':
        return 0;
      default:
        return 3; // Valor médio
    }
  }

  @override
  Widget build(BuildContext context) {
    List<ChartData> data = entradas.map((entrada) {
      DateTime date = DateTime.parse(entrada['createdAt']);
      int moodValue = getMoodValue(entrada['moodEmoji']);
      return ChartData(date, moodValue);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text("Gráfico de Humor")),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Margem externa do gráfico
        child: SfCartesianChart(
          plotAreaBorderWidth: 0, // Remove a borda ao redor do gráfico
          plotAreaBackgroundColor:
              Colors.transparent, // Transparente para estética
          plotAreaBorderColor: Colors.transparent, // Remover borda visual
          margin: EdgeInsets.all(
              16), // Adiciona uma margem para melhorar espaçamento
          primaryXAxis: DateTimeAxis(
            minimum: data.isNotEmpty
                ? data.last.date
                : DateTime.now().subtract(Duration(days: 30)),
            maximum: data.isNotEmpty ? data.first.date : DateTime.now(),
            intervalType: DateTimeIntervalType.days, // Exibir por dias
            edgeLabelPlacement: EdgeLabelPlacement
                .shift, // Ajuste de labels para não cortar nas bordas
            enableAutoIntervalOnZooming:
                true, // Permite ajuste dinâmico dos intervalos ao fazer zoom
            dateFormat: DateFormat.MMM('pt_BR'),
          ),
          primaryYAxis: NumericAxis(
            minimum: 0,
            maximum: 5,
            interval: 1,
            axisLabelFormatter: (AxisLabelRenderDetails args) {
              switch (args.value.toInt()) {
                case 0:
                  return ChartAxisLabel('😫', TextStyle());
                case 1:
                  return ChartAxisLabel('😡', TextStyle());
                case 2:
                  return ChartAxisLabel('😔', TextStyle());
                case 3:
                  return ChartAxisLabel('🥹', TextStyle());
                case 4:
                  return ChartAxisLabel('😁', TextStyle());
                case 5:
                  return ChartAxisLabel('😀', TextStyle());
                default:
                  return ChartAxisLabel('', TextStyle());
              }
            },
          ),
          zoomPanBehavior: ZoomPanBehavior(
            enablePanning: true, // Habilitar rolagem
            enablePinching: true, // Habilitar zoom com gesto de pinça
            zoomMode: ZoomMode.x, // Permitir zoom apenas no eixo X
            maximumZoomLevel:
                0.5, // Definir o máximo nível de zoom (quanto menor, mais zoom)
          ),
          series: <CartesianSeries>[
            LineSeries<ChartData, DateTime>(
              dataSource: data,
              xValueMapper: (ChartData entry, _) => entry.date,
              yValueMapper: (ChartData entry, _) => entry.moodValue,
              dataLabelSettings: DataLabelSettings(isVisible: true),
              markerSettings: MarkerSettings(isVisible: true),
              onPointTap: (ChartPointDetails details) {
                // Ao tocar no ponto, mostrar detalhes
                final entrada = entradas[details.pointIndex!];
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Detalhes do Humor"),
                      content: Text(
                          "${entrada['moodEmoji']} - ${entrada['entry']}\nData: ${DateFormat.yMMMMd('pt_BR').format(DateTime.parse(entrada['createdAt']))}"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Fechar"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final DateTime date;
  final int moodValue;

  ChartData(this.date, this.moodValue);
}
