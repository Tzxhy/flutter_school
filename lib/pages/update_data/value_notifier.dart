


import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_school/pages/update_data/update_data.dart';



class SignInPageValueNotifier extends StatefulWidget {

  SignInPageValueNotifier({
    this.notifier,
  });

  final ValueNotifier<NOW_STATUS> notifier;

  static SignInPageValueNotifier create(BuildContext context) {
    ValueNotifier<NOW_STATUS> loginNotifier = ValueNotifier(NOW_STATUS.unlogin);
    return SignInPageValueNotifier(
      notifier: loginNotifier,
    );
  }

  @override
  State<StatefulWidget> createState() {
    return _SignInPageValueNotifierState();
  }
}


class _SignInPageValueNotifierState extends State<SignInPageValueNotifier> {

  NOW_STATUS loginStatus;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.notifier.removeListener(_updateState);
    widget.notifier.addListener(_updateState);
    loginStatus = widget.notifier.value;
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    if (loginStatus != widget.notifier.value) {
      setState(() {
        loginStatus = widget.notifier.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SignInButton(
        text: widget.notifier.value == NOW_STATUS.login ? '已登录' : '登录',
        loading: widget.notifier.value == NOW_STATUS.logining,
        onPressed: () {
          if (widget.notifier.value == NOW_STATUS.unlogin) {
            widget.notifier.value = NOW_STATUS.logining;
            Timer(const Duration(seconds: 3), () {
              widget.notifier.value = NOW_STATUS.login;
            });
          } else if (widget.notifier.value == NOW_STATUS.login) {
            widget.notifier.value = NOW_STATUS.unlogin;
          }
        },
      ),
    );
  }
}
