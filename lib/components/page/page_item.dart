

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef PageBuilder = Widget Function(BuildContext );

class PageItemData {
  const PageItemData({
    this.title,
    this.pageBuilder,
  });

  final String title;
  final PageBuilder pageBuilder;
}

class PageItem extends StatelessWidget {

  const PageItem({
    Key key,
    this.data,
  }): super(key: key);

  final PageItemData data;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(context, CupertinoPageRoute(
          builder: (_) {
            return data.pageBuilder(_);
          }));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black45)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(data.title),
            Icon(Icons.keyboard_arrow_right),
          ],
        ),
      ),
    );
  }
}

class PageItemGroup extends StatelessWidget {

  const PageItemGroup({
    Key key,
    this.title,
    this.itemList,
  }): super(key: key);

  final String title;

  final List<PageItemData> itemList;

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    children.add( // title
      Container(
        padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
        decoration: BoxDecoration(
          color: Color(0xffe8e8e8),
        ),
        child: Center(
          child: Text(title),
        ),
      )
    );

    children.addAll(
      itemList.map<Widget>(
        (PageItemData item) {
          return PageItem(
            data: item,
          );
        }
      )
    );

    return Column(
      children: children,
    );
  }

}
