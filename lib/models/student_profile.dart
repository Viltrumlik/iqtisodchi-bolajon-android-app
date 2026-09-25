/// Which avatar the child picked on the welcome screen.
enum Gender { boy, girl }

extension GenderX on Gender {
  String get id => this == Gender.boy ? 'boy' : 'girl';

  String get label => this == Gender.boy ? 'O\'g\'il bola' : 'Qiz bola';

  String get asset => this == Gender.boy
      ? 'assets/avatars/boy.png'
      : 'assets/avatars/girl.png';

  static Gender fromId(String? id) => id == 'girl' ? Gender.girl : Gender.boy;
}

/// The child using the app — collected once on first launch.
class StudentProfile {
  final String firstName;
  final String lastName;
  final Gender gender;

  const StudentProfile({
    required this.firstName,
    required this.lastName,
    required this.gender,
  });

  /// True once the child has told us who they are.
  bool get isComplete => firstName.trim().isNotEmpty;

  String get fullName => '$firstName $lastName'.trim();

  /// "Alisher K." — keeps the home header short on narrow phones.
  String get shortName {
    final f = firstName.trim();
    final l = lastName.trim();
    if (l.isEmpty) return f;
    return '$f ${l[0].toUpperCase()}.';
  }

  static const empty =
      StudentProfile(firstName: '', lastName: '', gender: Gender.boy);

  StudentProfile copyWith({
    String? firstName,
    String? lastName,
    Gender? gender,
  }) =>
      StudentProfile(
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        gender: gender ?? this.gender,
      );
}
