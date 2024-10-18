class MentalHealthContent {
  final String? name; // Make nullable
  final String? description; // Make nullable
  final String? url; // Make nullable
  final List<String>? lastReviewed; // Make nullable
  final List<String>? relatedLinks; // Make nullable
  final List<WebPageElement>? hasParts; // Make nullable

  MentalHealthContent({
    this.name,
    this.description,
    this.url,
    this.lastReviewed,
    this.relatedLinks,
    this.hasParts,
  });

  factory MentalHealthContent.fromMap(Map<String, dynamic> json) {
    return MentalHealthContent(
      name: json['name'] as String?, // Cast to nullable String
      description: json['description'] as String?, // Cast to nullable String
      url: json['url'] as String?, // Cast to nullable String
      lastReviewed: json['lastReviewed'] != null
          ? List<String>.from(json['lastReviewed'])
          : null, // Handle null
      relatedLinks: json['relatedLink'] != null
          ? List<String>.from(json['relatedLink'].map((link) => link['url']))
          : null, // Handle null
      hasParts: json['hasPart'] != null
          ? (json['hasPart'] as List)
              .map((part) => WebPageElement.fromMap(part))
              .toList()
          : null, // Handle null
    );
  }
}
class WebPageElement {
  final String? name; // Make nullable
  final String? text; // Make nullable
  final String? url; // Make nullable

  WebPageElement({
    this.name,
    this.text,
    this.url,
  });

  factory WebPageElement.fromMap(Map<String, dynamic> json) {
    return WebPageElement(
      name: json['name'] as String?, // Handle null
      text: json['text'] as String?, // Handle null
      url: json['url'] ?? '', // Fallback to an empty string if null
    );
  }
}
