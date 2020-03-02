
import 'package:flutter/material.dart';

typedef ProviderCreator<T> = T Function();
typedef ProviderListCreator<T> = List<T> Function();

class StoreProvider extends StatefulWidget{

  StoreProvider({
    Key key,
    @required this.providers,
    @required this.child,
  }): super(key: key);

  final List<_SquashStoreInheritedWithType> providers;

  final Widget child;

  @override
  State<StatefulWidget> createState() {
    return _StoreProviderState();
  }
}

class _StoreProviderState extends State<StoreProvider> {

  List<SquashChangeNotifier> stores = [];

  @override
  void initState() { 
    super.initState();
    widget.providers.forEach((_SquashStoreInheritedWithType f) {
      final store = (f as ChangeNotifierProvider).create();
      stores.add(store);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    addListener();
  }

  @override
  void didUpdateWidget(StoreProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
    addListener();
  }

  @override
  void dispose() {
    stores.forEach((f) {
      f.dispose();
    });
    super.dispose();
  }

  void _update() {
    setState(() {});
  }

  void addListener() {
    stores.forEach((SquashChangeNotifier f) {
      f.removeListener(_update);
      f.addListener(_update);
    });
  }

  Widget wrapInherited() {
    Widget _child = widget.child;
    widget.providers.asMap().forEach((int i, f) {
      _child = f.cloneWithChild(_child, stores[i]);
    });
    return _child;
  }

  @override
  Widget build(BuildContext context) {
    Widget child = wrapInherited();
    return child;
  }
}

typedef ShouldNotify<T> = bool Function(T previous, T now);

class _SquashStoreInherited<T extends SquashChangeNotifier> extends InheritedWidget {
  _SquashStoreInherited({
    Key key,
    @required this.value,
    @required this.updateDate,
    this.shouldNotify,
    @required Widget child,
  }): 
    super(key: key, child: child);

  final T value;
  final DateTime updateDate;

  final ShouldNotify<T> shouldNotify;

  @override
  bool updateShouldNotify(_SquashStoreInherited oldWidget) {
    if (shouldNotify != null) {
      return shouldNotify(oldWidget.value, value);
    }
    return oldWidget.updateDate != updateDate;
  }

}

class SquashChangeNotifier extends ChangeNotifier {

  SquashChangeNotifier() {
    _updateDate = DateTime.now();
  }

  DateTime _updateDate;

  DateTime get updateDate {
    return _updateDate;
  }

  @override
  void notifyListeners() {
    _updateDate = DateTime.now();
    super.notifyListeners();
  }
}

abstract class _SquashStoreInheritedWithType {
  _SquashStoreInherited cloneWithChild(Widget child, SquashChangeNotifier value);
}

class ChangeNotifierProvider<T extends SquashChangeNotifier>
  implements _SquashStoreInheritedWithType {

  ChangeNotifierProvider({
    Key key,
    @required ProviderCreator<T> create,
  }): _create = create;

  final ProviderCreator<T> _create;

  ProviderCreator<T> get create {
    return _create;
  }

  @override
  _SquashStoreInherited cloneWithChild(Widget child, SquashChangeNotifier value) {
    return _SquashStoreInherited<T>(
      child: child,
      value: value,
      updateDate: value.updateDate,
    );
  }
}


class Squash {
  static T of<T extends SquashChangeNotifier>(BuildContext context, {bool listen = true}) {

    _SquashStoreInherited widget;
    if (listen) {
      widget = context.dependOnInheritedWidgetOfExactType<_SquashStoreInherited<T>>();
        ;
    } else {
      widget = context.getElementForInheritedWidgetOfExactType<_SquashStoreInherited<T>>()?.widget
        as _SquashStoreInherited<T>;
    }
    if (widget != null) {
      return widget?.value;
    }
    return null;
  }
}
