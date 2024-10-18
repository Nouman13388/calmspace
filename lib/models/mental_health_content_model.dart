// models/mental_health_content_model.dart
class MentalHealthContent {
  final String name;
  final String description;
  final String url;
  final List<String> lastReviewed;
  final List<String> relatedLinks;
  final List<WebPageElement> hasParts;

  MentalHealthContent({
    required this.name,
    required this.description,
    required this.url,
    required this.lastReviewed,
    required this.relatedLinks,
    required this.hasParts,
  });

  factory MentalHealthContent.fromMap(Map<String, dynamic> json) {
    return MentalHealthContent(
      name: json['name'],
      description: json['description'],
      url: json['url'],
      lastReviewed: List<String>.from(json['lastReviewed']),
      relatedLinks:
          List<String>.from(json['relatedLink'].map((link) => link['url'])),
      hasParts: (json['hasPart'] as List)
          .map((part) => WebPageElement.fromMap(part))
          .toList(),
    );
  }
}

// Model for the webpage elements
class WebPageElement {
  final String name;
  final String text;
  final String url;

  WebPageElement({required this.name, required this.text, required this.url});

  factory WebPageElement.fromMap(Map<String, dynamic> json) {
    return WebPageElement(
      name: json['name'],
      text: json['text'],
      url: json['url'] ?? '', // Optional URL
    );
  }
}
