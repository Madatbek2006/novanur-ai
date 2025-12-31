import 'package:flutter_image_compress/flutter_image_compress.dart';

class UploadableFile {
  UploadableFile({
    this.id,
    this.name,
    this.localPath,
    this.extension,
    this.xFile,
  });

  UploadableFile copy() {
    return UploadableFile(
      id: id,
      name: name,
      localPath: localPath,
      extension: extension,
      xFile: xFile,
    );
  }

  String? id;
  String? name;
  String? localPath;
  String? extension;
  XFile? xFile;

  bool isUploaded() {
    return id?.isNotEmpty == true;
  }

  bool isSame(UploadableFile other) {
    return (id != null && id == other.id) ||
        (xFile?.path != null && xFile?.path == other.xFile?.path);
  }

  bool isNotUploaded() {
    return id == null || id?.isEmpty == true;
  }
}
