import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../database/database_helper.dart';
import '../models/escola.dart';
import '../models/tecnico.dart';
import '../models/atividade.dart';
import '../data/tipos_atividade.dart';
import '../data/equipe_padrao.dart';
import '../widgets/assinatura_pad.dart';
import '../services/pdf_service.dart';

class NovaAtividadeScreen extends StatefulWidget {
  const NovaAtividadeScreen({super.key});

  @override
  State<NovaAtividadeScreen> createState() => _NovaAtividadeScreenState();
}

class _NovaAtividadeScreenState extends State<NovaAtividadeScreen> {
  List<Escola> escolas = [];
  List<Tecnico> tecnicos = []; // Técnicos do banco de dados
  List<Tecnico> equipe = [];    // Equipe padrão

  Escola? escolaSelecionada;
  Tecnico? membroEquipeSelecionado; // Membro da equipe (da equipe padrão)

  String? tipoSelecionado;

  final Map<String, dynamic> dados = {};

  Uint8List? assinaturaEscola;
  String nomeResponsavel = "";
  String funcaoResponsavel = "Diretor";

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final e = await DatabaseHelper.instance.listarEscolas();
    final t = await DatabaseHelper.instance.listarTecnicos();

    setState(() {
      escolas = e;
      tecnicos = t;
      equipe = EquipePadrao.equipe;

      escolaSelecionada = null;
      membroEquipeSelecionado = null;
    });
  }

  Future<void> abrirAssinatura() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return AssinaturaPad(
            onConfirmar: (imagem) {
              setState(() {
                assinaturaEscola = imagem;
              });
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  Future<void> _gerarPDF(Atividade atividade) async {
  try {
    final escola = await DatabaseHelper.instance.getEscolaById(
      escolaSelecionada!.id!,
    );

    if (escola == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao carregar dados para o PDF'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Criar um técnico temporário com os dados do membro da equipe
    final tecnico = Tecnico(
      id: null,
      nome: membroEquipeSelecionado!.nome,
      nomeCompleto: membroEquipeSelecionado!.nomeCompleto,
      assinatura: membroEquipeSelecionado!.assinatura,
      cargo: membroEquipeSelecionado!.cargo, // ADICIONAR CARGO
    );

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

  Future<void> salvarAtividade() async {
    // Validar formulário
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos obrigatórios'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validações adicionais
    if (escolaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma escola'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (membroEquipeSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um membro da equipe'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (tipoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o tipo de atividade'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (nomeResponsavel.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o nome do responsável'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (assinaturaEscola == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Capture a assinatura do responsável'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Adicionar o membro da equipe aos dados
    dados['membroEquipe'] = membroEquipeSelecionado!.nomeCompleto;
    dados['membroEquipeAssinatura'] = membroEquipeSelecionado!.assinatura;

    final atividade = Atividade(
      escolaId: escolaSelecionada!.id!,
      tecnicoId: 0, // Não usamos mais técnico do banco
      municipio: "Capistrano",
      tipo: tipoSelecionado!,
      data: DateTime.now().toIso8601String(),
      dados: jsonEncode(dados),
      assinaturaEscola: assinaturaEscola == null
          ? null
          : base64Encode(assinaturaEscola!),
      nomeResponsavelAssinatura: nomeResponsavel,
      funcaoResponsavelAssinatura: funcaoResponsavel,
    );

    try {
      await DatabaseHelper.instance.inserirAtividade(atividade);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atividade salva com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      final gerarPDF = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Gerar PDF'),
          content: const Text(
            'A atividade foi salva com sucesso!\n'
            'Deseja gerar o PDF agora?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Não'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sim'),
            ),
          ],
        ),
      );

      if (gerarPDF == true) {
        await _gerarPDF(atividade);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar atividade: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget construirCampos() {
  // Se não houver tipo selecionado, retorna vazio
  if (tipoSelecionado == null || tipoSelecionado!.isEmpty) {
    return const SizedBox.shrink();
  }

  final atividade = tiposAtividade.firstWhere(
    (item) => item["nome"] == tipoSelecionado,
    orElse: () => {"nome": "", "campos": []},
  );

  final List<dynamic> campos = atividade["campos"] ?? [];

  if (campos.isEmpty) {
    return const SizedBox.shrink();
  }

  return Column(
    children: campos.map<Widget>((campo) {
      final campoNome = campo.toString();
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          maxLines: null, // ← PERMITE MÚLTIPLAS LINHAS
          minLines: 1,    // ← COMEÇA COM 1 LINHA
          keyboardType: TextInputType.multiline, // ← HABILITA QUEBRA DE LINHA
          textInputAction: TextInputAction.newline, // ← BOTÃO "ENTER" PARA QUEBRA
          decoration: InputDecoration(
            labelText: campoNome,
            border: const OutlineInputBorder(),
            // Opcional: adicionar um fundo para melhor visualização
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (valor) {
            dados[campoNome] = valor;
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Preencha o campo $campoNome';
            }
            return null;
          },
        ),
      );
    }).toList(),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nova Atividade"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: salvarAtividade,
            tooltip: 'Salvar atividade',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Dropdown: Escola
                DropdownButton<Escola>(
                  isExpanded: true,
                  value: escolaSelecionada,
                  hint: const Text("Selecione a escola"),
                  items: escolas.map<DropdownMenuItem<Escola>>((Escola e) {
                    return DropdownMenuItem<Escola>(
                      value: e,
                      child: Text(e.nome),
                    );
                  }).toList(),
                  onChanged: (Escola? valor) {
                    setState(() {
                      escolaSelecionada = valor;
                    });
                  },
                ),

                const SizedBox(height: 15),

                // Município fixo
                const Text(
                  "Município: Capistrano",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                // Dropdown: Membro da Equipe (Usa o model Tecnico)
                DropdownButton<Tecnico>(
                  isExpanded: true,
                  value: membroEquipeSelecionado,
                  hint: const Text("Selecione o membro da equipe"),
                  items: equipe.map<DropdownMenuItem<Tecnico>>(
                    (Tecnico membro) {
                      return DropdownMenuItem<Tecnico>(
                        value: membro,
                        child: Text(membro.nome),
                      );
                    },
                  ).toList(),
                  onChanged: (Tecnico? valor) {
                    setState(() {
                      membroEquipeSelecionado = valor;
                    });
                  },
                ),

                const SizedBox(height: 15),

                // Dropdown: Tipo de atividade
                DropdownButton<String>(
                  isExpanded: true,
                  value: tipoSelecionado,
                  hint: const Text("Tipo de atividade"),
                  items: tiposAtividade
                      .map<DropdownMenuItem<String>>(
                        (item) {
                          return DropdownMenuItem<String>(
                            value: item["nome"].toString(),
                            child: Text(item["nome"].toString()),
                          );
                        },
                      )
                      .toList(),
                  onChanged: (String? valor) {
                    setState(() {
                      tipoSelecionado = valor;
                      dados.clear();
                    });
                  },
                ),

                const SizedBox(height: 20),

                // Campos dinâmicos
                if (tipoSelecionado != null && tipoSelecionado!.isNotEmpty)
                  construirCampos(),

                const SizedBox(height: 20),

                // Nome do responsável da escola
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Nome do responsável da escola",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (valor) {
                    nomeResponsavel = valor;
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o nome do responsável';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // Dropdown: Função do responsável
                DropdownButton<String>(
                  value: funcaoResponsavel,
                  isExpanded: true,
                  items: <String>[
                    "Diretor",
                    "Coordenador pedagógico",
                    "Secretário",
                    "Professor",
                    "Outro"
                  ].map<DropdownMenuItem<String>>(
                    (String funcao) {
                      return DropdownMenuItem<String>(
                        value: funcao,
                        child: Text(funcao),
                      );
                    },
                  ).toList(),
                  onChanged: (String? valor) {
                    setState(() {
                      funcaoResponsavel = valor!;
                    });
                  },
                ),

                const SizedBox(height: 15),

                // Botão de assinatura
                ElevatedButton.icon(
                  onPressed: abrirAssinatura,
                  icon: Icon(
                    assinaturaEscola == null ? Icons.edit : Icons.check_circle,
                    color: assinaturaEscola == null ? null : Colors.white,
                  ),
                  label: Text(
                    assinaturaEscola == null
                        ? "Assinar responsável"
                        : "Assinatura registrada ✓",
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    foregroundColor: Colors.white,
                    backgroundColor: assinaturaEscola == null
                        ? Colors.teal
                        : Colors.green,
                  ),
                ),

                const SizedBox(height: 25),

                // Botão Salvar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: salvarAtividade,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: const Text(
                      "Salvar atividade",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}