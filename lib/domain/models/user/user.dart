class User {
  int id;
  String firstName;
  String lastName;
  String fullName;
  String? email;
  String? photo;
  String? userRole;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.email,
    this.photo,
    this.userRole,
  });
}
