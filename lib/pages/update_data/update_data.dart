

import 'package:flutter/material.dart';
import 'package:flutter_school/pages/update_data/set_state.dart';
import 'package:flutter_school/pages/update_data/value_notifier.dart';

import 'bloc.dart';
import 'inherited.dart';


enum Option {
  setState,

  bloc,

  valueNotifier,

  inherited,
}

enum NOW_STATUS {
  unlogin,

  logining,

  login,
}

class OptionData {
  OptionData({
    this.title,
  });

  final String title;
}

class OptionDatas {
  
  const OptionDatas();
  static Map<String, Map<String, String>> _map = {
    'setState': {
      'title': 'setState',
    },
    'bloc': {
      'title': 'BLoC',
    },
    'valueNotifier': {
      'title': 'valueNotifier',
    },
    'vanilla': {
      'title': 'vanilla',
    },
    'inherited': {
      'title': 'inherited',
    },
  };

  OptionData operator [](Option name) {
    String _name = name.toString().substring(7);
    if (_map.containsKey(_name)) {
      Map<String, String> target = _map[_name];
      return OptionData(
        title: target['title'],
      );
    }
    return null;
  }
}

class SignInPageNavigation extends StatefulWidget {

  const SignInPageNavigation({Key key}) : super(key: key);
  final OptionDatas optionsData = const OptionDatas();

  @override
  State<StatefulWidget> createState() {
    return SignInPageNavigationState();
  }
}


class SignInPageNavigationState extends State<SignInPageNavigation> {
  
  ValueNotifier<Option> option;

  OptionData get optionData => widget.optionsData[option.value];

  @override
  void initState() { 
    super.initState();
    option = ValueNotifier(Option.setState);
    option.addListener(_updateMethod);
  }

  @override
  void dispose() {
    option.removeListener(_updateMethod);
    super.dispose();
  }

  void _updateMethod() {
    setState(() {});
  }

  Widget _buildContent(BuildContext context) {
    switch (option.value) {
      case Option.setState:
        return SignInPageSetState();
      case Option.bloc:
        return SignInPageBloc.create(context);
      case Option.valueNotifier:
        return SignInPageValueNotifier.create(context);
      case Option.inherited:
        return SignInPageInheritedPage();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(optionData.title),
      ),
      endDrawer: MenuSwitcher(
        options: widget.optionsData,
        selectedOption: option,
      ),
      body: _buildContent(context),
    );
  }
}


class MenuSwitcher extends StatefulWidget {
  MenuSwitcher({
    Key key,
    this.options,
    this.selectedOption,
  }): super(key: key);

  final options;
  final ValueNotifier<Option> selectedOption;

  @override
  State<StatefulWidget> createState() {
    return MenuSwitcherState();
  }
}

class MenuSwitcherState extends State<MenuSwitcher> {

  Option selectValue;

  @override
  void initState() { 
    super.initState();
    selectValue = widget.selectedOption.value;
    widget.selectedOption.addListener(_listen);
  }

  @override
  void dispose() {
    widget.selectedOption.removeListener(_listen);
    super.dispose();
  }

  void _listen() {
    setState(() {
      selectValue = widget.selectedOption.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 50),
      width: 200,
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Text('State 方式'),
          RadioListTile<Option>(title: Text('setState'), value: Option.setState, groupValue: selectValue, onChanged: (_) {
            widget.selectedOption.value = _;
          }),
          RadioListTile<Option>(title: Text('BLoC'), value: Option.bloc, groupValue: selectValue, onChanged: (_) {
            widget.selectedOption.value = _;
          }),
          RadioListTile<Option>(title: Text('valueNotifier'), value: Option.valueNotifier, groupValue: selectValue, onChanged: (_) {
            widget.selectedOption.value = _;
          }),
          RadioListTile<Option>(title: Text('inherited'), value: Option.inherited, groupValue: selectValue, onChanged: (_) {
            widget.selectedOption.value = _;
          }),
        ],
      ),
    );
  }
}

class SignInButton extends StatelessWidget {
  SignInButton({
    Key key,
    this.text,
    this.loading = false,
    this.onPressed,
  }): super(key: key);

  final String text;
  final bool loading;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    Widget _child;
    if (loading) {
      _child = CircularProgressIndicator(backgroundColor: Colors.white);
    } else {
      _child = Text(text ?? '登录', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white));
    }
    _child = SizedBox(width: 60, height: 36, child: Center( child: _child));
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: _child,
      ),
    );
  }
}
