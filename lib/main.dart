import 'package:flutter/material.dart';
import 'package:pan/models/task.dart';
import 'package:pan/screens/pan.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskQueue(3),
      child: MaterialApp(
        title: 'Z 盘',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const PanFilePage(title: 'Z 盘', prefix: ''),
      ),
    );
  }
}
