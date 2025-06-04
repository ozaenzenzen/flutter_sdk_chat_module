import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:konnek_native_core/src/support/app_logger.dart';

class AppFilePickerServiceCS {
  Future<File?> pickFiles({
    bool allowMultiples = false,
    void Function(double sizeFileValue)? onSizeFile,
    void Function(String fileNameValue)? onFileName,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        File fileFormat = File(result.files.single.path!);
        
        String fileName = getFileName(fileFormat);
        onFileName?.call(fileName);

        double sizeFile = await calculateSizeWithValue(fileFormat);
        onSizeFile?.call(sizeFile);
        return fileFormat;
      } else {
        return null;
      }
    } catch (e) {
      AppLoggerCS.debugLog("[AppFilePickerServiceCS][pickFiles] $e");
      return null;
    }
  }

  String getFileName(File fileFormat) {
    String fileName = fileFormat.path.split('/').last;
    // AppLoggerCS.debugLog("[getFileName]: $fileName");
    return fileName;
  }

  Future<double> calculateSizeWithValue(File fileFormat) async {
    // Calculate the size in MB
    int sizeInBytes = await fileFormat.length();
    double sizeInMb = sizeInBytes / (1024 * 1024);
    // AppLoggerCS.debugLog("Image Size MB: $sizeInMb");
    // AppLoggerCS.debugLog("Image Size KB: ${sizeInMb * 1000}");
    return sizeInMb;
  }
}
