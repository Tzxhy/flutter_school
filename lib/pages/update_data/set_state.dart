
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_school/pages/update_data/update_data.dart'
  show NOW_STATUS, SignInButton;

class SignInPageSetState extends StatefulWidget {
  const SignInPageSetState();

  @override
  State<StatefulWidget> createState() {
    return _SignInPageSetState();
  }
}

class _SignInPageSetState extends State<SignInPageSetState> {

  NOW_STATUS status = NOW_STATUS.unlogin;

  void _handlePress() {
    if (status == NOW_STATUS.login) {
      setState(() {
        status = NOW_STATUS.unlogin;
      });
    } else if (status == NOW_STATUS.unlogin) {
      setState(() {
        status = NOW_STATUS.logining;
      });
      Timer(const Duration(milliseconds: 3000), () {
        setState(() {
          status = NOW_STATUS.login;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget _child;
    
    _child = SignInButton(
      text: status == NOW_STATUS.unlogin ? '登录' : '退出登录',
      loading: status == NOW_STATUS.logining,
      onPressed: _handlePress,
    );
    
    return Center(
      child: _child,
    );
  }
}
