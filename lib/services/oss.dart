import 'dart:io';
import 'dart:typed_data';

import 'package:minio/io.dart';
import 'package:minio/minio.dart';
import 'package:minio/models.dart';
import 'package:path_provider/path_provider.dart';

class OssService {
  static const String bucketName = 'pan';
  static const String endPoint = '10.111.23.47';
  static const int port = 9000;
  static const String accessKey = '6UQmclxevHd1Mbu8m4xD';
  static const String secretKey = 'gujzJMv5N54Q8M4CtByn9qvUzadKG8qS6V4R3ULu';

  static final minio = Minio(
    endPoint: endPoint,
    port: port,
    accessKey: accessKey,
    secretKey: secretKey,
    useSSL: false,
  );

  Future<void> uploadFile(String objectName, String filePath) async {
    await minio.putObject(
      bucketName,
      objectName,
      filePath as Stream<Uint8List>,
    );
  }

  /// Count the number of files in a bucket
  /// @param ?prefix
  /// @return Number of files
  static Future<int> fileCount([String? prefix]) async {
    final stream = minio.listObjects(bucketName, prefix: prefix ?? '');
    var count = 0;
    await for (var list in stream) {
      count += list.objects.length;
    }
    return count;
  }

  /// Count the number of folders in a bucket
  /// @param ?prefix
  /// @return Number of folders
  static Future<int> folderCount([String? prefix]) async {
    final stream = minio.listObjects(bucketName, prefix: prefix ?? '');
    var count = 0;
    await for (var list in stream) {
      count += list.prefixes.length;
    }
    return count;
  }

  /// List all files in a bucket
  /// @param ?prefix
  /// @return List of files
  static Future<List<Object>> listFiles([String? prefix, bool? rec]) async {
    final stream = minio.listObjects(bucketName,
        prefix: prefix ?? '', recursive: rec ?? false);
    var objects = <Object>[];
    await for (var list in stream) {
      for (var object in list.objects) {
        objects.add(object);
      }
    }
    return objects;
  }

  /// List all folders in a bucket
  /// @param ?prefix
  /// @return List of folders
  static Future<List<String>> listFolders([String? prefix]) async {
    final stream = minio.listObjects(bucketName, prefix: prefix ?? '');
    var folders = <String>[];
    await for (var list in stream) {
      for (var folder in list.prefixes) {
        folders.add(folder);
      }
    }
    return folders;
  }

  static Future<void> downloadFile(String objectName, String path) async {
    await minio.fGetObject(bucketName, objectName, path);
  }

  static Future<void> downloadFileWithProgress(String objectName) async {}

  static Future<String> downloadFileInTemp(String objectName) async {
    Directory tempDir = await getTemporaryDirectory();
    String path = '${tempDir.path}/$objectName';
    await minio.fGetObject(bucketName, objectName, path);
    return path;
  }

  static Future<String> getFileUrl(String objectName) async {
    return minio.presignedGetObject(bucketName, objectName);
  }

  static Future<void> deleteFiles(List<String> files, String prefix) async {
    for (var file in files) {
      List<String> folders = await listFolders(prefix);
      if (folders.contains(file)) {
        List<Object> files = await listFiles(file, true);
        for (var file in files) {
          await minio.removeObject(bucketName, file.key!);
        }
        continue;
      }
      await minio.removeObject(bucketName, file);
    }
  }
}
