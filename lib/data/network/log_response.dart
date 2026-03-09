import 'dart:convert';
import 'dart:developer' as logging;

class LogResponse {
  static void logPlainJson(String tag, Map<String, dynamic> jsonObject) {
    try {
      // Convert the JSON object to a pretty-printed string
      const JsonEncoder encoder = JsonEncoder.withIndent('  ');
      final prettyJson = encoder.convert(jsonObject);

      // Set the maximum log chunk size
      const int chunkSize = 1020;

      // Add a separator at the beginning of the log
      logging.log('\n================ $tag ================\n');

      // Split the JSON string into smaller chunks and log each chunk
      for (var i = 0; i < prettyJson.length; i += chunkSize) {
        logging.log(
          prettyJson.substring(
            i,
            i + chunkSize > prettyJson.length
                ? prettyJson.length
                : i + chunkSize,
          ),
          level: 2000,
        );
      }

      // Add a separator at the end of the log
      logging.log('\n================ END ================\n');
    } catch (e) {
      logging.log('$tag: Failed to log JSON - $e');
    }
  }

  static void logJsonResponse(String tag, Map<String, dynamic> jsonObject) {
    logPlainJson(tag, jsonObject);
  }
}
