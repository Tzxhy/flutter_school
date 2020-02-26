import 'package:flutter/material.dart';
import 'package:flutter_school/pages/update_data/update_data.dart';
import 'package:flutter_school/pages/update_data/page/case1.dart' as APP1;
import 'package:flutter_school/pages/update_data/page/case2.dart' as APP2;
import 'components/page/page_item.dart';

void main() => runApp(MyApp());


Widget setState(_) => const SignInPageNavigation();
Widget valueNotifier(_) => const APP1.MyApp();
Widget constFlutter(_) => const APP2.App();

const List<PageItemData> statePageList = [
  const PageItemData(
    title: '几种数据更新方式',
    pageBuilder: setState,
  ),
  const PageItemData(
    title: '观察者 + 多个单状态InheritedWidget',
    pageBuilder: valueNotifier,
  ),
  const PageItemData(
    title: 'flutter 中的 const 组件',
    pageBuilder: constFlutter,
  ),
];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter学习',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('flutter学习'),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const PageItemGroup(
                title: '数据更新',
                itemList: statePageList,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
