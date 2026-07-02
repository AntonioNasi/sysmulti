import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/configuracao.dart';
import '../models/escola.dart';
import '../models/tecnico.dart';
import '../models/atividade.dart';
import '../models/membro.dart';  // ← ADICIONAR
import '../data/escolas_padrao.dart';

class DatabaseHelper {
  // SINGLETON - Abordagem única e consistente
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;
  
  // Construtor factory - retorna a instância única
  factory DatabaseHelper() => _instance;
  
  // Construtor privado
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('edumov.db');  // ← Mudar nome para edumov.db
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    // Tabela escolas
    await db.execute('''
      CREATE TABLE escolas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        diretor TEXT NOT NULL
      )
    ''');

    // Tabela configuracao - ESTRUTURA CORRETA
await db.execute('''
  CREATE TABLE configuracao (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_tecnico TEXT NOT NULL,
    cargo TEXT,
    assinatura_path TEXT,
    municipio TEXT,
    logo_path TEXT,
    secretaria TEXT,
    uf TEXT,
    setup_concluido INTEGER DEFAULT 0,
    chave_licenca TEXT,
    data_expiracao TEXT,
    plano TEXT,
    assinatura_ativa INTEGER DEFAULT 0,
    cor_primaria TEXT,
    cor_secundaria TEXT,
    data_criacao TEXT NOT NULL,
    data_atualizacao TEXT
  )
''');

    // Tabela tecnicos
    await db.execute('''
      CREATE TABLE tecnicos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        cargo TEXT NOT NULL
      )
    ''');

    // Tabela membros
    await db.execute('''
      CREATE TABLE membros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        senha TEXT NOT NULL,
        tipo TEXT NOT NULL,
        ativo INTEGER DEFAULT 1,
        data_cadastro TEXT NOT NULL,
        ultimo_acesso TEXT,
        foto_path TEXT
      )
    ''');

    // Tabela atividades
    await db.execute('''
      CREATE TABLE atividades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        escolaId INTEGER NOT NULL,
        tecnicoId INTEGER NOT NULL,
        municipio TEXT NOT NULL,
        tipo TEXT NOT NULL,
        data TEXT NOT NULL,
        dados TEXT NOT NULL,
        assinaturaEscola TEXT,
        nomeResponsavelAssinatura TEXT,
        funcaoResponsavelAssinatura TEXT,
        FOREIGN KEY (escolaId) REFERENCES escolas (id),
        FOREIGN KEY (tecnicoId) REFERENCES tecnicos (id)
      )
    ''');

    // Inserir escolas padrão
    await _inserirEscolasPadrao(db);

