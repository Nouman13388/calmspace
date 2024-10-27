class AssessmentQuestion {
  final int id;
  final String type;
  final String result;
  final String createdAt;
  final int user;

  AssessmentQuestion({
    required this.id,
    required this.type,
    required this.result,
    required this.createdAt,
    required this.user,
  });

  factory AssessmentQuestion.fromJson(Map<String, dynamic> json) {
    return AssessmentQuestion(
      id: json['id'],
      type: json['type'],
      result: json['result'],
      createdAt: json['created_at'],
      user: json['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'result': result,
      'created_at': createdAt,
      'user': user,
    };
  }
}
