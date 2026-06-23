import 'package:flutter/material.dart';

import 'escolas_screen.dart';


class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('Relatório de Visitas'),
      ),


      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [


            ElevatedButton.icon(

              icon: const Icon(Icons.add),

              label: const Text('Nova Visita'),

              onPressed: () {
                // futuro: tela de nova visita
              },

            ),


            const SizedBox(height: 20),


            ElevatedButton.icon(

              icon: const Icon(Icons.school),

              label: const Text('Escolas'),

              onPressed: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(

                    builder: (_) => const EscolasScreen(),

                  ),

                );

              },

            ),


            const SizedBox(height: 20),


            ElevatedButton.icon(

              icon: const Icon(Icons.history),

              label: const Text('Histórico'),

              onPressed: () {
                // futuro: tela de histórico
              },

            ),


          ],

        ),

      ),

    );

  }

}