import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mindcare_app/services/api_service.dart';
import 'package:mindcare_app/theme/theme.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DiarioHumorScreen extends StatefulWidget {
  const DiarioHumorScreen({Key? key}) : super(key: key);

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

  final FocusNode _textFieldFocusNode = FocusNode();

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
    _textFieldFocusNode.dispose();
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
        // Exibir mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: successColorLight,
            content: Text(
              "Emoji adicionado com sucesso!",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: msg,
                  ),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text(
              "Erro ao atualizar emojis personalizados: $e",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onError,
                  ),
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: Text(
            "Você pode personalizar até 6 emojis.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onError,
                ),
          ),
        ),
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
        const SnackBar(
            content: Text("Selecione um emoji que representa seu humor")),
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
            children: const [
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
      Future.delayed(const Duration(seconds: 2), () {
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
      // Log de erro
      print("Erro ao inicializar a formatação de data: $e");
    }
    _carregarHistorico(); // Carrega o histórico após a inicialização.
  }

  String formatarData(DateTime data) {
    DateTime dataLocal = data.toLocal();
    return DateFormat.yMMMMd('pt_BR').format(dataLocal);
  }

  String formatarHora(DateTime data) {
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
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            "Adicionar Emoji Personalizado",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          content: TextField(
            controller: emojiController,
            decoration: InputDecoration(
              hintText: "Digite ou cole o emoji",
              hintStyle: Theme.of(context).textTheme.bodyMedium,
              border: const OutlineInputBorder(),
            ),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Cancelar",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                String novoEmoji = emojiController.text.trim();
                if (novoEmoji.isNotEmpty) {
                  _adicionarEmojiPersonalizado(novoEmoji);
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                "Adicionar",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
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
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            "Remover Emoji",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          content: Text(
            "Tem certeza de que deseja remover este emoji?",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Cancelar",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                "Remover",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              ),
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
          title: const Text("Detalhes do Humor"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entrada['moodEmoji'] ?? '',
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 10),
              Text(
                entrada['entry'] ?? '',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 10),
              Text(
                "Registrado em ${formatarData(DateTime.parse(entrada['createdAt']))} às ${formatarHora(DateTime.parse(entrada['createdAt']))}",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Fechar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _mostrarDialogoEditarEntrada(entrada);
              },
              child: const Text("Editar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _confirmarExcluirEntrada(entrada['_id']);
              },
              child: const Text("Excluir"),
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
          title: const Text("Editar Entrada"),
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: editSelectedEmoji == emoji
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: editEntryController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "Editar descrição",
                    border: const OutlineInputBorder(),
                    labelStyle: Theme.of(context).textTheme.bodyMedium,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancelar"),
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
                    const SnackBar(
                        content: Text("Entrada atualizada com sucesso!")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Erro ao atualizar entrada: $e")),
                  );
                }
              },
              child: Text(
                "Salvar",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Theme.of(context).colorScheme.surface,
              ),
             ),
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
          title: const Text("Excluir Entrada"),
          content:
              const Text("Tem certeza de que deseja excluir esta entrada?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await apiService.deleteDiaryEntry(entryId);
                  Navigator.pop(context);
                  _carregarHistorico(refresh: true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Entrada excluída com sucesso!")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Erro ao excluir entrada: $e")),
                  );
                }
              },
              child: const Text("Excluir"),
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
        title: Text(
          "Diário de Humor",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.show_chart,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GraficoHumorScreen(entradas: _entradas),
                ),
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
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16.0.w), // Responsive padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seção de Registro de Emoções
                Text(
                  "Como você está se sentindo?",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 10.h), // Responsive spacing

                // Scroll horizontal para emojis com botão de adicionar
                SizedBox(
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
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _selectedEmoji == emoji
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 32),
                                ),
                              ).animate().fadeIn(),
                            );
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.add,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onPressed: _mostrarDialogoAdicionarEmoji,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h), // Responsive spacing

                // Campo de texto para descrever o humor com prompt de reflexão
                TextField(
                  controller: _entryController,
                  focusNode: _textFieldFocusNode,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "Descreva seu humor (opcional)",
                    hintText: "O que aconteceu hoje que influenciou seu humor?",
                    border: const OutlineInputBorder(),
                    labelStyle: Theme.of(context).textTheme.labelLarge,
                    hintStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
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
                            .map((keyword) => Chip(
                                  label: Text(
                                    keyword,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                ))
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
                          ? SpinKitCircle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 30.w,
                            ) // Responsive size
                          : Text(
                              "Registrar Humor",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                            ), // Responsive font size
                    ).animate().scale(),
                  ),
                ),
                SizedBox(height: 20.h), // Responsive spacing

                // Mensagem de sucesso
                _isRegistered
                    ? AnimatedOpacity(
                        opacity: _isRegistered ? 1.0 : 0.0,
                        duration: const Duration(seconds: 1),
                        child: Text(
                          "Humor registrado com sucesso!",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Container(),

                const Divider(),
                Text(
                  "Histórico de Humor",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                SizedBox(height: 10.h), // Responsive spacing

                // Adicionar o filtro
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Filtrar:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(width: 10.w), // Responsive spacing
                    DropdownButton<String>(
                      value: _selectedFilter,
                      items: ['Todas', 'Diário', 'Semanal', 'Mensal']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
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
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    border: const OutlineInputBorder(),
                    labelStyle: Theme.of(context).textTheme.labelLarge,
                  ),
                  style: Theme.of(context).textTheme.bodyLarge,
                  onChanged: (text) {
                    setState(() {
                      _searchQuery = text.toLowerCase();
                    });
                  },
                ),
                SizedBox(height: 10.h), // Responsive spacing

                // Histórico de humor com animações
                displayedEntries.isEmpty
                    ? Center(
                        child: Text(
                          "Nenhum registro encontrado.",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: displayedEntries.length,
                        itemBuilder: (context, index) {
                          final entrada = displayedEntries[index];
                          final DateTime createdAt =
                              DateTime.parse(entrada['createdAt']);
                          final String moodEmoji = entrada['moodEmoji'];
                          final String texto = entrada['entry'];

                          return ListTile(
                            leading: Text(
                              moodEmoji,
                              style: const TextStyle(fontSize: 32),
                            ),
                            title: Text(
                              texto,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            subtitle: Text(
                              "Registrado em ${formatarData(createdAt)} às ${formatarHora(createdAt)}",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: Theme.of(context).iconTheme.color,
                            ),
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
                        ? SpinKitCircle(
                            color: Theme.of(context).colorScheme.primary,
                            size: 30.w,
                          ) // Responsive size
                        : ElevatedButton(
                            onPressed: () {
                              _carregarHistorico();
                            },
                            child: Text(
                              "Carregar Mais",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                            ), // Responsive font size
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

  GraficoHumorScreen({Key? key, required this.entradas}) : super(key: key);

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
      appBar: AppBar(
        title: Text(
          "Gráfico de Humor",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Margem externa do gráfico
        child: SfCartesianChart(
          plotAreaBorderWidth: 0, // Remove a borda ao redor do gráfico
          plotAreaBackgroundColor:
              Colors.transparent, // Transparente para estética
          plotAreaBorderColor: Colors.transparent, // Remover borda visual
          margin: const EdgeInsets.all(
              16), // Adiciona uma margem para melhorar espaçamento
          primaryXAxis: DateTimeAxis(
            minimum: data.isNotEmpty
                ? data.last.date
                : DateTime.now().subtract(const Duration(days: 30)),
            maximum: data.isNotEmpty ? data.first.date : DateTime.now(),
            intervalType: DateTimeIntervalType.days, // Exibir por dias
            edgeLabelPlacement: EdgeLabelPlacement
                .shift, // Ajuste de labels para não cortar nas bordas
            enableAutoIntervalOnZooming:
                true, // Permite ajuste dinâmico dos intervalos ao fazer zoom
            dateFormat: DateFormat.MMM('pt_BR'),
            labelStyle: Theme.of(context).textTheme.bodySmall,
          ),
          primaryYAxis: NumericAxis(
            minimum: 0,
            maximum: 5,
            interval: 1,
            axisLabelFormatter: (AxisLabelRenderDetails args) {
              switch (args.value.toInt()) {
                case 0:
                  return ChartAxisLabel(
                      '😫', Theme.of(context).textTheme.bodySmall!);
                case 1:
                  return ChartAxisLabel(
                      '😡', Theme.of(context).textTheme.bodySmall!);
                case 2:
                  return ChartAxisLabel(
                      '😔', Theme.of(context).textTheme.bodySmall!);
                case 3:
                  return ChartAxisLabel(
                      '🥹', Theme.of(context).textTheme.bodySmall!);
                case 4:
                  return ChartAxisLabel(
                      '😁', Theme.of(context).textTheme.bodySmall!);
                case 5:
                  return ChartAxisLabel(
                      '😀', Theme.of(context).textTheme.bodySmall!);
                default:
                  return ChartAxisLabel(
                      '', Theme.of(context).textTheme.bodySmall!);
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
              color: Theme.of(context).colorScheme.primary,
              dataSource: data,
              xValueMapper: (ChartData entry, _) => entry.date,
              yValueMapper: (ChartData entry, _) => entry.moodValue,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
              markerSettings: const MarkerSettings(isVisible: true),
              onPointTap: (ChartPointDetails details) {
                // Ao tocar no ponto, mostrar detalhes
                final entrada = entradas[details.pointIndex!];
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Detalhes do Humor"),
                      content: Text(
                        "${entrada['moodEmoji']} - ${entrada['entry']}\nData: ${DateFormat.yMMMMd('pt_BR').format(DateTime.parse(entrada['createdAt']))}",
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Fechar"),
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
