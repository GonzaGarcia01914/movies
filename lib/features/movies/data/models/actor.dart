class Person {
  final int id;
  final String name;
  final String? profilePath;
  final String? character;

  Person({
    required this.id,
    required this.name,
    required this.profilePath,
    required this.character,
  });

  factory Person.fromJson(Map<String, dynamic> json) => Person(
    id: json['id'] as int,
    name: json['name'] as String? ?? '',
    profilePath: json['profile_path'] as String?,
    character: json['character'] as String?,
  );

  String get profileUrl =>
      profilePath != null ? 'https://image.tmdb.org/t/p/w185$profilePath' : '';
}
