import '../../domain/entities/reverse_result.dart';
import '../../domain/repositories/number_repository.dart';

class NumberRepositoryImpl implements NumberRepository {
  @override
  Future<ReverseResult> calculateReverseDifference(int number) async {
    final absNumber = number.abs();
    final reversedStr = absNumber.toString().split('').reversed.join('');
    final reversed = int.parse(reversedStr);
    final difference = (absNumber - reversed).abs();

    return ReverseResult(
      originalNumber: absNumber,
      reversedNumber: reversed,
      difference: difference,
    );
  }
}
