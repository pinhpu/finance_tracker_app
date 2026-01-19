import '../../../data/models/transaction_model.dart';
import '../../../data/repositories/transaction_repository.dart';

class TransactionController {
  final TransactionRepository _repo = TransactionRepository();

  Future<void> addTransaction(TransactionModel tx) {
    return _repo.addTransaction(tx);
  }
}
