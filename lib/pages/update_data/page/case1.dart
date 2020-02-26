

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MyApp extends StatelessWidget {

  const MyApp();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('观察者 + 多个单状态InheritedWidget'),
      ),
      body: const MyPage(),
    );
  }
}

class MyPage extends StatefulWidget {

  const MyPage();

  @override
  State<StatefulWidget> createState() {
    return _MyPageState();
  }
}

class PageData {
  PageData({
    this.clickTimes,
    this.color,
  });

  final int clickTimes;
  final Color color;

  PageData.defaultInstance():
    clickTimes = 0,
    color = Colors.black;
}

class PageValueNotifier extends ChangeNotifier {
  PageValueNotifier(this.value);
  PageData value;

  void click() {
    value = PageData(
      clickTimes: value.clickTimes + 1,
      color: value.color,
    );
    notifyListeners();
  }

  void changeTextColor() {
    value = PageData(
      clickTimes: value.clickTimes,
      color: Color(Random().nextInt(0xffffff) + 0xff000000),
    );
    notifyListeners();
  }
}

int i = 0;
class _MyPageState extends State<MyPage> {
  PageValueNotifier pageData;
  Timer _timer;
  @override
  void initState() { 
    super.initState();
    // 初始化存储
    pageData = PageValueNotifier(PageData.defaultInstance());
    pageData.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    pageData.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageObserverProxy(
      child: ClickTimeProxy(
        child: TextColorProxy(
          child: const PageComponents(), // 关键代码，这里用一个无状态组件来作为 const child
          color: pageData.value.color,
        ),
        clickTimes: pageData.value.clickTimes,
      ),
      obsever: pageData,
    );
  }
}

class PageComponents extends StatelessWidget {
  const PageComponents();

  @override
  Widget build(BuildContext context) {
    print('build PageComponents ' + (i++).toString());
    return Column(
      children: <Widget>[
        ClickTimes(),
        Text('这个 text 一直不会 rebuild'),
        ChangeTextColor(),
      ],
    );
  }
}

class ChangeTextColor extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    print('rebuild ChangeTextColor ' + (i++).toString());
    TextColorProxy textColorProxy =
      context.inheritFromWidgetOfExactType(TextColorProxy);
    PageObserverProxy pWidget = context.inheritFromWidgetOfExactType(PageObserverProxy);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        pWidget.obsever.changeTextColor();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text('可以变色哟', style: TextStyle(color: textColorProxy.color))
      ),
    );
  }

}

class ClickTimes extends StatelessWidget {

  const ClickTimes();

  @override
  Widget build(BuildContext context) {
    print('build ClickTimes ' + (i++).toString());
    ClickTimeProxy pWidget = context.inheritFromWidgetOfExactType(ClickTimeProxy);
    PageObserverProxy observerProxy = context.inheritFromWidgetOfExactType(PageObserverProxy);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('点击了' + pWidget.clickTimes.toString() + '次'),
        IconButton(
          icon: Icon(Icons.closed_caption),
          onPressed: () {
            observerProxy.obsever.click();
          }
        ),
      ],
    );
  }
}

class PageObserverProxy extends InheritedWidget {
  PageObserverProxy({
    @required Widget child,
    @required this.obsever,
  }): super(child: child);

  final PageValueNotifier obsever;

  @override
  bool updateShouldNotify(PageObserverProxy oldWidget) {
    return obsever != oldWidget.obsever;
  }

  
}

class ClickTimeProxy extends InheritedWidget {

  ClickTimeProxy({
    @required Widget child,
    this.clickTimes,
  }): super(child: child);

  final int clickTimes;

  @override
  bool updateShouldNotify(ClickTimeProxy oldWidget) {
    return clickTimes != oldWidget.clickTimes;
  }
  
}

class TextColorProxy extends InheritedWidget {
  TextColorProxy({
    @required Widget child,
    @required this.color,
  }): super(child: child);

  final Color color;

  @override
  bool updateShouldNotify(TextColorProxy oldWidget) {
    return oldWidget.color != color;
  }

}
