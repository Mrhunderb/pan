import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:pan/services/oss.dart';

class PdfView extends StatefulWidget {
  final String pdfPath;

  const PdfView({super.key, required this.pdfPath});

  @override
  State<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  late final String pdfName;

  @override
  void initState() {
    super.initState();
    pdfName = widget.pdfPath.split('/').last;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pdfName),
      ),
      body: Center(
        child: FutureBuilder(
          future: OssService.downloadFileInTemp(widget.pdfPath),
          builder: (context, futureSnapshot) {
            if (futureSnapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (futureSnapshot.hasError) {
              return Text('Error: ${futureSnapshot.error}');
            }
            final localPath = futureSnapshot.data as String;
            return PDFView(
              filePath: localPath,
            );
          },
        ),
      ),
    );
  }
}
