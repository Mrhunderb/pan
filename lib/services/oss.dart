import 'dart:typed_data';

import 'package:minio/minio.dart';
import 'package:minio/models.dart';

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
  static Future<List<Object>> listFiles([String? prefix]) async {
    final stream = minio.listObjects(bucketName, prefix: prefix ?? '');
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

  static Future<Stream<List<int>>> downloadFile(String objectName) async {
    return minio.getObject(bucketName, objectName);
  }
}
