import 'dart:async';
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

  static Future<void> uploadFile(String objectName, String filePath) async {
    await minio.fPutObject(bucketName, objectName, filePath);
  }

  static Future<void> fUploadWithProgress(
    String object,
    String filePath,
    Function(int, int) onProgress,
  ) async {
    final file = File(filePath);
    final stat = await file.stat();
    if (stat.size > minio.maxObjectSize) {
      throw MinioError(
        '$filePath size : ${stat.size}, max allowed size : 5TB',
      );
    }

    int totalBytesSent = 0;

    final fileStream = file.openRead().transform<Uint8List>(
      StreamTransformer.fromHandlers(
        handleData: (data, sink) {
          sink.add(Uint8List.fromList(data));

          totalBytesSent += data.length;

          onProgress(totalBytesSent, stat.size);
        },
      ),
    );

    await minio.putObject(
      bucketName,
      object,
      fileStream,
      size: stat.size,
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

  static Future<void> fDownloadWithProgress(
    String object,
    String filePath,
    Function(int, int) onProgress,
  ) async {
    MinioInvalidBucketNameError.check(bucketName);
    MinioInvalidObjectNameError.check(object);

    final stat = await minio.statObject(bucketName, object);
    final dir = File(filePath).parent;
    await dir.create(recursive: true);

    final partFileName = '$filePath.${stat.etag}.part.minio';
    final partFile = File(partFileName);
    IOSink partFileStream;
    var offset = 0;

    Future<void> rename() async {
      await partFile.rename(filePath);
    }

    if (await partFile.exists()) {
      final localStat = await partFile.stat();
      if (stat.size == localStat.size) {
        onProgress(stat.size!, stat.size!); // 完成时触发100%进度
        return await rename();
      }
      offset = localStat.size;
      partFileStream = partFile.openWrite(mode: FileMode.append);
    } else {
      partFileStream = partFile.openWrite(mode: FileMode.write);
    }

    int bytesDownloaded = offset;
    onProgress(bytesDownloaded, stat.size!);

    final dataStream = await minio.getPartialObject(bucketName, object, offset);
    await for (var chunk in dataStream) {
      bytesDownloaded += chunk.length;
      partFileStream.add(chunk);
      onProgress(bytesDownloaded, stat.size!);
    }

    await partFileStream.close();

    final localStat = await partFile.stat();
    if (localStat.size != stat.size) {
      throw MinioError('Size mismatch between downloaded file and the object');
    }

    return rename();
  }

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
    List<String> folders = await listFolders(prefix);
    for (var file in files) {
      if (folders.contains(file)) {
        List<Object> folderFiles = await listFiles(file, true);
        for (var f in folderFiles) {
          await minio.removeObject(bucketName, f.key!);
        }
        continue;
      }
      await minio.removeObject(bucketName, file);
    }
  }
}
