import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_hover/smooth_hover.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smooth Hover Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmoothHoverScope(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 24.0,
            children: <Widget>[
              _HoverObject(0),
              _HoverObject(1),
              _HoverObject(2),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoverObject extends StatelessWidget {
  const _HoverObject(this.index);

  final int index;

  @override
  Widget build(BuildContext context) {
    return SmoothHover(
      inkDecoration: BoxDecoration(
        color: const Color.fromARGB(124, 227, 227, 227),
        borderRadius: BorderRadius.circular(16.0),
      ),
      tooltipText: switch (index) {
        0 => 'Hello World',
        1 => 'Hello the whole world',
        2 => 'Hello',
        _ => throw UnimplementedError(),
      },
      child: Container(
        width: switch (index) {
          0 => 300,
          1 => 300,
          2 => 400,
          _ => throw UnimplementedError(),
        },
        height: 80.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              blurStyle: BlurStyle.outer,
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8.0,
            children: [
              SizedBox(width: 16),
              Icon(Icons.favorite, size: 24, color: Colors.pink),
              Text(
                'Item ${index + 1}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Spacer(),
              CupertinoListTileChevron(),
              SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}
