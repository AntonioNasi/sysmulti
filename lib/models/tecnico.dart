class Tecnico {
  final int? id;
  final String nome;
  final String nomeCompleto;
  final String assinatura;
  final String cargo; // NOVO CAMPO

  Tecnico({
    this.id,
    required this.nome,
    required this.nomeCompleto,
    required this.assinatura,
    required this.cargo, // NOVO
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'nomeCompleto': nomeCompleto,
      'assinatura': assinatura,
      'cargo': cargo, // NOVO
    };
  }

  factory Tecnico.fromMap(Map<String, dynamic> map) {
    return Tecnico(
      id: map['id'],
      nome: map['nome'],
      nomeCompleto: map['nomeCompleto'],
      assinatura: map['assinatura'],
      cargo: map['cargo'] ?? '', // NOVO com valor padrão
    );
  }
}