import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:logger/logger.dart';
import 'package:nurnova_ai/presentation/support/extensions/xfile_exts.dart';
import 'package:path/path.dart' as path;

extension XFileCompressingExts on XFile {
  Future<XFile> compressPhoto({int quality = 45}) async {
    final originalFile = toFile();

    final originalFilePath = originalFile.absolute.path;
    final extension = path.extension(originalFilePath);
    final compressedFilePath =
        originalFilePath.replaceFirst(extension, '_compressed$extension');

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      originalFilePath,
      compressedFilePath,
      quality: quality > 0 && quality <= 100 ? quality : 45,
    );

    if (compressedFile != null) {
      if (await originalFile.exists()) {
        await originalFile.delete();
        Logger().w("Original file deleted successfully.");
      } else {
        Logger().w("Original file does not exist.");
      }
    }
    return compressedFile!;
  }
}
