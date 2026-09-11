import 'package:nurnova_ai/data/datasource/network/dto/identity/employee_response.dart';
import 'package:nurnova_ai/data/datasource/network/dto/identity/student_response.dart';
import 'package:nurnova_ai/domain/models/identity/identity.dart';

extension EmployeeResponseMappers on EmployeeResponse {
  Identity toModel() {
    return Identity(
      id: id,
      iin: iin,
      firstName: firstName ?? "",
      lastName: lastName ?? "",
      fullName: "$firstName $lastName".trim(),
      patronymicName: patronymicName ?? "",
      identityPhoto: identityPhoto ?? "",
      role: role,
      groupId: null,
      groupName: "",
      isEmployee: true,
      isArchived: isArchived,
    );
  }
}

extension StudentResponseMapper on StudentResponse {
  Identity toModel() {
    return Identity(
      id: id,
      iin: iin,
      firstName: firstName ?? "",
      lastName: lastName ?? "",
      fullName: "${firstName ?? ""} ${lastName ?? ""}",
      patronymicName: patronymicName ?? "",
      identityPhoto: identityPhoto ?? "",
      role: "",
      groupId: group?.id,
      groupName: group?.name ?? "",
      isEmployee: false,
      isArchived: isArchived,
    );
  }
}
