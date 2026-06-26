import 'dart:typed_data';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:printing/printing.dart';

import '../models/atividade.dart';
import '../models/escola.dart';
import '../models/tecnico.dart';

class PdfService {
  // Constantes
  static const double margin = 2 * PdfPageFormat.cm;
  static const double fontSize = 12;
  static const double fontSizeTitle = 14;
  
  // Versão do app
  static const String versaoApp = '1.0.0';
  
  // Município fixo
  static const String municipio = 'Capistrano';

  /// Gera o PDF da atividade com o layout especificado
  static Future<Uint8List> gerarPdfAtividade({
    required Atividade atividade,
    required Escola escola,
    required Tecnico tecnico,
  }) async {
    final pdf = pw.Document();

    // Carregar logos
    final logoSecretaria = await _loadImage('assets/logo_secretaria.png');
    final logoEquipe = await _loadImage('assets/logo_equipe.png');
    
    // Carregar imagens adicionais
    final imagemCabecalho = await _loadImage('assets/imagens/cabecalho.png');
    final imagemRodape = await _loadImage('assets/imagens/rodape.png');

    // Decodificar dados da atividade
    Map<String, dynamic> dados;
    try {
      dados = jsonDecode(atividade.dados);
    } catch (e) {
      dados = {};
    }

    // Remover campos internos dos dados para não aparecerem no PDF
    final camposParaExibir = Map<String, dynamic>.from(dados);
    camposParaExibir.remove('membroEquipe');
    camposParaExibir.remove('membroEquipeAssinatura');

    // Carregar a assinatura do membro da equipe
    String assinaturaPath = dados['membroEquipeAssinatura'] ?? tecnico.assinatura;
    pw.MemoryImage? assinaturaMembro;
    if (assinaturaPath.isNotEmpty) {
      assinaturaMembro = await _loadImage(assinaturaPath);
    }

    // Carregar assinatura do responsável
    pw.MemoryImage? assinaturaResponsavel;
    if (atividade.assinaturaEscola != null && atividade.assinaturaEscola!.isNotEmpty) {
      try {
        final bytes = base64Decode(atividade.assinaturaEscola!);
        assinaturaResponsavel = pw.MemoryImage(bytes);
      } catch (e) {
        // Se falhar, ignora
      }
    }

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(margin),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ===== IMAGEM DO CABEÇALHO =====
              if (imagemCabecalho != null)
                pw.Center(
                  child: pw.Image(
                    imagemCabecalho,
                    width: 300,
                    height: 60,
                    fit: pw.BoxFit.contain,
                  ),
                ),
              
              pw.SizedBox(height: 10),
              
              // ===== CABEÇALHO =====
              _buildHeader(logoSecretaria, logoEquipe),
              
              pw.SizedBox(height: 10),
              
              // ===== TÍTULO =====
              _buildTitle(),
              
              pw.SizedBox(height: 20),
              
              // ===== INFORMAÇÕES DA ESCOLA =====
              _buildEscolaInfo(escola),
              
              pw.SizedBox(height: 20),
              
              // ===== CAMPOS DA ATIVIDADE =====
              _buildCamposAtividade(atividade, camposParaExibir),
              
              pw.SizedBox(height: 30),
              
              // ===== ASSINATURAS EM DUAS COLUNAS =====
              _buildAssinaturas(
                atividade: atividade,
                tecnico: tecnico,
                dados: dados,
                assinaturaMembro: assinaturaMembro,
                assinaturaResponsavel: assinaturaResponsavel,
              ),
              
              pw.SizedBox(height: 20),
              
              // ===== IMAGEM DO RODAPÉ =====
              if (imagemRodape != null)
                pw.Center(
                  child: pw.Image(
                    imagemRodape,
                    width: 200,
                    height: 60,
                    fit: pw.BoxFit.contain,
                  ),
                ),
              
              pw.SizedBox(height: 10),
              
              // ===== RODAPÉ =====
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }

  /// Carrega imagem dos assets
  static Future<pw.MemoryImage?> _loadImage(String path) async {
    try {
      final byteData = await rootBundle.load(path);
      return pw.MemoryImage(byteData.buffer.asUint8List());
    } catch (e) {
      print('Erro ao carregar imagem: $path - $e');
      return null;
    }
  }

