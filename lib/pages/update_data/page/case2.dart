

import 'package:flutter/material.dart';
int i = 0;
class App extends StatefulWidget {
  const App();
  @override
  State<StatefulWidget> createState() {
    return _AppState();
  }
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('flutter中的const'),
      ),
      body: Column(
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() {}),
            child: Case1(),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() {}),
            child: const Case2(),
          ),
        ],
      ),
    );
  }
}

class Case1 extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    print('build Case1 ' + (i++).toString());
    return Wrapper(
      child: Text('未使用 const 构造'),
    );
  }
}

class Case2 extends StatelessWidget {
  const Case2();

  @override
  Widget build(BuildContext context) {
    print('build Case2 ' + (i++).toString());
    return Wrapper(
      child: Text('使用 const 构造'),
    );
  }
}

class Wrapper extends StatelessWidget {

  const Wrapper({
    this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // print('build Wrapper');
    return Container(
      padding: EdgeInsets.all(30),
      child: child,
    );
  }

}
