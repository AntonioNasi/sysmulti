class Escola {
  final int? id;
  final String nome;
  final String municipio;
  final String diretor;

  Escola({
    this.id,
    required this.nome,
    required this.municipio,
    required this.diretor,
  });


  Map<String, dynamic> toMap() {

    return {

      'id': id,
      'nome': nome,
      'municipio': municipio,
      'diretor': diretor,

    };

  }


  factory Escola.fromMap(Map<String, dynamic> map) {

    return Escola(

      id: map['id'],

      nome: map['nome'],

      municipio: map['municipio'],

      diretor: map['diretor'],

    );

  }

}