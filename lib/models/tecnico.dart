class Tecnico {


  final int? id;

  final String nome;

  final String nomeCompleto;

  final String assinatura;



  Tecnico({

    this.id,

    required this.nome,

    required this.nomeCompleto,

    required this.assinatura,

  });





  Map<String, dynamic> toMap(){


    return {

      'id': id,

      'nome': nome,

      'nomeCompleto': nomeCompleto,

      'assinatura': assinatura,

    };


  }





  factory Tecnico.fromMap(Map<String,dynamic> map){


    return Tecnico(

      id: map['id'],

      nome: map['nome'],

      nomeCompleto: map['nomeCompleto'],

      assinatura: map['assinatura'],

    );


  }


}