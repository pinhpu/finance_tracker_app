import '../../../data/models/transaction_model.dart';
import '../../../data/repositories/transaction_repository.dart';

class HomeController {
  final TransactionRepository _repo = TransactionRepository();

  Future<List<TransactionModel>> getTransactions() {
    return _repo.getTransactions();
  }

  Future<void> deleteTransaction(String id) {
    return _repo.deleteTransaction(id);
  }
}
