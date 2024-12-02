import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mindcare_app/services/api_service.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  _PrivacyScreenState createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  final ApiService _apiService = ApiService();
  bool _hasPendingDeletion = false;  // Add this state variable

  @override
  void initState() {
    super.initState();
  }


  Future<void> _showDeleteAccountDialog() async {
    if (_hasPendingDeletion) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Exclusão em Andamento',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sua conta está programada para ser excluída.'),
                SizedBox(height: 8.h),
                Text('A exclusão será concluída em 7 dias.'),
                SizedBox(height: 16.h),
                Text(
                  'Deseja cancelar a exclusão?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Não'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    setState(() {
                      _hasPendingDeletion = false;
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Solicitação de exclusão cancelada.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
                child: const Text('Sim, cancelar exclusão'),
              ),
            ],
          );
        },
      );
    }

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Deletar Conta',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Importante:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              const Text(
                '• Sua conta será programada para exclusão\n'
                '• O processo será concluído após 7 dias\n'
                '• Durante este período, você pode cancelar a exclusão\n'
                '• Após 7 dias, todos os dados serão permanentemente excluídos',
              ),
              SizedBox(height: 16.h),
              const Text(
                'Deseja continuar com a exclusão?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await _apiService.deleteAccount();
                  setState(() {
                    _hasPendingDeletion = true;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Conta programada para exclusão. Será deletada em 7 dias.',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: Text(
                'Deletar',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacidade',
          style: TextStyle(fontSize: 20.sp),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configurações de Privacidade',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),

                // Visibilidade do Perfil
                ListTile(
                  title: Text(
                    'Visibilidade do Perfil',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  subtitle: const Text('Controle quem pode ver seu perfil'),
                  leading: const Icon(Icons.visibility),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Implementar navegação para configurações de visibilidade
                  },
                ),
                const Divider(),

                // Dados Pessoais
                ListTile(
                  title: Text(
                    'Dados Pessoais',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  subtitle: const Text('Gerencie seus dados pessoais'),
                  leading: const Icon(Icons.person_outline),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Implementar navegação para gerenciamento de dados
                  },
                ),
                const Divider(),

                // Bloqueios
                ListTile(
                  title: Text(
                    'Usuários Bloqueados',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  subtitle: const Text('Gerencie sua lista de bloqueios'),
                  leading: const Icon(Icons.block),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Implementar navegação para lista de bloqueios
                  },
                ),
                const Divider(),

                SizedBox(height: 32.h),
                Text(
                  'Dados da Conta',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),

                // Download dos Dados
                ListTile(
                  title: Text(
                    'Fazer Download dos Meus Dados',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  subtitle: const Text('Baixe uma cópia dos seus dados'),
                  leading: const Icon(Icons.download),
                  onTap: () {
                    // Implementar download de dados
                  },
                ),
                const Divider(),

                // Deletar Conta
                ListTile(
                  title: Text(
                    _hasPendingDeletion
                        ? 'Cancelar Exclusão da Conta'
                        : 'Deletar Minha Conta',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  subtitle: Text(
                    _hasPendingDeletion
                        ? 'Sua conta está programada para exclusão'
                        : 'Excluir permanentemente sua conta e dados',
                  ),
                  leading: Icon(
                    _hasPendingDeletion ? Icons.restore : Icons.delete_forever,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onTap: _showDeleteAccountDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
