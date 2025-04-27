# DisLogger

A Flutter package that simplifies logging to Discord webhooks. This package helps you send structured and formatted logs directly to Discord channels, making debugging and monitoring your Flutter applications easier and more collaborative.

[![Pub Version](https://img.shields.io/badge/pub-v0.1.0-blue)](https://pub.dev/packages/dis_logger)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

## Features

- 📝 **Channel-based logging** - Send different log types to different Discord webhooks
- 🔍 **Detailed context** - Automatically includes device info, timestamps, and user data
- 🌈 **Formatted messages** - Clean and readable Discord message formatting
- 📱 **Device identification** - Automatically captures device information
- ⚡ **Lightweight** - Minimal impact on app performance
- 🆓 **Completely free** - No hidden servers or fees
- 📈 **Collaborate easily** - Share logs with your team in Discord
- 🛠️ **Customizable fields** - Add custom data to your log messages [SOON]

## Installation

```yaml
dependencies:
  dis_logger: ^0.1.0
```

Run:

```
flutter pub get
```

## Quick Start

```dart
import 'package:dis_logger/dis_logger.dart';

// Define your prefered log types enum
enum LogType { auth, home, init }

void main() {
  // Configure the logger with webhook URLs
  DiscLogger.configure(webhookUrls: {
    LogType.auth: 'https://discord.com/api/webhooks/your_auth_webhook_url',
    LogType.home: 'https://discord.com/api/webhooks/your_home_webhook_url',
    LogType.init: 'https://discord.com/api/webhooks/your_init_webhook_url',
  });
  
  // Now you can log messages to specific channels
  DiscLogger.info(
    'Application started successfully!',
    type: LogType.init,
    user: user.email, // optional | Otherwise N/A
  );
  
  runApp(MyApp());
}
```

## Usage

### Basic Logging

```dart
// Log information
DiscLogger.info(
  'User viewed the dashboard',
  type: LogType.home,
  user: 'user@example.com',
);

// Log warnings
DiscLogger.warning(
  'API response took longer than expected',
  type: LogType.home,
);

// Log errors
DiscLogger.error(
  'Failed to load user data: Connection timeout',
  type: LogType.auth,
  user: 'user@example.com',
);
```

### Custom Log Data

Add custom fields to your log messages:

```dart
DiscLogger.sendLog(
  content: 'User completed checkout process',
  type: LogType.home,
  user: 'customer@example.com',
);
```

### Handling Authentication Events

```dart
try {
  // Login logic
  await authService.login(email, password);
  
  DiscLogger.info(
    'User login successful',
    type: LogType.auth,
    user: email,
  );
} catch (e) {
  DiscLogger.error(
    'Login failed: ${e.toString()}',
    type: LogType.auth,
    user: email,
  );
}
```

## Advanced Configuration

### Custom Enum Types

You can use any enum for categorizing your logs:

```dart
enum Feature { payments, notifications, profile, settings }

// Configure with multiple enum types
DiscLogger.configure(webhookUrls: {
  Feature.payments: 'https://discord.com/api/webhooks/payments_webhook',
  Feature.notifications: 'https://discord.com/api/webhooks/notifications_webhook',
});

// Use different enum types for logging
DiscLogger.error(
  'Payment processing failed',
  type: Feature.payments,  
);
```

### Error Handling

The package includes built-in error handling and retry logic:

```dart
// The package will automatically handle:
// - Rate limiting (with exponential backoff)
// - Network connectivity issues (with retries)
// - Invalid webhook URLs
// - Server errors

// You can also check if a log was sent successfully
bool success = await DiscLogger.error(
  'Critical database connection error',
  type: LogType.auth,
);

if (!success) {
  // Fallback logging mechanism
}
```

## Message Format

Discord messages are formatted for readability:

```
📌 System Log
--------------------------------

⏰ Timestamp: April 27, 2025 14:30:45

👤 User: user@example.com
🔍 Type: auth
📱 Device: iPhone 13 Pro (iOS 16.2)


// - NOT YET IMPLEMENTED
Additional Info:
• Severity: ERROR
• Session ID: a1b2c3d4

📋 Details:
Failed to authenticate user: Invalid credentials
 
--------------------------------
```

<!-- ## Customization

You can modify the message format by extending the `DiscLogger` class:

```dart
class CustomDiscLogger extends DiscLogger {
  static Future<bool> customLog({
    required String content,
    required String category,
    Enum? type,
  }) {
    return sendLog(
      content: content,
      user: 'System',
      type: type,
      additionalFields: {'Category': category},
    );
  }
}
``` -->

## Best Practices

- **Don't log sensitive information**: Never send passwords, authentication tokens, or personal data
- **Be mindful of rate limits**: Discord has rate limits on webhook requests , Discord Allows up to 5 requests per second per webhook. Avoid sending too many logs in a short time.
- **Use different channels logically**: Organize by feature, severity, or environment
- **Include context**: Add relevant information that helps understand the log context
- **Handle errors gracefully**: Check return values from logging calls when critical

## Todo ROADMAP

- [ ] Add support for custom message formatting
- [ ] Implement a more robust retry mechanism to avoid rate limits from Discord

## 🌟 Give it a Star

If you find discord_logger useful, please ⭐ star the repo — it helps support the project and reach more developers!

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
