import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  static final GetStorage _storage = GetStorage();

  static GetStorage get storage => _storage;

  static Future<void> initStorage() async {
    await GetStorage.init();
  }

  static void saveData(String key, dynamic value) {
    try {
      String rawData = jsonEncode({
        'value': value,
        'type': value.runtimeType.toString(),
      });

      _storage.write(key, rawData);
    } catch (e) {
      debugPrint('Error saving data with Key "$key": $e');
      rethrow;
    }
  }

  static dynamic getData(String key) {
    try {
      String? rawData = _storage.read(key);
      if (rawData != null) {
        Map<String, dynamic> data = jsonDecode(rawData);
        dynamic value = data['value'];
        String type = data['type'];

        switch (type) {
          case 'String':
            return value as String;
          case 'int':
            return int.parse(value.toString());
          case 'double':
            return double.parse(value.toString());
          case 'bool':
            return value.toString().toLowerCase() == 'true';
          default:
            return value;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error retrieving data with Key "$key": $e');
      return null;
    }
  }

  static void removeData(String key) {
    try {
      _storage.remove(key);
    } catch (e) {
      debugPrint('Error removing data with Key "$key": $e');
    }
  }

  static void clearAll() {
    try {
      _storage.erase();
    } catch (e) {
      debugPrint('Error clearing storage: $e');
    }
  }
}
