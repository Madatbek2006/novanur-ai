class VisitorAttendance {
  final int id;
  final String type;
  final bool isExit;
  final String gender;
  final bool isFemale;
  final int age;
  final String faceImage;
  final String orgName;
  final DateTime recordedAt;

  VisitorAttendance({
    required this.id,
    required this.type,
    required this.isExit,
    required this.gender,
    required this.isFemale,
    required this.age,
    required this.faceImage,
    required this.orgName,
    required this.recordedAt,
  });
}