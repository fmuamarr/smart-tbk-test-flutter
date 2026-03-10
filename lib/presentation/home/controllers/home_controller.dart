import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/utils/const/storage_const.dart';
import '../../../app/utils/locales/locale_strings.dart';
import '../../../app/utils/service/storage_service.dart';
import '../../../data/network/config.dart';
import '../../../data/repository/api_number_repository_impl.dart';
import '../../../domain/entities/reverse_result.dart';
import '../../../domain/usecase/calculate_reverse_difference_usecase.dart';

enum CalculationMode { builtIn, api }

class HomeController extends GetxController {
  final CalculateReverseDifferenceUseCase localUseCase;
  final CalculateReverseDifferenceUseCase apiUseCase;
  final ApiNumberRepositoryImpl apiRepository;

  HomeController({
    required this.localUseCase,
    required this.apiUseCase,
    required this.apiRepository,
  });

  final textController = TextEditingController();
  final hostController = TextEditingController();
  final Rxn<ReverseResult> result = Rxn<ReverseResult>();
  final RxString errorMessage = ''.obs;
  final Rx<CalculationMode> mode = CalculationMode.builtIn.obs;
  final RxBool isLoading = false.obs;
  final RxBool isApiHealthy = false.obs;
  final RxBool isCheckingHealth = false.obs;
  final RxString currentHost = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final saved = StorageService.getData(StorageConst.customApiHost) as String?;
    final host = (saved != null && saved.isNotEmpty)
        ? saved
        : ApiConfig.baseUrl;
    currentHost.value = host;
    hostController.text = host;
    apiRepository.apiProvider.updateBaseUrl(host);
  }

  CalculateReverseDifferenceUseCase get _activeUseCase =>
      mode.value == CalculationMode.api ? apiUseCase : localUseCase;

  String sanitizeInput(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String? saveHost(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return LocaleStrings.hostEmpty.tr;

    final uri = Uri.tryParse(trimmed);
    final isValid =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    if (!isValid) return LocaleStrings.hostInvalid.tr;

    StorageService.saveData(StorageConst.customApiHost, trimmed);
    currentHost.value = trimmed;
    apiRepository.apiProvider.updateBaseUrl(trimmed);

    if (mode.value == CalculationMode.api) {
      mode.value = CalculationMode.builtIn;
      result.value = null;
    }
    errorMessage.value = '';
    return null;
  }

  Future<void> switchMode(CalculationMode newMode) async {
    if (newMode == mode.value) return;

    if (newMode == CalculationMode.api) {
      isCheckingHealth.value = true;
      errorMessage.value = '';

      final healthy = await apiRepository.checkHealth();

      isCheckingHealth.value = false;
      isApiHealthy.value = healthy;

      if (!healthy) {
        errorMessage.value = LocaleStrings.apiUnreachable.tr;
        return;
      }
    }

    mode.value = newMode;
    result.value = null;
    errorMessage.value = '';
  }

  Future<void> submit() async {
    final input = textController.text.trim();

    if (input.isEmpty) {
      errorMessage.value = LocaleStrings.pleaseEnterNumber.tr;
      result.value = null;
      return;
    }

    final number = int.tryParse(input);
    if (number == null) {
      errorMessage.value = LocaleStrings.invalidNumber.tr;
      result.value = null;
      return;
    }

    errorMessage.value = '';
    isLoading.value = true;

    try {
      result.value = await _activeUseCase.execute(number);
    } catch (e) {
      errorMessage.value = e.toString();
      result.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    textController.dispose();
    hostController.dispose();
    super.onClose();
  }
}
