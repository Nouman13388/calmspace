class MentalHealthContent {
  final String? title; // Title
  final String? author; // Author
  final String? date; // Date
  final String? description; // Description
  final String? image; // Image URL
  final List<String>? tags; // Tags

  MentalHealthContent({
    this.title,
    this.author,
    this.date,
    this.description,
    this.image,
    this.tags,
  });

  factory MentalHealthContent.fromMap(Map<String, dynamic> json) {
    return MentalHealthContent(
      title: json['title'] as String?,
      author: json['author'] as String?,
      date: json['date'] as String?,
      description: json['description'] as String?,
      image: json['image'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }
}
