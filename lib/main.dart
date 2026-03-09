import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/routes/app_pages.dart';
import 'app/theme/theme.dart';
import 'app/utils/app_translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(
    GetMaterialApp(
      title: 'SMART TBK Technical Test done by Fadillah Muamar',
      theme: AppTheme.lightTheme,
      translations: AppTranslations(),
      locale: PlatformDispatcher.instance.locale,
      fallbackLocale: const Locale('en', 'US'),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    ),
  );
}
