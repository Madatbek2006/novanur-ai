class Attendance {
  final int id;
  final String iin;
  final int? groupId;
  final String? groupName;
  final String firstName;
  final String lastName;
  final String fullName;
  final String patronymicName;
  final String role;
  final bool isArchived;
  final String attendancePhoto;
  final String identityPhoto;
  final String attTakingSource;
  final bool isSpoofed;
  final double? compScore;
  final double? spoofingScore;
  final String createdAt;
  final bool isAbsent;

  Attendance({
    required this.id,
    required this.iin,
    required this.groupId,
    required this.groupName,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.patronymicName,
    required this.role,
    required this.isArchived,
    required this.attendancePhoto,
    required this.identityPhoto,
    required this.attTakingSource,
    required this.isSpoofed,
    required this.compScore,
    required this.spoofingScore,
    required this.createdAt,
    required this.isAbsent,
  });

  bool get hasAttendance => !isAbsent;

  bool get isAutoAtt => attTakingSource.toUpperCase() == "camera".toUpperCase();

  bool get isManualAtt =>
      attTakingSource.toUpperCase() == "mobile".toUpperCase();
}
