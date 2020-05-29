import 'package:flutter/material.dart';
import 'package:flutter_school/pages/update_data/update_data.dart';
import 'package:flutter_school/pages/update_data/page/case1.dart' as APP1;
import 'package:flutter_school/pages/update_data/page/case2.dart' as APP2;
import 'package:flutter_school/pages/render_object/render_object.dart' as APP3;
import 'components/page/page_item.dart';
import 'package:flutter_school/pages/temp/provider.dart' as TEMP;
import 'package:flutter_school/framework/state/squash.dart' as SQUASH;
import 'package:flutter_school/framework/state/example.dart' as SQUASH_EXAMPLE;
import 'package:flutter_school/pages/state_manage/bloc/app.dart' as BLOC;
import 'package:flutter_school/pages/state_manage/provider/provider.dart' as Provider;
import 'package:flutter_school/pages/state_manage/redux/redux.dart' as Redux;
// void main() => runApp(TEMP.MyApp());
// void main() => runApp(SQUASH_EXAMPLE.MyApp());
void main() => runApp(MyApp());


Widget setState(_) => const SignInPageNavigation();
Widget valueNotifier(_) => const APP1.MyApp();
Widget constFlutter(_) => const APP2.App();
Widget renderObject(_) => const APP3.Page();

const List<PageItemData> statePageList = [
  const PageItemData(
    title: '几种数据更新方式',
    pageBuilder: setState,
  ),
  const PageItemData(
    title: '观察者 + 多个单状态InheritedWidget',
    pageBuilder: valueNotifier,
  ),
];

const List<PageItemData> lowerList = [
  const PageItemData(
    title: '自定义组件',
    pageBuilder: renderObject,
  ),
];

const List<PageItemData> optimizationPageList = [
  const PageItemData(
    title: 'flutter 中的 const 组件',
    pageBuilder: constFlutter,
  ),
];

Widget blocManege(_) => const BLOC.MyBLoCApp();
Widget providerManege(_) => const Provider.MyApp();
Widget reduxManege(_) => const Redux.MyApp();
const List<PageItemData> stateManegePageList = [
  const PageItemData(
    title: 'BLoC',
    pageBuilder: blocManege,
  ),
  const PageItemData(
    title: 'Provider',
    pageBuilder: providerManege,
  ),
  const PageItemData(
    title: 'Redux',
    pageBuilder: reduxManege,
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
              const PageItemGroup(
                title: '优化相关',
                itemList: optimizationPageList,
              ),
              const PageItemGroup(
                title: '底层相关',
                itemList: lowerList,
              ),
              const PageItemGroup(
                title: '状态管理',
                itemList: stateManegePageList,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
