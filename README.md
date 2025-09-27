# Sales Quote Assistant - Flutter App

A Flutter application for sales teams to automatically generate quote quantities from site inspection documents and draft client emails from final quotes using AI. **Note app is designed for custom site inspection sheet and quote - app will note be functional without the custom sheet and quote layout as it was designed for internal use**

## Features

- 📄 **Document Processing**: Upload Word/PDF inspection documents to extract hardware items and quantities
- 📧 **Email Generation**: Create professional client emails from final quote PDFs
- 🎨 **Multiple Email Tones**: Choose from Standard Professional, Warm & Client Focused, or Clear & Action Oriented
- 🌙 **Dark Mode Support**: Automatic light/dark theme switching
- 💻 **Cross-Platform**: Runs on iOS, and Android

## Prerequisites

- Flutter SDK (3.0.0 or later)
- Dart SDK
- A Gemini API key from Google AI Studio

## Setup Instructions

### 1. Install Flutter

If you don't have Flutter installed, follow the official installation guide:
- [Flutter Installation Guide](https://docs.flutter.dev/get-started/install)

### 2. Clone and Setup

```bash
# Create a new Flutter project directory
mkdir sales_quote_assistant
cd sales_quote_assistant

# Initialize Flutter project (if needed)
flutter create --org com.yourcompany.salesquote .

# Install dependencies
flutter pub get
```

### 3. Get Gemini API Key

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Copy the API key

### 4. Configure Environment

Create a `.env` file in the root directory:

```bash
# .env file
GEMINI_API_KEY=your_actual_gemini_api_key_here
```

### 5. Run the App

For macOS desktop:
```bash
flutter run -d macos
```

For other platforms:
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d [device-id]
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── quote_item.dart      # Data models
├── services/
│   └── gemini_service.dart  # AI service integration
├── screens/
│   └── home_screen.dart     # Main application screen
└── widgets/
    ├── file_upload_widget.dart      # File upload component
    └── email_type_selector.dart     # Email type selection
```

## How to Use

### Generate Quote Quantities
1. Click "Upload Inspection Document" in the first section
2. Select a Word document (.doc, .docx) or PDF containing site inspection data
3. Click "Generate Quantities" to extract hardware items and their quantities
4. View the extracted items in the table below

### Create Professional Emails
1. Select your preferred email tone (Standard Professional, Warm & Client Focused, or Clear & Action Oriented)
2. Click "Upload Final Quote PDF" in the second section
3. Select your completed quote PDF
4. Click "Create New Email" to generate a professional email template
5. Copy the generated email to your clipboard

## Building for Different Platforms

### macOS Desktop App
```bash
flutter build macos
```

### Windows Desktop App
```bash
flutter build windows
```

### Linux Desktop App
```bash
flutter build linux
```

### iOS App
```bash
flutter build ios
```

### Android App
```bash
flutter build apk
```

## Troubleshooting

### Common Issues

1. **API Key Error**: Make sure your `.env` file contains the correct Gemini API key
2. **File Upload Issues**: Ensure you have proper file permissions on your system
3. **Build Issues**: Run `flutter clean` and `flutter pub get` to resolve dependency issues

### macOS Specific

If you encounter signing issues on macOS, you may need to:
```bash
# Disable code signing for development
flutter build macos --debug
```

## Dependencies

The app uses these main dependencies:
- `google_generative_ai`: For AI document processing
- `file_picker`: For file selection
- `flutter_dotenv`: For environment variable management
- `http`: For network requests

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Create an issue on the repository
3. Consult the Flutter documentation at [flutter.dev](https://flutter.dev)
