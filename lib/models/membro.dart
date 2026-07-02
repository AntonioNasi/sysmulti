class Membro {
  final int? id;
  final String nome;
  final String email;
  final String senha;
  final String tipo;
  final bool ativo;
  final DateTime dataCadastro;
  final DateTime? ultimoAcesso;
  final String? fotoPath;

  Membro({
    this.id,
    required this.nome,
    required this.email,
    required this.senha,
    required this.tipo,
    this.ativo = true,
    required this.dataCadastro,
    this.ultimoAcesso,
    this.fotoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
      'tipo': tipo,
      'ativo': ativo ? 1 : 0,
      'data_cadastro': dataCadastro.toIso8601String(),
      'ultimo_acesso': ultimoAcesso?.toIso8601String(),
      'foto_path': fotoPath,
    };
  }

  factory Membro.fromMap(Map<String, dynamic> map) {
    return Membro(
      id: map['id'],
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      senha: map['senha'] ?? '',
      tipo: map['tipo'] ?? 'Membro',
      ativo: map['ativo'] == 1,
      dataCadastro: DateTime.parse(map['data_cadastro']),
      ultimoAcesso: map['ultimo_acesso'] != null 
          ? DateTime.parse(map['ultimo_acesso']) 
          : null,
      fotoPath: map['foto_path'],
    );
  }

  Membro copyWith({
    int? id,
    String? nome,
    String? email,
    String? senha,
    String? tipo,
    bool? ativo,
    DateTime? dataCadastro,
    DateTime? ultimoAcesso,
    String? fotoPath,
  }) {
    return Membro(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      senha: senha ?? this.senha,
      tipo: tipo ?? this.tipo,
      ativo: ativo ?? this.ativo,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      ultimoAcesso: ultimoAcesso ?? this.ultimoAcesso,
      fotoPath: fotoPath ?? this.fotoPath,
    );
  }
}