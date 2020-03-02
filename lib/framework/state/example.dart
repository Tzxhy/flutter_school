

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_school/framework/state/squash.dart';
int i = 0;
class MyApp extends StatelessWidget {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    print('MyApp ' + (i++).toString());
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('squash example'),
        ),
        body: const Body(),
      )
    );
  }
}

class Counter extends SquashChangeNotifier {
  int time = 0;

  void increasment() {
    time += 1;
    notifyListeners();
  }
}

class ColorConfig extends SquashChangeNotifier {
  Color textColor = Colors.black;

  void changeTextColor() {
    textColor = Color(0xff000000 + Random().nextInt(0xffffff));
    notifyListeners();
  }
}

class Body extends StatelessWidget {
  const Body();

  @override
  Widget build(BuildContext context) {
    print('Body ' + (i++).toString());
    return StoreProvider(
      providers: [
        ChangeNotifierProvider(create: () => Counter()),
        ChangeNotifierProvider(create: () => ColorConfig()),
      ],
      child: const MyPage(),
    );
  }
}

class MyPage extends StatelessWidget {

  const MyPage();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const TestText(),
        const Add(),
        const ShowTime(),
        const ShowColor(),
      ],
    );
  }
}

class TestText extends StatelessWidget {
  const TestText();

  @override
  Widget build(BuildContext context) {
    print('build TestText ' + (i++).toString());
    Counter data = Squash.of<Counter>(context);

    return Text('点击了：' + (data?.time?.toString() ?? '') + ' 次。');
  }
}

class Add extends StatelessWidget {

  const Add();

  @override
  Widget build(BuildContext context) {
    print('build Add ' + (i++).toString());
    return GestureDetector(
      onTap: () {
        Squash.of<Counter>(context, listen: false).increasment();
      },
      child: Container(
        color: Colors.blue,
        child: Text('点击'),
      ),
    );
  }
}

class ShowTime extends StatelessWidget {

  const ShowTime();

  @override
  Widget build(BuildContext context) {
    print('build ShowTime ' + (i++).toString());
    Counter data = Squash.of<Counter>(context, listen: true);
    return Text(data?.updateDate?.toString() ?? '');
  }

}

class ShowColor extends StatelessWidget {
  const ShowColor();

  @override
  Widget build(BuildContext context) {
    print('build ShowColor ' + (i++).toString());
    ColorConfig data = Squash.of<ColorConfig>(context, listen: true);
    return GestureDetector(
      onTap: () {
        data.changeTextColor();
      },
      child: Text('灰色', style: TextStyle(color: data.textColor)),
    );
  }
}
