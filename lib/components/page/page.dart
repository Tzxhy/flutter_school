

import 'package:flutter/material.dart';

class Page extends StatelessWidget {

  const Page({
    this.title,
    this.builder,
  });

  final String title;

  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(title ?? '标题'),
        actions: <Widget>[
          Icon(Icons.keyboard_backspace),
          Icon(Icons.keyboard_backspace),
          Icon(Icons.keyboard_backspace),
        ],
      ),
      body: Builder(
        builder: builder,
      ),
    );
  }
}
