// models/mental_health_content_model.dart
class MentalHealthContent {
  final int id;
  final String title;
  final String description;

  MentalHealthContent(
      {required this.id, required this.title, required this.description});

  factory MentalHealthContent.fromMap(Map<String, dynamic> json) {
    return MentalHealthContent(
      id: json['id'],
      title: json['title'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }
}
