import '../../domain/entities/reverse_result.dart';
import '../../domain/repositories/number_repository.dart';
import '../mapper/reverse_result_mapper.dart';
import '../model/calculate_response_model.dart';
import '../network/api_provider.dart';
import '../network/config.dart';

class ApiNumberRepositoryImpl implements NumberRepository {
  final ApiProvider apiProvider;

  ApiNumberRepositoryImpl(this.apiProvider);

  @override
  Future<ReverseResult> calculateReverseDifference(int number) async {
    final response = await apiProvider.call(
      ApiConfig.calculateEndpoint,
      method: MethodRequest.post,
      request: {'number': number},
    );

    final data = response['data'] as Map<String, dynamic>;
    final model = CalculateResponseModel.fromJson(data);
    return ReverseResultMapper.fromModel(model);
  }
}
