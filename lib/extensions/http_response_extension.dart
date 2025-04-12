// External Imports
import 'package:http/http.dart' as http;

extension HttpResponseExtension on http.Response {
  /// Checks if the HTTP response status code is 200 (OK).
  ///
  /// Throws an [Exception] if the status code is not in the 2xx range, indicating a failed request.
  void isSuccessStatusCode() {
    if (statusCode < 200 || statusCode >= 300) {
      throw Exception(
        "HTTP request to '${request?.url}' failed with status code: $statusCode.",
      );
    }
  }
}
