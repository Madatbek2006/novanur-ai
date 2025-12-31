import 'package:baiqavisit/data/datasource/network/dto/attendance/attendance_response.dart';
import 'package:baiqavisit/data/datasource/network/dto/attendance/attendance_stats_response.dart';
import 'package:baiqavisit/data/datasource/network/dto/attendance/processing_attendance_response.dart';
import 'package:baiqavisit/domain/models/attendance/attendance.dart';
import 'package:baiqavisit/domain/models/attendance/attendance_stats.dart';
import 'package:baiqavisit/domain/models/attendance/processing_attendance.dart';

extension AttendanceResponseMappers on AttendanceResponse {
  Attendance toModel() {
    return Attendance(
      id: id,
      iin: iin,
      groupId: group?.id,
      groupName: group?.name,
      firstName: firstName ?? "",
      lastName: lastName ?? "",
      fullName: "$firstName $lastName".trim(),
      patronymicName: "",
      role: "",
      isArchived: false,
      attendancePhoto: attendancePhoto ?? "",
      identityPhoto: identityPhoto ?? "",
      attTakingSource: attTakingSource,
      isSpoofed: isSpoofed ?? false,
      compScore: compScore,
      spoofingScore: spoofingScore,
      createdAt: createdAt ?? "",
      isAbsent: false,
    );
  }
}

extension AbsentResponseMappers on AbsentResponse {
  Attendance toModel() {
    return Attendance(
      id: id,
      iin: iin,
      groupId: group?.id,
      groupName: group?.name,
      firstName: firstName ?? "",
      lastName: lastName ?? "",
      fullName: "$firstName $lastName".trim(),
      patronymicName: patronymicName ?? "",
      role: role ?? "",
      isArchived: isArchived ?? false,
      attendancePhoto: "",
      identityPhoto: identityPhoto ?? "",
      attTakingSource: "",
      isSpoofed: false,
      compScore: null,
      spoofingScore: null,
      createdAt: "",
      isAbsent: true,
    );
  }
}

extension AttendanceStatsMappers on AttendanceStatsResponse {
  AttendanceStats toModel({required bool isEmployeeStats}) {
    return AttendanceStats(
      autoAttCount: autoAttCount ?? 0,
      manualAttCount: manualAttCount ?? 0,
      spoofedAttCount: spoofedAttCount ?? 0,
      totalAttCount: totalAttCount ?? 0,
      totalAbsentCount: totalAbsentCount ?? 0,
      isEmployeeStats: isEmployeeStats,
    );
  }
}

extension ProcessingAttendanceResponseMappers on ProcessingAttendanceResponse {
  ProcessingAttendance toModel() {
    return ProcessingAttendance(
      deviceId: deviceId ?? "",
      deviceName: deviceName ?? "",
      attendancePhoto: attendancePhoto ?? "",
      createdAt: createdAt ?? "",
    );
  }
}
