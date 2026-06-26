import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/escola.dart';
import '../models/tecnico.dart';
import '../models/atividade.dart';
import '../data/escolas_padrao.dart'; // IMPORT CORRETO

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('visitas.db');
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

    // Tabela tecnicos
    await db.execute('''
      CREATE TABLE tecnicos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        cargo TEXT NOT NULL
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
  }

  // Método para inserir escolas padrão usando o arquivo importado
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

  // Método para verificar se já existem escolas no banco
  Future<bool> temEscolas() async {
    final db = await instance.database;
    final result = await db.query('escolas', limit: 1);
    return result.isNotEmpty;
  }

  // Método para resetar o banco
  Future<void> resetarBanco() async {
    final db = await instance.database;
    await db.delete('atividades');
    await db.delete('escolas');
    await db.delete('tecnicos');
    await _inserirEscolasPadrao(db);
  }

  // ========== MÉTODOS PARA ESCOLAS ==========

  Future<int> inserirEscola(Escola escola) async {
    final db = await instance.database;
    return await db.insert(
      'escolas',
      escola.toMap(),
    );
  }

  Future<List<Escola>> listarEscolas() async {
    final db = await instance.database;
    final result = await db.query('escolas');
    return result.map((e) => Escola.fromMap(e)).toList();
  }

  Future<Escola?> getEscolaById(int id) async {
    final db = await instance.database;
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
    final db = await instance.database;
    return await db.update(
      'escolas',
      escola.toMap(),
      where: 'id = ?',
      whereArgs: [escola.id],
    );
  }

  Future<int> excluirEscola(int id) async {
    final db = await instance.database;
    return await db.delete(
      'escolas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== MÉTODOS PARA TÉCNICOS ==========

  Future<int> inserirTecnico(Tecnico tecnico) async {
    final db = await instance.database;
    return await db.insert(
      'tecnicos',
      tecnico.toMap(),
    );
  }

  Future<List<Tecnico>> listarTecnicos() async {
    final db = await instance.database;
    final result = await db.query('tecnicos');
    return result.map((e) => Tecnico.fromMap(e)).toList();
  }

  Future<Tecnico?> getTecnicoById(int id) async {
    final db = await instance.database;
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
    final db = await instance.database;
    return await db.update(
      'tecnicos',
      tecnico.toMap(),
      where: 'id = ?',
      whereArgs: [tecnico.id],
    );
  }

  Future<int> excluirTecnico(int id) async {
    final db = await instance.database;
    return await db.delete(
      'tecnicos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== MÉTODOS PARA ATIVIDADES ==========

  Future<int> inserirAtividade(Atividade atividade) async {
    final db = await instance.database;
    return await db.insert(
      'atividades',
      atividade.toMap(),
    );
  }

  Future<List<Atividade>> listarAtividades() async {
    final db = await instance.database;
    final result = await db.query('atividades');
    return result.map((e) => Atividade.fromMap(e)).toList();
  }

  Future<Atividade?> getAtividadeById(int id) async {
    final db = await instance.database;
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
    final db = await instance.database;
    return await db.update(
      'atividades',
      atividade.toMap(),
      where: 'id = ?',
      whereArgs: [atividade.id],
    );
  }

  Future<int> excluirAtividade(int id) async {
    final db = await instance.database;
    return await db.delete(
      'atividades',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> listarAtividadesCompleto() async {
  final db = await instance.database;
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
}