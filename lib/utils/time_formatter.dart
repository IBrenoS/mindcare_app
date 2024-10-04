String formatarTempoEmPortugues(DateTime dataPostagem) {
  final agora = DateTime.now();
  final diferenca = agora.difference(dataPostagem);

  if (diferenca.inDays > 1) {
    return 'há ${diferenca.inDays} dias';
  } else if (diferenca.inDays == 1) {
    return 'há 1 dia';
  } else if (diferenca.inHours > 1) {
    return 'há ${diferenca.inHours} horas';
  } else if (diferenca.inHours == 1) {
    return 'há 1 hora';
  } else if (diferenca.inMinutes > 1) {
    return 'há ${diferenca.inMinutes} minutos';
  } else {
    return 'há alguns segundos';
  }
}
