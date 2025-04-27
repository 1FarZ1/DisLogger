import 'package:dio/dio.dart';
import 'package:dis_logger/device_helper.dart';
import 'package:logger/logger.dart';

//
//Exemple of an enum
//enum LogType { auth, home, init }

class DiscLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 100,
      colors: true,
      dateTimeFormat: (DateTime time) => time.toIso8601String(),
      printEmojis: true,
    ),
  );
  static final Dio _dio = Dio();
  static Map<String, String> _webhookUrls = {};
  static bool _isConfigured = false;

  /// Configure the logger with Discord webhook URLs for different log types.
  ///
  /// Example:
  /// ```dart
  /// DiscLogger.configure(webhookUrls: {
  ///   LogType.auth: 'https://discord.com/api/webhooks/your_webhook_url',
  ///   LogType.home: 'https://discord.com/api/webhooks/another_webhook_url',
  /// });
  /// ```
  static void configure({required Map<Enum, String> webhookUrls}) {
    _webhookUrls = webhookUrls.map((key, value) {
      return MapEntry(key.toString().split('.').last, value);
    });

    _isConfigured = true;
  }

  static String _getWebhookUrl(Enum? type) {
    if (type == null) {
      return _webhookUrls.values.first;
    }
    return _webhookUrls[type.name] ?? _webhookUrls.values.first;
  }

  /// Sends a log message to the configured Discord webhook.
  ///
  /// Parameters:
  /// - [content]: The main content of the log message
  /// - [user]: Optional user identifier (defaults to 'N/A')
  /// - [type]: Log type to determine which webhook to use
  /// - [additionalFields]: Optional map of additional fields to include in the log
  ///
  /// Returns a Future that completes when the log is sent or when all retries are exhausted.
  static Future<bool> sendLog({
    required String content,
    String user = 'N/A',
    Enum? type,
    Map<String, String>? additionalFields,
  }) async {
    if (!_isConfigured) {
      _logger.e('DiscLogger not configured. Call configure() first.');
      return false;
    }

    final String discordWebhookUrl = _getWebhookUrl(type);
    final String deviceInfo = await DeviceHelper.getDeviceInfo();

    // Build additional fields section if provided
    String additionalFieldsSection = '';
    if (additionalFields != null && additionalFields.isNotEmpty) {
      additionalFieldsSection = '\n**Additional Info:**\n';
      additionalFields.forEach((key, value) {
        additionalFieldsSection += '• **$key:** `$value`\n';
      });
    }

    final String formattedMessage = '''
**📌 System Log**
--------------------------------

⏰ **Timestamp:** <t:${(DateTime.now().millisecondsSinceEpoch / 1000).round()}:F>

👤 **User:** `$user`
🔍 **Type:** `${type?.toString().split('.').last ?? 'default'}`
📱 **Device:** `$deviceInfo`$additionalFieldsSection
📋 **Details:**
```
$content
```
 
--------------------------------
''';

    return await _sendToDiscord(discordWebhookUrl, formattedMessage);
  }

  /// Internal method to handle sending the message to Discord with retry logic
  static Future<bool> _sendToDiscord(String webhookUrl, String message) async {
    int attempts = 0;
    const int maxAttempts = 5;
    const int baseDelay = 1;

    while (attempts < maxAttempts) {
      try {
        final response = await _dio.post(
          webhookUrl,
          data: {"content": message},
          options: Options(
            headers: {'Content-Type': 'application/json'},
            validateStatus: (status) => status != null && status < 500,
          ),
        );

        if (response.statusCode == 204 || response.statusCode == 200) {
          _logger.i('Log sent successfully to Discord.');
          return true;
        } else {
          _logger.w('Discord returned status code: ${response.statusCode}');
          return false;
        }
      } catch (e) {
        if (e is DioException) {
          if (e.response?.statusCode == 429) {
            // Handle rate limiting
            final retryAfterHeader = e.response?.headers['retry-after']?.first;
            final retryAfter =
                retryAfterHeader != null
                    ? int.tryParse(retryAfterHeader) ?? baseDelay
                    : baseDelay;

            _logger.w(
              'Rate limit exceeded. Retrying in $retryAfter seconds... (Attempt ${attempts + 1})',
            );

            await Future.delayed(Duration(seconds: retryAfter));
            attempts++;
            continue;
          }
        }
        _logger.e("Failed to send log to Discord: $e");
        return false;
      }
    }

    if (attempts == maxAttempts) {
      _logger.e('Exceeded max retries. Failed to send log to Discord.');
    }

    return false;
  }

  /// Shorthand method for sending error logs
  static Future<bool> error(String content, {String user = 'N/A', Enum? type}) {
    return sendLog(
      content: content,
      user: user,
      type: type,
      additionalFields: {'Severity': 'ERROR'},
    );
  }

  /// Shorthand method for sending info logs
  static Future<bool> info(String content, {String user = 'N/A', Enum? type}) {
    return sendLog(
      content: content,
      user: user,
      type: type,
      additionalFields: {'Severity': 'INFO'},
    );
  }

  /// Shorthand method for sending warning logs
  static Future<bool> warning(
    String content, {
    String user = 'N/A',
    Enum? type,
  }) {
    return sendLog(
      content: content,
      user: user,
      type: type,
      additionalFields: {'Severity': 'WARNING'},
    );
  }
}
