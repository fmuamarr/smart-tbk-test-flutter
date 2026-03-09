import '../entities/reverse_result.dart';
import '../repositories/number_repository.dart';

class CalculateReverseDifferenceUseCase {
  final NumberRepository repository;

  CalculateReverseDifferenceUseCase(this.repository);

  Future<ReverseResult> execute(int number) {
    return repository.calculateReverseDifference(number);
  }
}
