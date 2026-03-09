import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../app/utils/locale_strings.dart';
import '../../../data/network/api_provider.dart';
import '../../../data/network/config.dart';
import '../../../domain/entities/reverse_result.dart';
import '../../../domain/usecase/calculate_reverse_difference_usecase.dart';

enum CalculationMode { builtIn, api }

class HomeController extends GetxController {
  final CalculateReverseDifferenceUseCase localUseCase;
  final CalculateReverseDifferenceUseCase apiUseCase;
  final ApiProvider apiProvider;

  HomeController({
    required this.localUseCase,
    required this.apiUseCase,
    required this.apiProvider,
  });

  static const _storageKey = 'custom_api_host';
  final _storage = GetStorage();

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
    final saved = _storage.read<String>(_storageKey);
    final defaultHost = ApiConfig.baseUrl;
    final host = (saved != null && saved.isNotEmpty) ? saved : defaultHost;
    currentHost.value = host;
    hostController.text = host;
    apiProvider.updateBaseUrl(host);
  }

  CalculateReverseDifferenceUseCase get _activeUseCase =>
      mode.value == CalculationMode.api ? apiUseCase : localUseCase;

  String sanitizeInput(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Saves the host and updates the Dio baseUrl.
  /// Returns an error message if the format is invalid, null if saved OK.
  String? saveHost(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return LocaleStrings.hostEmpty.tr;

    final uri = Uri.tryParse(trimmed);
    final isValid =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    if (!isValid) {
      return LocaleStrings.hostInvalid.tr;
    }

    _storage.write(_storageKey, trimmed);
    currentHost.value = trimmed;
    apiProvider.updateBaseUrl(trimmed);

    // If currently in API mode, re-check health with new host
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

      bool healthy;
      try {
        final response = await apiProvider.call(
          ApiConfig.healthEndpoint,
          method: MethodRequest.get,
        );
        healthy = response['data']?['status'] == 'ok';
      } catch (_) {
        healthy = false;
      }

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
