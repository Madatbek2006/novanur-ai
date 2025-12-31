class DangerousVisitor {
  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String iin;
  final Map<String, dynamic>? group;
  final String actualFaceImage;
  final String recognitionFaceImage;
  final String faceImageSentDevice;
  final double isSpoofed;
  final double compScore;
  final double spoofingScore;
  final DateTime recordedAt;

  DangerousVisitor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.iin,
    required this.group,
    required this.recognitionFaceImage,
    required this.actualFaceImage,
    required this.isSpoofed,
    required this.faceImageSentDevice,
    required this.compScore,
    required this.spoofingScore,
    required this.recordedAt,
  });
}