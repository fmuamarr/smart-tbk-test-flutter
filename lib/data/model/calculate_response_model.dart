class CalculateResponseModel {
  final int originalNumber;
  final int reversedNumber;
  final int difference;

  CalculateResponseModel({
    required this.originalNumber,
    required this.reversedNumber,
    required this.difference,
  });

  factory CalculateResponseModel.fromJson(Map<String, dynamic> json) {
    return CalculateResponseModel(
      originalNumber: json['originalNumber'] as int,
      reversedNumber: json['reversedNumber'] as int,
      difference: json['difference'] as int,
    );
  }
}