  /// Constrói o cabeçalho com as logos lado a lado
  static pw.Widget _buildHeader(pw.MemoryImage? logoSecretaria, pw.MemoryImage? logoEquipe) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        if (logoSecretaria != null)
          pw.Image(
            logoSecretaria,
            width: 60,
            height: 60,
            fit: pw.BoxFit.contain,
          ),
        
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'Equipe Multiprofissional - SME',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        if (logoEquipe != null)
          pw.Image(
            logoEquipe,
            width: 60,
            height: 60,
            fit: pw.BoxFit.contain,
          ),
      ],
    );
  }

  /// Título do documento
  static pw.Widget _buildTitle() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 8),
        pw.Text(
          'Registro de Atividade',
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 1),
      ],
    );
  }

  /// Informações da escola
  static pw.Widget _buildEscolaInfo(Escola escola) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Escola: ${escola.nome}',
          style: pw.TextStyle(
            fontSize: fontSizeTitle,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Diretor(a): ${escola.diretor}',
          style: pw.TextStyle(
            fontSize: fontSizeTitle,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Município: $municipio',
          style: pw.TextStyle(
            fontSize: fontSizeTitle,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Constrói os campos da atividade dentro de caixas
  static pw.Widget _buildCamposAtividade(Atividade atividade, Map<String, dynamic> dados) {
    // Adicionar campos padrão
    final Map<String, String> campos = {
      'Tipo de Atividade': atividade.tipo,
      'Data': _formatDate(atividade.data),
      ...dados.map((key, value) => MapEntry(key, value.toString())),
    };

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: campos.entries.map((entry) {
        return _buildCampoComCaixa(entry.key, entry.value);
      }).toList(),
    );
  }

  /// Constrói um campo com caixa
  static pw.Widget _buildCampoComCaixa(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          width: double.infinity,
          padding: pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(
              color: PdfColors.black,
              width: 1,
            ),
          ),
          child: pw.Text(
            value.isEmpty ? ' ' : value,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: pw.FontWeight.normal,
            ),
          ),
        ),
        pw.SizedBox(height: 12),
      ],
    );
  }

  /// Constrói as assinaturas em duas colunas
  static pw.Widget _buildAssinaturas({
    required Atividade atividade,
    required Tecnico tecnico,
    required Map<String, dynamic> dados,
    required pw.MemoryImage? assinaturaMembro,
    required pw.MemoryImage? assinaturaResponsavel,
  }) {
    // Nome do membro da equipe
    String nomeMembroEquipe = dados['membroEquipe'] ?? tecnico.nomeCompleto;
    
    // Cargo do membro da equipe
    String cargoMembroEquipe = tecnico.cargo;
    
    // Nome do responsável da escola
    String nomeResponsavel = atividade.nomeResponsavelAssinatura ?? 'Responsável não informado';
    String funcaoResponsavel = atividade.funcaoResponsavelAssinatura ?? '';

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 15),
        
        // Título da seção
        pw.Center(
          child: pw.Text(
            'ASSINATURAS',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        
        pw.SizedBox(height: 20),
        
        // Duas colunas
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            // Coluna 1: Membro da Equipe
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Assinatura do membro da equipe (imagem)
                  _buildAssinaturaMembroWidget(assinaturaMembro),
                  
                  pw.SizedBox(height: 8),
                  
                  // Nome do membro da equipe em caixa alta
                  pw.Text(
                    nomeMembroEquipe.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: fontSize,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  
                  pw.SizedBox(height: 4),
                  
                  // Cargo do membro da equipe
                  pw.Text(
                    cargoMembroEquipe.isNotEmpty ? cargoMembroEquipe : 'Membro da Equipe',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(width: 30),
            
            // Coluna 2: Responsável pela Escola
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Assinatura do responsável (capturada na tela)
                  _buildAssinaturaResponsavelWidget(assinaturaResponsavel),
                  
                  pw.SizedBox(height: 8),
                  
                  // Nome do responsável em caixa alta
                  pw.Text(
                    nomeResponsavel.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: fontSize,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  
                  pw.SizedBox(height: 4),
                  
                  pw.Text(
                    funcaoResponsavel.isNotEmpty ? funcaoResponsavel : 'Responsável pela Escola',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
        
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 1),
      ],
    );
  }

  /// Constrói o widget da assinatura do membro da equipe
  static pw.Widget _buildAssinaturaMembroWidget(pw.MemoryImage? assinatura) {
    if (assinatura != null) {
      return pw.Container(
        width: 180,
        height: 50,
        decoration: pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(
              color: PdfColors.black,
              width: 1,
            ),
          ),
        ),
        child: pw.Center(
          child: pw.Image(
            assinatura,
            width: 160,
            height: 40,
            fit: pw.BoxFit.contain,
          ),
        ),
      );
    }

    return pw.Container(
      width: 180,
      height: 50,
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.black,
            width: 1,
          ),
        ),
      ),
      child: pw.Center(
        child: pw.Text(
          '(Assinatura não disponível)',
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey,
          ),
        ),
      ),
    );
  }

  /// Constrói o widget da assinatura do responsável
  static pw.Widget _buildAssinaturaResponsavelWidget(pw.MemoryImage? assinatura) {
    if (assinatura != null) {
      return pw.Container(
        width: 180,
        height: 50,
        decoration: pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(
              color: PdfColors.black,
              width: 1,
            ),
          ),
        ),
        child: pw.Center(
          child: pw.Image(
            assinatura,
            width: 160,
            height: 40,
            fit: pw.BoxFit.contain,
          ),
        ),
      );
    }

    return pw.Container(
      width: 180,
      height: 50,
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.black,
            width: 1,
          ),
        ),
      ),
      child: pw.Center(
        child: pw.Text(
          '(Assinatura não capturada)',
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey,
          ),
        ),
      ),
    );
  }

  /// Rodapé com SysMulti e versão
  static pw.Widget _buildFooter() {
    return pw.Container(
      margin: pw.EdgeInsets.only(top: 10),
      child: pw.Column(
        children: [
          pw.Divider(thickness: 1),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              'SysMulti $versaoApp',
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Formata a data
  static String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year} ${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  /// Método para gerar e compartilhar o PDF
  static Future<void> gerarECompartilharPdf({
    required Atividade atividade,
    required Escola escola,
    required Tecnico tecnico,
  }) async {
    final pdfBytes = await gerarPdfAtividade(
      atividade: atividade,
      escola: escola,
      tecnico: tecnico,
    );
    
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'atividade_${escola.nome.replaceAll(' ', '_')}.pdf',
    );
  }
}