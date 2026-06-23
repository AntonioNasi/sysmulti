import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/escola.dart';



class EscolasScreen extends StatefulWidget {


  const EscolasScreen({super.key});


  @override
  State<EscolasScreen> createState() => _EscolasScreenState();


}



class _EscolasScreenState extends State<EscolasScreen> {


  final nome = TextEditingController();

  final municipio = TextEditingController();

  final diretor = TextEditingController();


  List<Escola> escolas = [];



  carregar() async {


    escolas = await DatabaseHelper.instance.listarEscolas();


    setState(() {});


  }



  salvar() async {


    final escola = Escola(

      nome: nome.text,

      municipio: municipio.text,

      diretor: diretor.text,

    );


    await DatabaseHelper.instance.inserirEscola(escola);


    nome.clear();

    municipio.clear();

    diretor.clear();


    carregar();


  }



  @override

  void initState() {

    super.initState();

    carregar();

  }




  @override

  Widget build(BuildContext context) {


    return Scaffold(


      appBar: AppBar(

        title: const Text('Escolas'),

      ),



      body: Padding(


        padding: const EdgeInsets.all(16),



        child: Column(


          children: [


            TextField(

              controller: nome,

              decoration:

              const InputDecoration(

                labelText: 'Nome da escola',

              ),

            ),



            TextField(

              controller: municipio,

              decoration:

              const InputDecoration(

                labelText: 'Município',

              ),

            ),



            TextField(

              controller: diretor,

              decoration:

              const InputDecoration(

                labelText: 'Diretor(a)',

              ),

            ),



            ElevatedButton(

              onPressed: salvar,

              child: const Text('Salvar'),

            ),



            Expanded(


              child: ListView.builder(


                itemCount: escolas.length,


                itemBuilder: (context,index){


                  final escola = escolas[index];


                  return ListTile(

                    title: Text(escola.nome),

                    subtitle: Text(

                      escola.municipio,

                    ),

                  );


                },


              ),

            )



          ],


        ),


      ),


    );


  }


}