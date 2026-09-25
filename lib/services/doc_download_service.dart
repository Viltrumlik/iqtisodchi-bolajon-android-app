import 'dart:io';
import 'dart:ui' show Rect;
import 'package:flutter/services.dart' show rootBundle;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Result of a download attempt, so the UI can show the right message.
enum DownloadStatus { opened, shared, failed }

class DownloadResult {
  final DownloadStatus status;
  final String? path;
  final String? message;

  const DownloadResult(this.status, {this.path, this.message});
}

/// Copies a bundled lesson-plan .doc out of the app and hands it to the
/// device — either opened in a Word viewer, or passed to the share sheet so
/// the teacher can save it to Files / Drive / Telegram.
class DocDownloadService {
  /// Writes [assetPath] into a user-visible folder and returns the file.
  ///
  /// On Android this prefers the app's external "Hujjatlar" directory, which
  /// is browsable in the Files app and needs no runtime permission.
  static Future<File> _materialise(String assetPath, String fileName) async {
    final bytes = await rootBundle.load(assetPath);

    Directory dir;
    if (Platform.isAndroid) {
      final external = await getExternalStorageDirectory();
      dir = Directory('${(external ?? await getApplicationDocumentsDirectory()).path}/Hujjatlar');
    } else {
      dir = Directory('${(await getApplicationDocumentsDirectory()).path}/Hujjatlar');
    }
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final file = File('${dir.path}/${_safeName(fileName)}');
    await file.writeAsBytes(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      flush: true,
    );
    return file;
  }

  /// Strips characters that are illegal in filenames on Android/iOS.
  static String _safeName(String name) =>
      name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '-');

  /// Saves the document and opens it in whatever app handles .doc files.
  /// Falls back to the share sheet when nothing on the device can open it.
  static Future<DownloadResult> openDoc(String assetPath, String fileName) async {
    try {
      final file = await _materialise(assetPath, fileName);
      final result = await OpenFilex.open(
        file.path,
        type: 'application/msword',
      );
      if (result.type == ResultType.done) {
        return DownloadResult(DownloadStatus.opened, path: file.path);
      }
      // No viewer installed — let the user send it somewhere that can read it.
      return shareDoc(assetPath, fileName);
    } catch (e) {
      return DownloadResult(DownloadStatus.failed, message: '$e');
    }
  }

  /// Saves the document and opens the system share sheet.
  static Future<DownloadResult> shareDoc(
    String assetPath,
    String fileName, {
    Rect? origin,
  }) async {
    try {
      final file = await _materialise(assetPath, fileName);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/msword')],
          subject: fileName,
          sharePositionOrigin: origin,
        ),
      );
      return DownloadResult(DownloadStatus.shared, path: file.path);
    } catch (e) {
      return DownloadResult(DownloadStatus.failed, message: '$e');
    }
  }
}
