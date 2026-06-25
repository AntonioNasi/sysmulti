import 'package:flutter/material.dart';
import 'escolas_screen.dart';
import 'nova_atividade_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            'assets/icon/app_icon.png', // Caminho do ícone
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
        ),
        title: const Text('Equipe Multiprofissional - SME'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botão 1 - Nova Atividade
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.assignment_add),
                label: const Text('Nova Atividade'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NovaAtividadeScreen(),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Botão 2 - Escolas
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: ElevatedButton.icon(
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
            ),
            
            const SizedBox(height: 20),
            
            // Botão 3 - Histórico
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.history),
                label: const Text('Histórico'),
                onPressed: () {
                  // futuro: tela de histórico
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}