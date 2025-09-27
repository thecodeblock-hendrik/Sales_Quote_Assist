import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/quote_item.dart';

class GeminiService {
  static final String _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  static late final GenerativeModel _model;

  static final GenerationConfig generationConfig =
      GenerationConfig(responseMimeType: 'application/json');

  static void initialize() {
    if (_apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in environment variables');
    }
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );
  }

  static const String _quantitiesPrompt = '''
You are a specialized AI assistant designed to analyze Point-of-Sale (POS) technical site layout documents. Your task is to extract all hardware items and calculate their total quantities based on the provided document. You must follow these specific rules for counting:

1.  **Station Equipment**:
    *   The document contains sections like "Station 1", "Station 2", etc.
    *   For each station, check for the following items: 'POS Terminal', 'Receipt Printer', 'Cash Drawer', 'Customer Facing Display', 'Fingerprint Reader'.
    *   Count an item as 1 for a station if its 'Model' or other details are filled.
    *   Count an item as 0 for a station if its fields contain 'N/A' or are left blank.
    *   After checking all stations, sum the counts for each item type. For example, if 'POS Terminal' is present in Station 1, 2, and 3, its total quantity is 3.

2.  **Remote Printers**:
    *   Count the number of distinct printer entries listed under the "Remote Printers" section.

3.  **Back Office**:
    *   Count the "Back Office" computer as 1 if the 'Model' field is filled. If blank, the count is 0.

4.  **Network Infrastructure**:
    *   **Network Switches**: Count the number of entries under "Network Switches". If the section is empty or details are blank, the quantity for an item named 'Network Switch' is 0.
    *   **Network Points**: Create a single item named "Network Points". Its quantity is the sum of all values in the 'Quantity' column under the "Network Points" section (e.g., sum of 'Total Active Network Points', 'POS Terminal Network Points', 'Remote Printer Network Points', 'Customer Internet').

5.  **Electrical Infrastructure**:
    *   Create a single item named "Electrical Points". Its quantity is the value from the 'Quantity' column for "Power Sockets".

6.  **Power Backup System**:
    *   Identify the 'Device Type' (e.g., 'Inverter'). This becomes the item name. Count it as 1 if its details ('Model', 'Capacity', etc.) are filled. If blank or 'N/A', the count is 0.

**Final Output Rules**:
*   Combine all findings into a summarized list.
*   Provide the output ONLY as a valid JSON array of objects. Each object must have two keys: "name" (string) and "totalQuantity" (number).
*   Do not include any explanatory text, notes, or apologies in your response. Only return the JSON array.

Example format:
[{"name": "POS Terminal", "totalQuantity": 3}, {"name": "Customer Facing Display", "totalQuantity": 0}, {"name": "Network Points", "totalQuantity": 13}]
''';

  static String _getEmailPrompt(EmailType emailType) {
    const templates = {
      EmailType.standardProfessional: '''
Subject: Quotation for [Project/Service/Item Name]

Dear [Client Name],

Please find attached your quotation for [project/service/item]. The quote includes the items, quantities, and amounts as detailed in the attached PDF.

In summary, the proposal covers:
[Number of items/products/services quoted]

Total investment: [Total Amount] (VAT inclusive/exclusive)

Should you have any questions or require adjustments, please let us know — we will gladly assist.

Best regards,
[Your Name]
[Your Position]
[Company Name]''',
      EmailType.warmAndClientFocused: '''
Subject: Proposal & Quotation for Your Review

Dear [Client Name],

Thank you for the opportunity to prepare this quotation for you. Please see the attached PDF for the full breakdown.

In brief, the proposal includes:
[Key product/service highlights]

A total cost of [Total Amount]

We believe this solution aligns well with your requirements and look forward to your feedback.

Kind regards,
[Your Name]
[Your Position]
[Company Name]''',
      EmailType.clearAndActionOriented: '''
Subject: Attached Quotation – [Company/Product/Service Name]

Dear [Client Name],

Attached is your quotation outlining the items and pricing for your consideration.

Summary:
Items/Services: [Short description]
Quantity: [X]
Total Amount: [Total Amount]

Please review the attached document and let us know if we may proceed or if any adjustments are required.

Sincerely,
[Your Name]
[Your Position]
[Company Name]'''
    };

    final selectedTemplate = templates[emailType]!;

    return '''
You are an expert sales assistant AI. Your task is to generate a professional email to a client based on the attached final quote document. The user has selected the "${emailType.displayName}" tone for the email.

First, analyze the quote to find the following details:
- The client's name. If you cannot find a specific name, use the placeholder "Valued Client".
- The final total amount of the quote.
- A brief summary of what the quote includes, tailored to the placeholders in the selected template.

Next, you MUST use the following template to structure your email:

--- TEMPLATE START ---
$selectedTemplate
--- TEMPLATE END ---

Populate the template with the extracted information. Replace placeholder values like "[Your Name]" with generic but professional placeholders (e.g., "Your Name", "Your Company").

Finally, provide your response ONLY as a valid JSON object with a single key, "emailBody", containing the complete, ready-to-send email as a single string. The email body should include the subject line.

Example format:
{"emailBody": "Subject: Your Quotation\\n\\nDear Valued Client,\\n\\nPlease find your quote attached..."}
''';
  }

  static Future<List<QuoteItem>> generateQuantitiesFromDocument(
      File file) async {
    try {
      final bytes = await file.readAsBytes();
      final content = [
        Content.multi([
          TextPart(_quantitiesPrompt),
          DataPart('application/pdf', bytes),
        ])
      ];

      final response = await _model.generateContent(content,
          generationConfig: generationConfig); //added
      final text = response.text;

      if (text == null) {
        throw Exception('No response received from AI model');
      }

      final List<dynamic> jsonList = jsonDecode(text);
      return jsonList.map((json) => QuoteItem.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to generate quantities: ${e.toString()}');
    }
  }

  static Future<EmailResponse> generateEmailFromQuote(
      File file, EmailType emailType) async {
    try {
      final bytes = await file.readAsBytes();
      final emailPrompt = _getEmailPrompt(emailType);

      final content = [
        Content.multi([
          TextPart(emailPrompt),
          DataPart('application/pdf', bytes),
        ])
      ];

      final response = await _model.generateContent(content,
          generationConfig: generationConfig); //added
      final text = response.text;

      if (text == null) {
        throw Exception('No response received from AI model');
      }

      final Map<String, dynamic> jsonResponse = jsonDecode(text);
      return EmailResponse.fromJson(jsonResponse);
    } catch (e) {
      throw Exception('Failed to generate email: ${e.toString()}');
    }
  }
}
