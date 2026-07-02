class Configuracao {
  final int id;
  final String nomeTecnico;
  final String cargo;
  final String? assinaturaPath;  // Caminho da imagem da assinatura
  final bool setupConcluido;
  final String? chaveLicenca;
  final DateTime? dataExpiracao;
  final String? plano;  // 'mensal', 'bimestral', 'semestral', 'anual'
  final bool assinaturaAtiva;
  final String? corPrimaria;
  final String? corSecundaria;
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;

  Configuracao({
    this.id = 1,
    required this.nomeTecnico,
    required this.cargo,
    this.assinaturaPath,
    this.setupConcluido = false,
    this.chaveLicenca,
    this.dataExpiracao,
    this.plano,
    this.assinaturaAtiva = false,
    this.corPrimaria = '#2196F3',
    this.corSecundaria = '#FF9800',
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
  }) : 
    dataCriacao = dataCriacao ?? DateTime.now(),
    dataAtualizacao = dataAtualizacao ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome_tecnico': nomeTecnico,
      'cargo': cargo,
      'assinatura_path': assinaturaPath,
      'setup_concluido': setupConcluido ? 1 : 0,
      'chave_licenca': chaveLicenca,
      'data_expiracao': dataExpiracao?.toIso8601String(),
      'plano': plano,
      'assinatura_ativa': assinaturaAtiva ? 1 : 0,
      'cor_primaria': corPrimaria,
      'cor_secundaria': corSecundaria,
      'data_criacao': dataCriacao.toIso8601String(),
      'data_atualizacao': dataAtualizacao.toIso8601String(),
    };
  }

  factory Configuracao.fromMap(Map<String, dynamic> map) {
    return Configuracao(
      id: map['id'] ?? 1,
      nomeTecnico: map['nome_tecnico'] ?? '',
      cargo: map['cargo'] ?? '',
      assinaturaPath: map['assinatura_path'],
      setupConcluido: map['setup_concluido'] == 1,
      chaveLicenca: map['chave_licenca'],
      dataExpiracao: map['data_expiracao'] != null 
          ? DateTime.parse(map['data_expiracao']) 
          : null,
      plano: map['plano'],
      assinaturaAtiva: map['assinatura_ativa'] == 1,
      corPrimaria: map['cor_primaria'] ?? '#2196F3',
      corSecundaria: map['cor_secundaria'] ?? '#FF9800',
      dataCriacao: map['data_criacao'] != null 
          ? DateTime.parse(map['data_criacao']) 
          : DateTime.now(),
      dataAtualizacao: map['data_atualizacao'] != null 
          ? DateTime.parse(map['data_atualizacao']) 
          : DateTime.now(),
    );
  }

  Configuracao copyWith({
    int? id,
    String? nomeTecnico,
    String? cargo,
    String? assinaturaPath,
    bool? setupConcluido,
    String? chaveLicenca,
    DateTime? dataExpiracao,
    String? plano,
    bool? assinaturaAtiva,
    String? corPrimaria,
    String? corSecundaria,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
  }) {
    return Configuracao(
      id: id ?? this.id,
      nomeTecnico: nomeTecnico ?? this.nomeTecnico,
      cargo: cargo ?? this.cargo,
      assinaturaPath: assinaturaPath ?? this.assinaturaPath,
      setupConcluido: setupConcluido ?? this.setupConcluido,
      chaveLicenca: chaveLicenca ?? this.chaveLicenca,
      dataExpiracao: dataExpiracao ?? this.dataExpiracao,
      plano: plano ?? this.plano,
      assinaturaAtiva: assinaturaAtiva ?? this.assinaturaAtiva,
      corPrimaria: corPrimaria ?? this.corPrimaria,
      corSecundaria: corSecundaria ?? this.corSecundaria,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
    );
  }

  // Verifica se a assinatura está ativa e não expirada
  bool get isAssinaturaValida {
    if (!assinaturaAtiva) return false;
    if (dataExpiracao == null) return false;
    return DateTime.now().isBefore(dataExpiracao!);
  }

  // Calcula dias restantes da assinatura
  int get diasRestantes {
    if (dataExpiracao == null) return 0;
    final diff = dataExpiracao!.difference(DateTime.now());
    return diff.inDays;
  }
}