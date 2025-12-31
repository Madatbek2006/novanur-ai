class Identity {
  final int id;
  final String iin;
  final String firstName;
  final String lastName;
  final String fullName;
  final String patronymicName;
  final String identityPhoto;
  final String role;
  final int? groupId;
  final String groupName;
  final bool isEmployee;
  final bool? isArchived;

  Identity({
    required this.id,
    required this.iin,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.patronymicName,
    required this.identityPhoto,
    required this.role,
    required this.groupId,
    required this.groupName,
    required this.isEmployee,
    required this.isArchived,
  });

  bool get isStudent => !isEmployee;
}
