
class Resource {
  final int id;
  final String title;
  final String type;
  final int? year;
  final String? description;
  final String subject;
  final String level;

  Resource({
    required this.id,
    required this.title,
    required this.type,
    this.year,
    this.description,
    required this.subject,
    required this.level,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'] as int,
      title: json['title'] as String,
      type: json['type'] as String,
      year: json['year'] as int?,
      description: json['description'] as String?,
      subject: json['subject'] as String,
      level: json['level'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'year': year,
      'description': description,
      'subject': subject,
      'level': level,
    };
  }
}

class Subject {
  final int id;
  final String name;
  final String level;

  Subject({
    required this.id,
    required this.name,
    required this.level,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as int,
      name: json['name'] as String,
      level: json['level'] as String? ?? 'Unknown', // Handle potential nulls or structure mismatch
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
    };
  }
}
