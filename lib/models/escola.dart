class Escola {

  final int? id;

  final String nome;

  final String diretor;



  Escola({

    this.id,

    required this.nome,

    required this.diretor,

  });



  Map<String, dynamic> toMap() {


    return {

      'id': id,

      'nome': nome,

      'diretor': diretor,

    };


  }




  factory Escola.fromMap(Map<String, dynamic> map) {


    return Escola(

      id: map['id'],

      nome: map['nome'],

      diretor: map['diretor'],

    );


  }


}