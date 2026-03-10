class ResponseResultModel<ResultModel> {
  bool success;
  String message;
  ResultModel? result;

  ResponseResultModel({this.success = false, this.message = '', this.result});

  factory ResponseResultModel.fromJson({
    required Map<String, dynamic> response,
    required ResultModel Function(Map<String, dynamic> json) onResult,
  }) => ResponseResultModel(
    success: response['success'] ?? false,
    message: response['message'] ?? '',
    result: response['data'] != null ? onResult(response['data'] ?? {}) : null,
  );

  factory ResponseResultModel.fromJsonOnResultList({
    required Map<String, dynamic> response,
    required ResultModel Function(List<dynamic> json) onResult,
  }) => ResponseResultModel(
    success: response['success'] ?? false,
    message: response['message'] ?? '',
    result: onResult(response['data'] ?? []),
  );

  Map<String, dynamic> toJson({
    required Map<String, dynamic> Function(ResultModel? result) resultToJson,
  }) {
    return {
      'success': success,
      'message': message,
      'data': resultToJson(result),
    };
  }
}
