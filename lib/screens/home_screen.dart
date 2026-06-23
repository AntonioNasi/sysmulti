import 'package:flutter/material.dart';


class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          'Relatório de Visitas',
        ),
      ),


      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,


          children: [


            ElevatedButton.icon(

              icon: const Icon(Icons.add),

              label: const Text(
                'Nova Visita',
              ),

              onPressed: () {},

            ),



            const SizedBox(height: 20),



            ElevatedButton.icon(

              icon: const Icon(Icons.school),

              label: const Text(
                'Escolas',
              ),

              onPressed: () {},

            ),



            const SizedBox(height: 20),



            ElevatedButton.icon(

              icon: const Icon(Icons.history),

              label: const Text(
                'Histórico',
              ),

              onPressed: () {},

            ),


          ],

        ),

      ),

    );

  }

}