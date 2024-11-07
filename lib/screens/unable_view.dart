import 'package:flutter/material.dart';

class UnableView extends StatelessWidget {
  const UnableView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unable View'),
      ),
      body: const Center(
        child: Text(
          '不支持预览此类型文件',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
