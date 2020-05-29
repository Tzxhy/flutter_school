import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

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

const Color _kTrackColor = CupertinoColors.lightBackgroundGray;
const Duration _kReactionDuration = Duration(milliseconds: 300);
const double _kSwitchWidth = 59.0;
const double _kSwitchHeight = 39.0;
const Duration _kToggleDuration = Duration(milliseconds: 200);

const double _kTrackWidth = 51.0;
const double _kTrackHeight = 31.0;
const double _kTrackRadius = _kTrackHeight / 2.0;
const double _kTrackInnerStart = _kTrackHeight / 2.0;
const double _kTrackInnerEnd = _kTrackWidth - _kTrackInnerStart;
const double _kTrackInnerLength = _kTrackInnerEnd - _kTrackInnerStart;


class _RenderCustomCupertinoSwitch extends RenderConstrainedBox {

  _RenderCustomCupertinoSwitch({
    @required bool value,
    @required Color activeColor,
    @required bool closeOrOpenLabel,
    ValueChanged<bool> onChanged,
    @required TextDirection textDirection,
    @required TickerProvider vsync,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
  }) : assert(value != null),
       assert(activeColor != null),
       assert(vsync != null),
       _value = value,
       _activeColor = activeColor,
       _onChanged = onChanged,
       _textDirection = textDirection,
       _vsync = vsync,
       _closeOrOpenLabel = closeOrOpenLabel,
       super(additionalConstraints: const BoxConstraints.tightFor(width: _kSwitchWidth, height: _kSwitchHeight)) {
    _tap = TapGestureRecognizer() // 绑定 tap 事件
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
    _reactionController = AnimationController(
      duration: _kReactionDuration,
      vsync: vsync,
    );
    _reaction = CurvedAnimation( // 整体状态进度，用于控制拖动块大小等状态
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

  DragStartBehavior get dragStartBehavior => _drag.dragStartBehavior;
  set dragStartBehavior(DragStartBehavior value) {
    assert(value != null);
    if (_drag?.dragStartBehavior == value)
      return;
    _drag?.dragStartBehavior = value;
  }

  bool get isInteractive => onChanged != null;

  TapGestureRecognizer _tap;
  HorizontalDragGestureRecognizer _drag;

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

  void _handleDragStart(DragStartDetails details) {
    if (isInteractive) {
      _reactionController.forward();
      _emitVibration();
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (isInteractive) {
      _position
        ..curve = null
        ..reverseCurve = null;
      final double delta = details.primaryDelta / _kTrackInnerLength;
      switch (textDirection) {
        case TextDirection.rtl:
          _positionController.value -= delta;
          break;
        case TextDirection.ltr:
          _positionController.value += delta;
          break;
      }
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_position.value >= 0.5)
      _positionController.forward();
    else
      _positionController.reverse();
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

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent && isInteractive) {
      _drag?.addPointer(event);
      _tap.addPointer(event);
    }
  }

  final CupertinoThumbPainter _thumbPainter = CupertinoThumbPainter();

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;

    final double currentValue = _position.value;
    print(currentValue);
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
    
    // canvas.drawLine(Offset(offset.dx + 15, offset.dy + 5), Offset(offset.dx + 15, offset.dy + 25), line);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(FlagProperty('value', value: value, ifTrue: 'checked', ifFalse: 'unchecked', showName: true));
    description.add(FlagProperty('isInteractive', value: isInteractive, ifTrue: 'enabled', ifFalse: 'disabled', showName: true, defaultValue: true));
  }
}
