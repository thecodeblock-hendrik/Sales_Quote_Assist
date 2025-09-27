class QuoteItem {
  final String name;
  final int totalQuantity;

  QuoteItem({
    required this.name,
    required this.totalQuantity,
  });

  factory QuoteItem.fromJson(Map<String, dynamic> json) {
    return QuoteItem(
      name: json['name'] as String,
      totalQuantity: json['totalQuantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'totalQuantity': totalQuantity,
    };
  }
}

enum EmailType {
  standardProfessional('Standard Professional'),
  warmAndClientFocused('Warm and Client Focused'),
  clearAndActionOriented('Clear and Action Oriented');

  const EmailType(this.displayName);
  final String displayName;
}

class EmailResponse {
  final String emailBody;

  EmailResponse({required this.emailBody});

  factory EmailResponse.fromJson(Map<String, dynamic> json) {
    return EmailResponse(
      emailBody: json['emailBody'] as String,
    );
  }
}
