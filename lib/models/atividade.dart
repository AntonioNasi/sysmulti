class Atividade {


  final int? id;


  final int escolaId;


  final int tecnicoId;


  final String municipio;


  final String tipo;


  final String data;


  final String dados;



  // NOVOS CAMPOS - ASSINATURA DA ESCOLA

  final String? assinaturaEscola;


  final String? nomeResponsavelAssinatura;


  final String? funcaoResponsavelAssinatura;





  Atividade({


    this.id,


    required this.escolaId,


    required this.tecnicoId,


    required this.municipio,


    required this.tipo,


    required this.data,


    required this.dados,



    this.assinaturaEscola,


    this.nomeResponsavelAssinatura,


    this.funcaoResponsavelAssinatura,


  });









  Map<String, dynamic> toMap(){


    return {


      'id': id,


      'escolaId': escolaId,


      'tecnicoId': tecnicoId,


      'municipio': municipio,


      'tipo': tipo,


      'data': data,


      'dados': dados,



      'assinaturaEscola':
      assinaturaEscola,



      'nomeResponsavelAssinatura':
      nomeResponsavelAssinatura,



      'funcaoResponsavelAssinatura':
      funcaoResponsavelAssinatura,



    };


  }









  factory Atividade.fromMap(

      Map<String,dynamic> map

      ){



    return Atividade(


      id: map['id'],


      escolaId: map['escolaId'],


      tecnicoId: map['tecnicoId'],


      municipio: map['municipio'],


      tipo: map['tipo'],


      data: map['data'],


      dados: map['dados'],



      assinaturaEscola:
      map['assinaturaEscola'],



      nomeResponsavelAssinatura:
      map['nomeResponsavelAssinatura'],



      funcaoResponsavelAssinatura:
      map['funcaoResponsavelAssinatura'],



    );


  }



}