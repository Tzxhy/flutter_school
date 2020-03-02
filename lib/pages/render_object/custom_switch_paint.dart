import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// 使用 [CustomPaint] 完成绘制

class CustomPainterSwitcher extends StatefulWidget {

  const CustomPainterSwitcher({
    Key key,
    @required this.value,
    @required this.onChanged,
    this.activeColor,
    this.openOrCloseLabel = false,
    this.dragStartBehavior = DragStartBehavior.start,
  }) : assert(value != null),
       assert(dragStartBehavior != null),
       super(key: key);
  final bool value;
  final void Function(bool) onChanged;
  final bool openOrCloseLabel;
  final Color activeColor;
  final DragStartBehavior dragStartBehavior;


  @override
  State<StatefulWidget> createState() {
    return _CustomPainterSwitcherState();
  }

}

class _CustomPainterSwitcherState extends State<CustomPainterSwitcher>
  with TickerProviderStateMixin<CustomPainterSwitcher> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        print('click');
      },
      child: SizedBox(
        width: 86,
        height: 40,
        child: ClipRect(
          child: CustomPaint(
          painter: _CustomSwitcPainter(),
        ),
        )
      )
    );
  }
}

class _CustomSwitcPainter extends CustomPainter {

  const _CustomSwitcPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, 200, 200), Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  @override
  bool hitTest(Offset position) => true;

}
