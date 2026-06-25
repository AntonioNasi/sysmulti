import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';



class AssinaturaPad extends StatefulWidget {


  final Function(Uint8List imagem) onConfirmar;



  const AssinaturaPad({

    super.key,

    required this.onConfirmar,

  });





  @override
  State<AssinaturaPad> createState() =>
      _AssinaturaPadState();


}







class _AssinaturaPadState
    extends State<AssinaturaPad> {



  final SignatureController controller =

  SignatureController(

    penStrokeWidth: 3,

    penColor: Colors.black,

    exportBackgroundColor: Colors.white,

  );







  @override
  void dispose() {

    controller.dispose();

    super.dispose();

  }







  Future<void> confirmar() async {



    if(controller.isEmpty){

      return;

    }




    final imagem =

    await controller.toPngBytes();




    if(imagem != null){

      widget.onConfirmar(imagem);

    }



  }







  @override
  Widget build(BuildContext context) {


    return Scaffold(



      appBar: AppBar(

        title:
        const Text(
            "Assinatura"
        ),

      ),





      body:

      Column(

        children: [




          Expanded(


            child:

            Container(


              margin:
              const EdgeInsets.all(20),


              decoration:

              BoxDecoration(

                border:

                Border.all(

                  color:
                  Colors.grey,

                ),

              ),




              child:

              Signature(

                controller:
                controller,


                backgroundColor:
                Colors.white,


              ),


            ),


          ),





          Row(

            mainAxisAlignment:
            MainAxisAlignment.spaceEvenly,


            children: [



              ElevatedButton(

                onPressed: (){

                  controller.clear();

                },


                child:

                const Text(
                    "Limpar"
                ),

              ),





              ElevatedButton(

                onPressed:

                confirmar,


                child:

                const Text(
                    "Confirmar"
                ),

              ),



            ],


          ),



          const SizedBox(height:20),



        ],


      ),


    );

  }



}