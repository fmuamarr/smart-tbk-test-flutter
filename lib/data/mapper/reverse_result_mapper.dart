import '../../domain/entities/reverse_result.dart';
import '../model/calculate_response_model.dart';

class ReverseResultMapper {
  static ReverseResult fromModel(CalculateResponseModel model) {
    return ReverseResult(
      originalNumber: model.originalNumber,
      reversedNumber: model.reversedNumber,
      difference: model.difference,
    );
  }
}
