


import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_school/pages/update_data/update_data.dart';

class SignInPageInheritedWidgetProxy extends InheritedWidget {
  SignInPageInheritedWidgetProxy({
    @required Widget child,
    this.loginStatus,
  }): super(child: child);

  final NOW_STATUS loginStatus;

  @override
  bool updateShouldNotify(SignInPageInheritedWidgetProxy oldWidget) {
    return oldWidget.loginStatus != loginStatus;
  }
}

class SignInPageInheritedPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SignInPageInheritedPageState();
  }
}

class _SignInPageInheritedPageState extends State<SignInPageInheritedPage> {

  NOW_STATUS status = NOW_STATUS.unlogin;

  void _handlePress() {
    if (status == NOW_STATUS.unlogin) {
      setState(() {
        status = NOW_STATUS.logining;
      });
      Timer(const Duration(seconds: 3), () {
        setState(() {
          status = NOW_STATUS.login;  
        });
      });
    } else if (status == NOW_STATUS.login) {
      setState(() {
        status = NOW_STATUS.unlogin;
      });
    }
  }

  Timer _timer;
  @override
  void initState() {
    super.initState();

    // _timer = Timer.periodic(const Duration(seconds: 2), (_) {
    //   setState(() {
        
    //   });
    // });
  }

  @override
  void dispose() {
    _timer?.cancel();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('build _SignInPageInheriedAppState');
    return Center(
      child: SignInPageInheritedWidgetProxy(
        child: const SignInButtonInheried(),
        loginStatus: status,
      ),
    );
  }
}

int i = 0;
/// 需要以 const 方式构造
class SignInButtonInheried extends StatelessWidget {
  const SignInButtonInheried();

  @override
  Widget build(BuildContext context) {
    i++;
    print('build SignInButtonInheried '+ i.toString());
    SignInPageInheritedWidgetProxy proxy =
      context.inheritFromWidgetOfExactType(SignInPageInheritedWidgetProxy);
    NOW_STATUS status = proxy.loginStatus;
    _SignInPageInheritedPageState p =
      context.ancestorStateOfType(const TypeMatcher<_SignInPageInheritedPageState>());
    return Center(
      child: SignInButton(
        text: status == NOW_STATUS.login ? '已登录' : '登录',
        loading: status == NOW_STATUS.logining,
        onPressed: p._handlePress,
      ),
    );
  }
}
