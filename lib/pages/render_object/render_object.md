## 渲染对象
在 flutter 中，我们通常可以使用官方提供的大量 widget，即使官方没有提供，也能通过 `Stack`、`Row` 等布局组件来实现一些自定义的组件。不过，组合一些组件，来实现一些复杂的通用组件（尤其是涉及到频繁交互而导致频繁绘制的），性能高吗？回答这个问题前，先思考一下：如何实现 iOS 风格的 Switch？如果你的答案是利用`Stack`来层层放置已有组件，那你就需要学习这篇教程了；如果你的答案是基于`RenderObjectWidget`来实现自定义整个绘制流程，或者说利用类似`CustomPaint`这种自定义绘制的方案，那么本教程对你应该作用不大，可以跳过。

## widget-element-renderObject 关系
具体参考[widget-element-renderObject](https://www.tanzhixuan.top/2019/10/04/flutter%E4%B8%ADwidget-element-renderObject%E5%85%B3%E7%B3%BB/#more)。不赘述。


## 开始我们的学习
这篇文章，我们将以 `Switch` 这个官方已实现的组件为例，讲解使用 `RenderObjectWidget` 和 `CustomPaint` 来实现我们的新组件。首先我们需要知道的是，官方提供的`CupertinoSwitch`组件还没实现 iOS 上的开关标签 UI。如果在使用时需要这种效果，那么就需要自己实现了。
![未选中](http://www.tanzhixuan.top/ng-s1/static/upload/img/6be26730/8722adc7ed5c5.png)
![选中](http://www.tanzhixuan.top/ng-s1/static/upload/img/6be26730/96a384a075397.png)

### 使用`RenderObjectWidget`
#### 构思
首先看一下 `CupertinoSwitch` 的实现方式：
> StatefulWidget -> Opacity -> _CupertinoSwitchRenderObjectWidget -> _RenderCupertinoSwitch

上面就是 `CupertinoSwitch` 组件的实现路径。暴露一个有状态的组件，内部是基于 `_CupertinoSwitchRenderObjectWidget` 这个叶节点渲染对象（忽略 Opacity 这个组件）。所以说，所有的逻辑，基本上都在 `_CupertinoSwitchRenderObjectWidget` 这里实现的。

让我们由浅入深，先从基础组件开始：

#### 基础配置组件
这里的顶层组件，与原有的 `CupertinoSwitch` 相差无几，只是多了一个`openOrCloseLabel` 属性而已（参考 iOS 上叫做开关标签的概念）。
```dart
/// 使用 [LeftRenderObjectWidget] 完成绘制
/// 参考 [CupertinoSwitch].
/// 在[CupertinoSwitch]基础上，增加iOS开关标签的功能
class CustomCupertinoSwitch extends StatefulWidget {

  const CustomCupertinoSwitch({
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
    return _CupertinoSwitchState();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('value', value: value, ifTrue: 'on', ifFalse: 'off', showName: true));
    properties.add(ObjectFlagProperty<ValueChanged<bool>>('onChanged', onChanged, ifNull: 'disabled'));
  }
  
}
const double _kCupertinoSwitchDisabledOpacity = .5;

class _CupertinoSwitchState extends State<CustomCupertinoSwitch> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.onChanged == null ? _kCupertinoSwitchDisabledOpacity : 1.0,
      child: _CustomCupertinoSwitchRenderObjectWidget(
        value: widget.value,
        activeColor: widget.activeColor ?? CupertinoColors.activeGreen,
        onChanged: widget.onChanged,
        openOrCloseLabel: widget.openOrCloseLabel,
        vsync: this,
        dragStartBehavior: widget.dragStartBehavior,
      ),
    );
  }
}
```
这里插问一个不太相关的问题：这个组件可以设计成为无状态组件吗？可以小小地思考一下~

答案是否定的：由于这个组件使用了动画，导致相关 `AnimationController` 需要一个 `TickerProvider` 对象，而 `TickerProvider` 对象的两个实现，都是基于 `State` 对象的，所以必须包含一个 `State`。至于为什么动画需要 `TickerProvider`，读者可以深入了解相关内容。

#### 构建叶节点组件
原生 Widget 只被4个抽象类继承，其中之一是`RenderObjectWidget`。而我们当前需要的叶节点组件，是 继承 `RenderObjectWidget` 的抽象类。一般来说，`RenderObjectWidget` 类完成的事就是根据传入的配置，构建、更新对应的 RenderObject。

```dart
class _CustomCupertinoSwitchRenderObjectWidget extends LeafRenderObjectWidget {
  const _CustomCupertinoSwitchRenderObjectWidget({
    Key key,
    this.value,
    this.activeColor,
    this.openOrCloseLabel = false,
    this.onChanged,
    this.vsync,
    this.dragStartBehavior = DragStartBehavior.start,
  }) : super(key: key);

  final bool value;
  final bool openOrCloseLabel;
  final Color activeColor;
  final void Function(bool) onChanged;
  final TickerProvider vsync;
  final DragStartBehavior dragStartBehavior;
  
  /// 创建 RO
  @override
  _RenderCustomCupertinoSwitch createRenderObject(BuildContext context) {
    return _RenderCustomCupertinoSwitch(
      value: value,
      activeColor: activeColor,
      closeOrOpenLabel: openOrCloseLabel,
      onChanged: onChanged,
      textDirection: Directionality.of(context),
      vsync: vsync,
      dragStartBehavior: dragStartBehavior,
    );
  }

  /// 更新 RO
  @override
  void updateRenderObject(BuildContext context, _RenderCustomCupertinoSwitch renderObject) {
    renderObject
      ..value = value
      ..activeColor = activeColor
      ..onChanged = onChanged
      ..textDirection = Directionality.of(context)
      ..vsync = vsync
      ..dragStartBehavior = dragStartBehavior;
  }
}
```

#### 实现对应的 RO
这里为了简单，把 drag 相关的事件删了，只保留了 tap。对比于 `_RenderCupertinoSwitch`，其实只是在 `paint` 这一过程中增加了相关实现：增加了绘制圆圈、竖线的操作。

```dart
class _RenderCustomCupertinoSwitch extends RenderConstrainedBox {
  _RenderCustomCupertinoSwitch({
    @required bool value,
    @required Color activeColor,
    @required bool closeOrOpenLabel,
    ValueChanged<bool> onChanged,
    @required TextDirection textDirection,
    @required TickerProvider vsync,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
  }) : _value = value,
       _activeColor = activeColor,
       _onChanged = onChanged,
       _textDirection = textDirection,
       _vsync = vsync,
       _closeOrOpenLabel = closeOrOpenLabel,
       super(additionalConstraints: const BoxConstraints.tightFor(width: _kSwitchWidth, height: _kSwitchHeight)) {
    _tap = TapGestureRecognizer() // 生成针对点击的对象，并绑定相关 tap 事件
      ..onTapDown = _handleTapDown
      ..onTap = _handleTap
      ..onTapUp = _handleTapUp
      ..onTapCancel = _handleTapCancel;
    _positionController = AnimationController(
      duration: _kToggleDuration,
      value: value ? 1.0 : 0.0,
      vsync: vsync,
    );
    _position = CurvedAnimation( // 拖动块位置
      parent: _positionController,
      curve: Curves.linear,
    )..addListener(markNeedsPaint)
     ..addStatusListener(_handlePositionStateChanged);
    _reactionController = AnimationController( // 整体状态进度，用于控制拖动块大小等状态
      duration: _kReactionDuration,
      vsync: vsync,
    );
    _reaction = CurvedAnimation(
      parent: _reactionController,
      curve: Curves.ease,
    )..addListener(markNeedsPaint);
  }

  AnimationController _positionController;
  CurvedAnimation _position;
  bool _closeOrOpenLabel;
  bool get closeOrOpenLabel {
    return _closeOrOpenLabel;
  }
  set closeOrOpenLabel(bool value) {
    if (value != null) {
      _closeOrOpenLabel = value;
    }
  }
  AnimationController _reactionController;
  Animation<double> _reaction;
  
  bool get value => _value;
  bool _value;

  set value(bool value) {
    assert(value != null);
    if (value == _value)
      return;
    _value = value;
    markNeedsSemanticsUpdate();
    _position
      ..curve = Curves.ease
      ..reverseCurve = Curves.ease.flipped;
    if (value)
      _positionController.forward();
    else
      _positionController.reverse();
  }

  TickerProvider get vsync => _vsync;
  TickerProvider _vsync;
  set vsync(TickerProvider value) {
    assert(value != null);
    if (value == _vsync)
      return;
    _vsync = value;
    _positionController.resync(vsync);
    _reactionController.resync(vsync);
  }

  Color get activeColor => _activeColor;
  Color _activeColor;
  set activeColor(Color value) {
    assert(value != null);
    if (value == _activeColor)
      return;
    _activeColor = value;
    markNeedsPaint();
  }

  ValueChanged<bool> get onChanged => _onChanged;
  ValueChanged<bool> _onChanged;
  set onChanged(ValueChanged<bool> value) {
    if (value == _onChanged)
      return;
    final bool wasInteractive = isInteractive;
    _onChanged = value;
    if (wasInteractive != isInteractive) {
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }

  TextDirection get textDirection => _textDirection;
  TextDirection _textDirection;
  set textDirection(TextDirection value) {
    assert(value != null);
    if (_textDirection == value)
      return;
    _textDirection = value;
    markNeedsPaint();
  }

  bool get isInteractive => onChanged != null;

  TapGestureRecognizer _tap;
  HorizontalDragGestureRecognizer _drag;

  /// 当绑定该 RO 时的操作
  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    if (value)
      _positionController.forward();
    else
      _positionController.reverse();
    if (isInteractive) {
      switch (_reactionController.status) {
        case AnimationStatus.forward:
          _reactionController.forward();
          break;
        case AnimationStatus.reverse:
          _reactionController.reverse();
          break;
        case AnimationStatus.dismissed:
        case AnimationStatus.completed:
          // nothing to do
          break;
      }
    }
  }

  @override
  void detach() {
    _positionController.stop();
    _reactionController.stop();
    super.detach();
  }

  void _handlePositionStateChanged(AnimationStatus status) {
    if (isInteractive) {
      if (status == AnimationStatus.completed && !_value)
        onChanged(true);
      else if (status == AnimationStatus.dismissed && _value)
        onChanged(false);
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (isInteractive)
      _reactionController.forward();
  }

  void _handleTap() {
    if (isInteractive) {
      onChanged(!_value);
      _emitVibration();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (isInteractive)
      _reactionController.reverse();
  }

  void _handleTapCancel() {
    if (isInteractive)
      _reactionController.reverse();
  }

  void _emitVibration() { // iOS 提供振动
    switch(defaultTargetPlatform) {
      case TargetPlatform.iOS:
        HapticFeedback.lightImpact();
        break;
      case TargetPlatform.fuchsia:
      case TargetPlatform.android:
        break;
    }
  }

  /// 当前 RO 响应命中测试
  @override
  bool hitTestSelf(Offset position) => true;

  /// 处理事件
  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent && isInteractive) {
      _drag?.addPointer(event);
      _tap.addPointer(event);
    }
  }

  final CupertinoThumbPainter _thumbPainter = CupertinoThumbPainter();

  /// 绘制
  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;

    final double currentValue = _position.value;
    final double currentReactionValue = _reaction.value;

    double visualPosition;
    switch (textDirection) {
      case TextDirection.rtl:
        visualPosition = 1.0 - currentValue;
        break;
      case TextDirection.ltr:
        visualPosition = currentValue;
        break;
    }

    final Color trackColor = _value ? activeColor : _kTrackColor;
    final double borderThickness = 1.5 + (_kTrackRadius - 1.5) * math.max(currentReactionValue, currentValue);

    final Paint paint = Paint()
      ..color = trackColor;

    final Rect trackRect = Rect.fromLTWH(
        offset.dx + (size.width - _kTrackWidth) / 2.0,
        offset.dy + (size.height - _kTrackHeight) / 2.0,
        _kTrackWidth,
        _kTrackHeight,
    );
    final RRect outerRRect = RRect.fromRectAndRadius(trackRect, const Radius.circular(_kTrackRadius));
    final RRect innerRRect = RRect.fromRectAndRadius(trackRect.deflate(borderThickness), const Radius.circular(_kTrackRadius));
    canvas.drawDRRect(outerRRect, innerRRect, paint);
    
    Paint labelLine = Paint()
      ..color = Colors.white;
    Paint labelCircle = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke;
    // 绘制竖线与圆圈
    canvas.drawRect(Rect.fromLTWH(offset.dx + 15, offset.dy + 14, 2, 10), labelLine);
    canvas.drawCircle(Offset(offset.dx + size.width - 16, offset.dy + 19), 4, labelCircle);

    final double currentThumbExtension = CupertinoThumbPainter.extension * currentReactionValue;
    final double thumbLeft = lerpDouble(
      trackRect.left + _kTrackInnerStart - CupertinoThumbPainter.radius,
      trackRect.left + _kTrackInnerEnd - CupertinoThumbPainter.radius - currentThumbExtension,
      visualPosition,
    );
    final double thumbRight = lerpDouble(
      trackRect.left + _kTrackInnerStart + CupertinoThumbPainter.radius + currentThumbExtension,
      trackRect.left + _kTrackInnerEnd + CupertinoThumbPainter.radius,
      visualPosition,
    );
    final double thumbCenterY = offset.dy + size.height / 2.0;

    _thumbPainter.paint(canvas, Rect.fromLTRB(
      thumbLeft,
      thumbCenterY - CupertinoThumbPainter.radius,
      thumbRight,
      thumbCenterY + CupertinoThumbPainter.radius,
    ));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {}
}
```
RO 中存在着许多函数，可以根据当前需求重写一些函数。