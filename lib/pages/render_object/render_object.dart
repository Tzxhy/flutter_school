

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_school/pages/render_object/custom_switch.dart';
import 'package:flutter_school/pages/render_object/custom_switch_paint.dart';

class Page extends StatelessWidget {
  const Page();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('自定义组件'),
      ),
      body: SingleChildScrollView(
        child: const _Page(),
      )
    );
  }
}

class _Page extends StatefulWidget {
  const _Page();

  @override
  State<StatefulWidget> createState() {
    return _PageState();
  }
}

class _PageState extends State<_Page> {

  bool checked = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CupertinoSwitch(
            value: checked,
            onChanged: (bool _) {
              setState(() {
                checked = _;
              });
            },
          ),
          CustomCupertinoSwitch(
            value: checked,
            onChanged: (bool _) {
              setState(() {
                checked = _;
              });
            },
          ),
          CustomPainterSwitcher(
            value: checked,
            onChanged: (bool _) {
              setState(() {
                checked = _;
              });
            },
          ),
        ],
      )
    );
  }

}

