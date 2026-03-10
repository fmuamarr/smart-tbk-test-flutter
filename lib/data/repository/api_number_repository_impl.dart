import '../../app/utils/const/api_url.dart';
import '../../domain/entities/reverse_result.dart';
import '../../domain/repositories/number_repository.dart';
import '../mapper/reverse_result_mapper.dart';
import '../model/base_response_model.dart';
import '../model/calculate_response_model.dart';
import '../network/api_provider.dart';

class ApiNumberRepositoryImpl implements NumberRepository {
  final ApiProvider apiProvider;

  ApiNumberRepositoryImpl(this.apiProvider);

  final ApiUrl _apiUrl = ApiUrl();

  @override
  Future<ReverseResult> calculateReverseDifference(int number) async {
    final response = await apiProvider.call(
      _apiUrl.calculate,
      method: MethodRequest.post,
      request: {'number': number},
    );

    final parsed = ResponseResultModel<CalculateResponseModel>.fromJson(
      response: response,
      onResult: (json) => CalculateResponseModel.fromJson(json),
    );

    if (!parsed.success || parsed.result == null) {
      throw ApiException(parsed.message, 0);
    }

    return ReverseResultMapper.fromModel(parsed.result!);
  }

  Future<bool> checkHealth() async {
    try {
      final response = await apiProvider.call(
        _apiUrl.checkApi,
        method: MethodRequest.get,
      );
      return response['data']?['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }
}
