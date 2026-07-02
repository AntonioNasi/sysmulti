import 'package:sqflite/sqflite.dart';
import 'package:edumov/database/database_helper.dart';
import 'package:edumov/models/membro.dart';

class DatabaseService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Inserir membro
  Future<int> inserirMembro(Membro membro) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'membros',
      membro.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Buscar todos os membros
  Future<List<Membro>> buscarTodosMembros() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('membros');
    return List.generate(maps.length, (i) => Membro.fromMap(maps[i]));
  }

  // Buscar membro por email
  Future<Membro?> buscarMembroPorEmail(String email) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'membros',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return Membro.fromMap(maps.first);
    }
    return null;
  }

  // Atualizar membro
  Future<int> atualizarMembro(Membro membro) async {
    final db = await _dbHelper.database;
    return await db.update(
      'membros',
      membro.toMap(),
      where: 'id = ?',
      whereArgs: [membro.id],
    );
  }

  // Deletar membro
  Future<int> deletarMembro(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'membros',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}