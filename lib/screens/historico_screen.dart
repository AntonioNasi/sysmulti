import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../database/database_helper.dart';
import '../models/atividade.dart';
import '../models/escola.dart';
import '../models/tecnico.dart';
import '../services/pdf_service.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  List<Map<String, dynamic>> atividades = [];
  bool carregando = true;
  String? filtroTipo;
  String? filtroEscola;

  List<String> tiposDisponiveis = [];
  List<String> escolasDisponiveis = [];

  @override
  void initState() {
    super.initState();
    carregarHistorico();
  }

  Future<void> carregarHistorico() async {
    setState(() {
      carregando = true;
    });

    try {
      // Buscar atividades com dados completos
      final atividadesCompletas = await DatabaseHelper.instance.listarAtividadesCompleto();
      
      print('📊 Total de atividades encontradas: ${atividadesCompletas.length}');
      
      // Extrair tipos e escolas para os filtros
      final tipos = <String>{};
      final escolas = <String>{};
      
      for (var item in atividadesCompletas) {
        if (item['tipo'] != null) {
          tipos.add(item['tipo'] as String);
        }
        if (item['escola_nome'] != null) {
          escolas.add(item['escola_nome'] as String);
        }
      }

      setState(() {
        atividades = atividadesCompletas;
        tiposDisponiveis = tipos.toList()..sort();
        escolasDisponiveis = escolas.toList()..sort();
        carregando = false;
      });
    } catch (e) {
      print('❌ Erro ao carregar histórico: $e');
      setState(() {
        carregando = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar histórico: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> get atividadesFiltradas {
    var lista = atividades;
    
    if (filtroTipo != null && filtroTipo!.isNotEmpty) {
      lista = lista.where((item) => item['tipo'] == filtroTipo).toList();
    }
    
    if (filtroEscola != null && filtroEscola!.isNotEmpty) {
      lista = lista.where((item) => item['escola_nome'] == filtroEscola).toList();
    }
    
    return lista;
  }

  Future<void> _gerarPDF(Atividade atividade, Escola escola, Tecnico tecnico) async {
    try {
      final pdfBytes = await PdfService.gerarPdfAtividade(
        atividade: atividade,
        escola: escola,
        tecnico: tecnico,
      );
      
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'atividade_${escola.nome.replaceAll(' ', '_')}.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _excluirAtividade(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja excluir esta atividade?'),
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
        await DatabaseHelper.instance.excluirAtividade(id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Atividade excluída com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        await carregarHistorico();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir atividade: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatarData(String dataStr) {
    try {
      final data = DateTime.parse(dataStr);
      return '${data.day.toString().padLeft(2, '0')}/'
          '${data.month.toString().padLeft(2, '0')}/'
          '${data.year} ${data.hour.toString().padLeft(2, '0')}:'
          '${data.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dataStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Histórico de Atividades',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: carregarHistorico,
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          if (atividades.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: filtroTipo,
                      hint: const Text('Todos os tipos'),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Todos os tipos'),
                        ),
                        ...tiposDisponiveis.map((tipo) {
                          return DropdownMenuItem<String>(
                            value: tipo,
                            child: Text(tipo),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          filtroTipo = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: filtroEscola,
                      hint: const Text('Todas as escolas'),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Todas as escolas'),
                        ),
                        ...escolasDisponiveis.map((escola) {
                          return DropdownMenuItem<String>(
                            value: escola,
                            child: Text(escola),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          filtroEscola = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Lista de atividades
          Expanded(
            child: carregando
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : atividades.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Nenhuma atividade registrada',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Registre uma nova atividade no menu principal',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: atividadesFiltradas.length,
                        itemBuilder: (context, index) {
                          final item = atividadesFiltradas[index];
                          
                          // Verificar se os dados existem
                          final escolaNome = item['escola_nome'] ?? 'Escola não informada';
                          final escolaDiretor = item['escola_diretor'] ?? 'Diretor não informado';
                          final tecnicoNome = item['tecnico_nome'] ?? 'Técnico não informado';
                          
                          // Converter para objetos
                          final atividade = Atividade(
                            id: item['id'],
                            escolaId: item['escolaId'] ?? 0,
                            tecnicoId: item['tecnicoId'] ?? 0,
                            municipio: item['municipio'] ?? 'Capistrano',
                            tipo: item['tipo'] ?? 'Não informado',
                            data: item['data'] ?? DateTime.now().toIso8601String(),
                            dados: item['dados'] ?? '{}',
                            assinaturaEscola: item['assinaturaEscola'],
                            nomeResponsavelAssinatura: item['nomeResponsavelAssinatura'],
                            funcaoResponsavelAssinatura: item['funcaoResponsavelAssinatura'],
                          );

                          final escola = Escola(
                            id: item['escolaId'] ?? 0,
                            nome: escolaNome,
                            diretor: escolaDiretor,
                          );

                          final tecnico = Tecnico(
                            id: item['tecnicoId'] ?? 0,
                            nome: tecnicoNome,
                            nomeCompleto: tecnicoNome,
                            assinatura: '',
                            cargo: item['tecnico_cargo'] ?? '',
                          );

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  item['tipo']?.substring(0, 1).toUpperCase() ?? 'A',
                                  style: TextStyle(
                                    color: Colors.blue.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                escolaNome,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tipo: ${item['tipo'] ?? 'Não informado'}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    'Data: ${_formatarData(item['data'] ?? DateTime.now().toIso8601String())}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.picture_as_pdf,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      await _gerarPDF(atividade, escola, tecnico);
                                    },
                                    tooltip: 'Gerar PDF',
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _excluirAtividade(atividade.id!),
                                    tooltip: 'Excluir',
                                  ),
                                ],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildDetailRow('Escola', escolaNome),
                                      _buildDetailRow('Diretor', escolaDiretor),
                                      _buildDetailRow('Técnico', tecnicoNome),
                                      _buildDetailRow('Cargo', item['tecnico_cargo'] ?? 'Não informado'),
                                      _buildDetailRow('Tipo', item['tipo'] ?? 'Não informado'),
                                      _buildDetailRow('Data', _formatarData(item['data'] ?? DateTime.now().toIso8601String())),
                                      _buildDetailRow('Responsável', item['nomeResponsavelAssinatura'] ?? 'Não informado'),
                                      _buildDetailRow('Função', item['funcaoResponsavelAssinatura'] ?? 'Não informado'),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Dados da Atividade:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Text(
                                          item['dados'] ?? 'Sem dados',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}