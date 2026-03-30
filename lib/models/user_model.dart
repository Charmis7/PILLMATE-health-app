

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String gender;
  final String dateOfBirth;//DateTime

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.gender,
    required this.dateOfBirth,
  });

  // f->d
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid        : map['uid']         ?? '',
      name       : map['name']        ?? '',
      email      : map['email']       ?? '',
      gender     : map['gender']      ?? 'Select',
      dateOfBirth: map['dateOfBirth'] ?? 'Select',// dateOfBirth:DateTime.tryParse(map['dateOfBirth'] ?? '') ?? DateTime.now(),


    );
  }
//d->f
  Map<String, dynamic> toMap() {
    return {
      'uid'        : uid,
      'name'       : name,
      'email'      : email,
      'gender'     : gender,
      'dateOfBirth': dateOfBirth,
      'updatedAt'  : DateTime.now().toIso8601String(),
    };
  }
}