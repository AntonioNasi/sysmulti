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
  final diretor = TextEditingController();

  List<Escola> escolas = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    setState(() {
      carregando = true;
    });

    try {
      escolas = await DatabaseHelper.instance.listarEscolas();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar escolas: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          carregando = false;
        });
      }
    }
  }

  Future<void> salvar() async {
    if (nome.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O nome da escola é obrigatório'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (diretor.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O nome do diretor é obrigatório'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final escola = Escola(
        nome: nome.text.trim(),
        diretor: diretor.text.trim(),
      );

      await DatabaseHelper.instance.inserirEscola(escola);

      nome.clear();
      diretor.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escola cadastrada com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      await carregar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar escola: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> excluirEscola(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir esta escola?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DatabaseHelper.instance.excluirEscola(id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Escola excluída com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        await carregar();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir escola: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolas'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: carregar,
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Formulário de cadastro
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: nome,
                      decoration: const InputDecoration(
                        labelText: 'Nome da escola',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.school),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: diretor,
                      decoration: const InputDecoration(
                        labelText: 'Diretor(a)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: salvar,
                        icon: const Icon(Icons.save),
                        label: const Text(
                          'Cadastrar Escola',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Contador de escolas
            Text(
              'Total de escolas: ${escolas.length}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Lista de escolas
            Expanded(
              child: carregando
                  ? const Center(child: CircularProgressIndicator())
                  : escolas.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhuma escola cadastrada',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: escolas.length,
                          itemBuilder: (context, index) {
                            final escola = escolas[index];
                            return Card(
                              elevation: 1,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade100,
                                  child: Text(
                                    escola.nome[0].toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.blue.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  escola.nome,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Diretor: ${escola.diretor}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => excluirEscola(escola.id!),
                                  tooltip: 'Excluir escola',
                                ),
                                onTap: () {
                                  // Aqui você pode adicionar navegação para detalhes
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}