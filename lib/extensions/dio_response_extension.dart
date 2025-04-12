// External Imports
import 'package:dio/dio.dart';

extension DioResponseExtension on Response {
  /// Checks if the HTTP response status code is 200 (OK).
  ///
  /// Throws an [Exception] if the status code is not in the 2xx range, indicating a failed request.
  void isSuccessStatusCode() {
    if (statusCode == null) {
      throw Exception(
        "HTTP request to '${realUri.toString()}' failed with no status code.",
      );
    } else if (statusCode! > 399) {
      throw Exception(
        "HTTP request to '${realUri.toString()}' failed with status code: $statusCode.",
      );
    }
  }
}
