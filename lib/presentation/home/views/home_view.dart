import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../app/theme/theme.dart';
import '../../../app/utils/locales/locale_strings.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleStrings.appTitle.tr),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'Switch Language',
            onPressed: () {
              final isEn = Get.locale?.languageCode == 'en';
              final newLocale = isEn
                  ? const Locale('id', 'ID')
                  : const Locale('en', 'US');
              Get.updateLocale(newLocale);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: LocaleStrings.apiSettings,
            onPressed: () => _showApiSettings(Get.context!),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildModeToggle(),
            const SizedBox(height: 20),
            _buildInputField(),
            const SizedBox(height: 16),
            _buildSubmitButton(),
            const SizedBox(height: 8),
            _buildErrorMessage(),
            const SizedBox(height: 24),
            _buildResult(),
            const SizedBox(height: 32),
            _buildWatermark(),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Obx(() {
      final mode = controller.mode.value;
      final isChecking = controller.isCheckingHealth.value;

      return Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _modeTab(
              label: LocaleStrings.builtInMode.tr,
              icon: Icons.memory,
              isActive: mode == CalculationMode.builtIn,
              isLoading: false,
              onTap: () => controller.switchMode(CalculationMode.builtIn),
            ),
            _modeTab(
              label: LocaleStrings.apiMode.tr,
              icon: Icons.cloud,
              isActive: mode == CalculationMode.api,
              isLoading: isChecking,
              onTap: () => controller.switchMode(CalculationMode.api),
            ),
          ],
        ),
      );
    });
  }

  Widget _modeTab({
    required String label,
    required IconData icon,
    required bool isActive,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isActive ? Colors.white : AppTheme.primaryColor,
                  ),
                )
              else
                Icon(
                  icon,
                  size: 18,
                  color: isActive ? Colors.white : AppTheme.primaryColor,
                ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return TextField(
      controller: controller.textController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: LocaleStrings.enterNumberHint.tr,
        hintText: LocaleStrings.enterNumberExample.tr,
        prefixIcon: const Icon(Icons.numbers),
      ),
      onChanged: (value) {
        final sanitized = controller.sanitizeInput(value);
        if (sanitized != value) {
          controller.textController.text = sanitized;
          controller.textController.selection = TextSelection.fromPosition(
            TextPosition(offset: sanitized.length),
          );
        }
      },
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      final loading = controller.isLoading.value;
      return ElevatedButton(
        onPressed: loading ? null : controller.submit,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                LocaleStrings.submit.tr,
                style: const TextStyle(fontSize: 16),
              ),
      );
    });
  }

  Widget _buildErrorMessage() {
    return Obx(() {
      if (controller.errorMessage.value.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            controller.errorMessage.value,
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildResult() {
    return Obx(() {
      final res = controller.result.value;
      if (res == null) return const SizedBox.shrink();

      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildSourceBadge(),
              const SizedBox(height: 8),
              _ResultRow(
                label: LocaleStrings.number.tr,
                value: '${res.originalNumber}',
              ),
              const Divider(),
              _ResultRow(
                label: LocaleStrings.reversed.tr,
                value: '${res.reversedNumber}',
              ),
              const Divider(),
              _ResultRow(
                label: LocaleStrings.difference.tr,
                value: '${res.difference}',
                valueColor: AppTheme.primaryColor,
                isBold: true,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildWatermark() {
    return Text(
      LocaleStrings.madeBy.tr,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12, color: AppTheme.darkColor.withAlpha(80)),
    );
  }

  Widget _buildSourceBadge() {
    return Obx(() {
      final isApi = controller.mode.value == CalculationMode.api;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isApi
              ? AppTheme.darkColor.withAlpha(25)
              : AppTheme.primaryColor.withAlpha(25),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isApi ? LocaleStrings.viaApi.tr : LocaleStrings.viaBuiltIn.tr,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isApi ? AppTheme.darkColor : AppTheme.primaryColor,
          ),
        ),
      );
    });
  }

  void _showApiSettings(BuildContext context) {
    // Sync the text field with the current saved host each time sheet opens
    controller.hostController.text = controller.currentHost.value;
    final errorObs = ''.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.cloud_outlined, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  LocaleStrings.apiHostSettings.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              LocaleStrings.apiHostDescription.tr,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Obx(
              () => TextField(
                controller: controller.hostController,
                keyboardType: TextInputType.url,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: LocaleStrings.baseUrl.tr,
                  hintText: LocaleStrings.baseUrlHint.tr,
                  prefixIcon: const Icon(Icons.link),
                  errorText: errorObs.value.isEmpty ? null : errorObs.value,
                ),
                onChanged: (_) => errorObs.value = '',
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Text(
                LocaleStrings.currentHost.trParams({
                  'host': controller.currentHost.value,
                }),
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.darkColor.withAlpha(120),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final error = controller.saveHost(
                  controller.hostController.text,
                );
                if (error != null) {
                  errorObs.value = error;
                } else {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        LocaleStrings.hostUpdated.trParams({
                          'host': controller.currentHost.value,
                        }),
                      ),
                      backgroundColor: AppTheme.darkColor,
                    ),
                  );
                }
              },
              child: Text(LocaleStrings.save.tr),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _ResultRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyLarge),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
