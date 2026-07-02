import 'package:sqflite/sqflite.dart';
import '../models/configuracao.dart';
import '../database/database_helper.dart';

class ConfigService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> salvarConfiguracao(Configuracao config) async {
    final db = await _dbHelper.database;
    // ✅ Usar o toMap() do modelo - que agora tem nome_tecnico
    return await db.insert(
      'configuracao',
      config.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Configuracao?> buscarConfiguracao() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('configuracao');
    if (maps.isNotEmpty) {
      return Configuracao.fromMap(maps.first);
    }
    return null;
  }

  Future<bool> isSetupConcluido() async {
    final config = await buscarConfiguracao();
    return config?.setupConcluido ?? false;
  }

  Future<int> atualizarConfiguracao(Configuracao config) async {
    final db = await _dbHelper.database;
    return await db.update(
      'configuracao',
      config.toMap(),
      where: 'id = ?',
      whereArgs: [config.id],
    );
  }

  Future<void> concluirSetup(Configuracao config) async {
    final configAtualizada = config.copyWith(setupConcluido: true);
    await salvarConfiguracao(configAtualizada);
  }
}