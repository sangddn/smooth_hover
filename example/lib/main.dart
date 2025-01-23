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
        child: Row(
          children: [
            Expanded(child: _Tiles()),
            Expanded(child: _MenuButtons())
          ],
        ),
      ),
    );
  }
}

class _Tiles extends StatelessWidget {
  const _Tiles();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 24.0,
      children: <Widget>[
        _Tile(0),
        _Tile(1),
        _Tile(2),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.index);

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

class _MenuButtons extends StatelessWidget {
  const _MenuButtons();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          border: Border.all(width: 0.75, color: Colors.grey),
        ),
        constraints: BoxConstraints(maxWidth: 300.0),
        margin: EdgeInsets.all(32.0),
        padding: EdgeInsets.all(12.0),
        child: Column(
          spacing: 2.0,
          children: [
            _MenuButton(CupertinoIcons.home, 'Home'),
            _MenuButton(CupertinoIcons.settings, 'Settings'),
            _MenuButton(CupertinoIcons.bell, 'Notifications'),
            _MenuButton(CupertinoIcons.person, 'Profile'),
            _MenuButton(CupertinoIcons.info, 'About'),
            _MenuButton(CupertinoIcons.question, 'Help'),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SmoothHover(
      inkPhysics: Spring.swift,
      tooltipText: 'Tooltip for $label',
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, size: 16.0),
            SizedBox(width: 8.0),
            Text(label),
            Spacer(),
            Icon(
              CupertinoIcons.chevron_right,
              size: 16.0,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
