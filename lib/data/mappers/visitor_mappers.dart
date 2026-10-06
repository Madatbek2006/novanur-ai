import 'package:nurnova_ai/data/datasource/network/dto/visitor/dangerous_visitor_response.dart';
import 'package:nurnova_ai/data/datasource/network/dto/visitor/visitor_attendance_response.dart';
import 'package:nurnova_ai/domain/models/visitor/dangerous_visitor.dart';
import 'package:nurnova_ai/domain/models/visitor/visitor_attendance.dart';

extension VisitorAttendanceMapper on VisitorAttendanceResponse {
  VisitorAttendance toModel() {
    return VisitorAttendance(
      id: id,
      type: type ?? "",
      isExit: type?.toLowerCase().contains("exit") ?? false,
      gender: gender ?? "",
      isFemale: type?.toLowerCase().contains("female") ?? false,
      age: age ?? 0,
      faceImage: faceImage,
      orgName: orgName ?? "",
      recordedAt: recordedAt,
    );
  }
}

extension DangerousVisitorMapper on DangerousVisitorResponse {
  DangerousVisitor toModel() {
    return DangerousVisitor(
      id: id,
      firstName: firstName ?? "",
      lastName: lastName ?? "",
      fullName: "$firstName $lastName".trim(),
      iin: iin ?? "",
      group: group,
      recognitionFaceImage: recognitionFaceImage ?? "",
      actualFaceImage: actualFaceImage ?? "",
      faceImageSentDevice: faceImageSentDevice ?? "",
      isSpoofed: isSpoofed ?? 0.0,
      compScore: compScore ?? 0.0,
      spoofingScore: spoofingScore ?? 0.0,
      recordedAt: recordedAt,
    );
  }
}