    // Inserir configuração padrão
    await db.insert('configuracao', {
      'nome_tecnico': 'Técnico da SME',
      'cargo': '',
      'municipio': '',
      'logo_path': '',
      'setup_concluido': 0,
      'assinatura_ativa': 0,
      'cor_primaria': '#2196F3',
      'cor_secundaria': '#FF9800',
      'data_criacao': DateTime.now().toIso8601String(),
      'data_atualizacao': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _inserirEscolasPadrao(Database db) async {
    for (var escolaData in EscolasPadrao.escolas) {
      await db.insert(
        'escolas',
        {
          'nome': escolaData['nome'],
          'diretor': escolaData['diretor'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<bool> temEscolas() async {
    final db = await database;
    final result = await db.query('escolas', limit: 1);
    return result.isNotEmpty;
  }

  Future<void> resetarBanco() async {
    final db = await database;
    await db.delete('atividades');
    await db.delete('escolas');
    await db.delete('tecnicos');
    await _inserirEscolasPadrao(db);
  }

  Future<void> verificarEConfigurarSetup() async {
    final db = await database;
    final configs = await db.query('configuracao');
    
    if (configs.isEmpty) {
      await db.insert('configuracao', {
        'nome_tecnico': '',
        'cargo': '',
        'assinatura_path': '',
        'logo_path': '',
        'setup_concluido': 0,
        'assinatura_ativa': 0,
        'cor_primaria': '#2196F3',
        'cor_secundaria': '#FF9800',
        'data_criacao': DateTime.now().toIso8601String(),
        'data_atualizacao': DateTime.now().toIso8601String(),
      });
    }
  }

  // ========== MÉTODOS PARA ESCOLAS ==========

  Future<int> inserirEscola(Escola escola) async {
    final db = await database;
    return await db.insert('escolas', escola.toMap());
  }

  Future<List<Escola>> listarEscolas() async {
    final db = await database;
    final result = await db.query('escolas');
    return result.map((e) => Escola.fromMap(e)).toList();
  }

  Future<Escola?> getEscolaById(int id) async {
    final db = await database;
    final result = await db.query(
      'escolas',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Escola.fromMap(result.first);
    }
    return null;
  }

  Future<int> atualizarEscola(Escola escola) async {
    final db = await database;
    return await db.update(
      'escolas',
      escola.toMap(),
      where: 'id = ?',
      whereArgs: [escola.id],
    );
  }

  Future<int> excluirEscola(int id) async {
    final db = await database;
    return await db.delete(
      'escolas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== MÉTODOS PARA TÉCNICOS ==========

  Future<int> inserirTecnico(Tecnico tecnico) async {
    final db = await database;
    return await db.insert('tecnicos', tecnico.toMap());
  }

  Future<List<Tecnico>> listarTecnicos() async {
    final db = await database;
    final result = await db.query('tecnicos');
    return result.map((e) => Tecnico.fromMap(e)).toList();
  }

  Future<Tecnico?> getTecnicoById(int id) async {
    final db = await database;
    final result = await db.query(
      'tecnicos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Tecnico.fromMap(result.first);
    }
    return null;
  }

  Future<int> atualizarTecnico(Tecnico tecnico) async {
    final db = await database;
    return await db.update(
      'tecnicos',
      tecnico.toMap(),
      where: 'id = ?',
      whereArgs: [tecnico.id],
    );
  }

  Future<int> excluirTecnico(int id) async {
    final db = await database;
    return await db.delete(
      'tecnicos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== MÉTODOS PARA MEMBROS ==========

  Future<int> inserirMembro(Membro membro) async {
    final db = await database;
    return await db.insert(
      'membros',
      membro.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Membro>> listarMembros() async {
    final db = await database;
    final result = await db.query('membros');
    return result.map((e) => Membro.fromMap(e)).toList();
  }

  Future<Membro?> getMembroByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'membros',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) {
      return Membro.fromMap(result.first);
    }
    return null;
  }

  Future<int> atualizarMembro(Membro membro) async {
    final db = await database;
    return await db.update(
      'membros',
      membro.toMap(),
      where: 'id = ?',
      whereArgs: [membro.id],
    );
  }

  Future<int> excluirMembro(int id) async {
    final db = await database;
    return await db.delete(
      'membros',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== MÉTODOS PARA ATIVIDADES ==========

  Future<int> inserirAtividade(Atividade atividade) async {
    final db = await database;
    return await db.insert('atividades', atividade.toMap());
  }

  Future<List<Atividade>> listarAtividades() async {
    final db = await database;
    final result = await db.query('atividades');
    return result.map((e) => Atividade.fromMap(e)).toList();
  }

  Future<Atividade?> getAtividadeById(int id) async {
    final db = await database;
    final result = await db.query(
      'atividades',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Atividade.fromMap(result.first);
    }
    return null;
  }

  Future<int> atualizarAtividade(Atividade atividade) async {
    final db = await database;
    return await db.update(
      'atividades',
      atividade.toMap(),
      where: 'id = ?',
      whereArgs: [atividade.id],
    );
  }

  Future<int> excluirAtividade(int id) async {
    final db = await database;
    return await db.delete(
      'atividades',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> listarAtividadesCompleto() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT 
        a.*,
        e.nome as escola_nome,
        e.diretor as escola_diretor,
        t.nome as tecnico_nome,
        t.cargo as tecnico_cargo
      FROM atividades a
      INNER JOIN escolas e ON a.escolaId = e.id
      LEFT JOIN tecnicos t ON a.tecnicoId = t.id
      ORDER BY a.data DESC
    ''');
  }

  // ========== MÉTODOS PARA CONFIGURAÇÃO ==========

  Future<int> salvarConfiguracao(Configuracao config) async {
    final db = await database;
    
    final existing = await db.query('configuracao');
    if (existing.isNotEmpty) {
      return await db.update(
        'configuracao',
        config.toMap(),
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      return await db.insert('configuracao', config.toMap());
    }
  }

  Future<Configuracao?> buscarConfiguracao() async {
    final db = await database;
    final result = await db.query('configuracao');
    if (result.isNotEmpty) {
      return Configuracao.fromMap(result.first);
    }
    return null;
  }

  Future<bool> temConfiguracao() async {
    final db = await database;
    final result = await db.query('configuracao', limit: 1);
    return result.isNotEmpty;
  }
}