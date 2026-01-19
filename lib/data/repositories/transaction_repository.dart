import '../datasources/sqlite_service.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final SqliteService _dbService = SqliteService();

  Future<List<TransactionModel>> getTransactions() async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: "date DESC",
    );
    return List.generate(maps.length, (i) => TransactionModel.fromMap(maps[i]));
  }

  Future<void> addTransaction(TransactionModel t) async {
    final db = await _dbService.database;
    await db.insert('transactions', t.toMap());
  }

  Future<void> deleteTransaction(String id) async {
    final db = await _dbService.database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
