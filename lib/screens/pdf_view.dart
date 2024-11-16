import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:pan/services/oss.dart';
import 'package:path_provider/path_provider.dart';

class PdfView extends StatefulWidget {
  final String pdfPath;

  const PdfView({super.key, required this.pdfPath});

  @override
  State<PdfView> createState() => _PdfViewState();
}

class _PdfViewState extends State<PdfView> {
  late final String pdfName;
  late final String pdfFile;
  late Future<void> _initialLoad;

  @override
  void initState() {
    super.initState();
    _initialLoad = _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final downloadedPdfName =
          await OssService.downloadFileInTemp(widget.pdfPath);
      setState(() {
        pdfName = widget.pdfPath.split('/').last;
        pdfFile = downloadedPdfName;
      });
    } catch (e) {
      throw Exception('Failed to get pdf file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pdfName),
      ),
      body: Center(
        child: FutureBuilder(
          future: _initialLoad,
          builder: (context, futureSnapshot) {
            if (futureSnapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (futureSnapshot.hasError) {
              return Text('Error: ${futureSnapshot.error}');
            }
            return PDFView(
              filePath: pdfFile,
            );
          },
        ),
      ),
    );
  }
}
