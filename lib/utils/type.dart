final Map<String, String> suffixToType = {
  'pdf': 'pdf',
  'doc': 'doc',
  'txt': 'doc',
  'docx': 'doc',
  'png': 'image',
  'jpg': 'image',
  'jpeg': 'image',
  'mp4': 'video',
  'mp3': 'video',
  'mkv': 'video',
  'avi': 'video',
};

final Map<String, String> fileTypeToImagePath = {
  'pdf': 'assets/pdf.png',
  'doc': 'assets/doc.png',
  'image': 'assets/image.png',
  'video': 'assets/video.png',
  'folder': 'assets/folder.png',
  'file': 'assets/file.png',
};

String getFileType(String path, bool isFolder) {
  if (isFolder) {
    return 'folder';
  }
  return suffixToType[path.split('.').last] ?? 'file';
}

String getImagePath(String type) {
  return fileTypeToImagePath[type]!;
}
