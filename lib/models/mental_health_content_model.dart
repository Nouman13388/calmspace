// models/mental_health_content.dart
class MentalHealthContent {
  final int id;
  final String title;
  final String description;
  final String createdAt;

  MentalHealthContent({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory MentalHealthContent.fromMap(Map<String, dynamic> json) {
    return MentalHealthContent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_at': createdAt,
    };
  }
}
