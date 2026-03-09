import '../entities/reverse_result.dart';

abstract class NumberRepository {
  Future<ReverseResult> calculateReverseDifference(int number);
}
