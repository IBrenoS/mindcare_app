import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FAQScreen extends StatelessWidget {
  final List<Map<String, String>> faqItems = [
    {
      'question':
          'Como o MindCare pode me ajudar a melhorar minha saúde mental?',
      'answer':
          'O MindCare oferece recursos como Diário de Humor, Exercícios de Meditação e Comunidade de Apoio para auxiliar na redução de estresse e ansiedade.'
    },
    {
      'question': 'O que é o Diário de Humor e como utilizá-lo?',
      'answer':
          'O Diário de Humor permite que você registre seu humor diário usando emojis e anotações para acompanhar seu bem-estar emocional.'
    },
    {
      'question': 'Como funciona a Comunidade de Apoio?',
      'answer':
          'É um espaço seguro para compartilhar experiências, interagir com outros membros e receber apoio emocional.'
    },
    {
      'question':
          'Posso usar o MindCare para encontrar profissionais de saúde mental?',
      'answer':
          'Sim! Use o mapa de geolocalização para encontrar clínicas próximas e acessar suporte presencial.'
    },
    {
      'question': 'Como proteger meus dados pessoais no MindCare?',
      'answer':
          'O MindCare é totalmente compatível com a LGPD e utiliza criptografia para proteger seus dados.'
    },
    {
      'question': 'O que fazer se eu esquecer minha senha?',
      'answer':
          'Use a opção "Esqueci minha senha" na tela de login para redefinir sua senha de forma rápida e segura.'
    },
    {
      'question': 'Os exercícios de meditação são pagos?',
      'answer':
          'Alguns exercícios são gratuitos, mas há conteúdo premium disponível através de planos de assinatura.'
    },
    {
      'question': 'Como entro em contato com o suporte?',
      'answer':
          'Você pode preencher o formulário de contato na seção "Suporte ao Usuário" ou enviar um e-mail para suporte@mindcare.com.'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Perguntas Frequentes (FAQ)',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: ListView.builder(
          itemCount: faqItems.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              elevation: 2,
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  title: Text(
                    faqItems[index]['question']!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 16.sp,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                      child: Text(
                        faqItems[index]['answer']!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 14.sp,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              height: 1.5,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
