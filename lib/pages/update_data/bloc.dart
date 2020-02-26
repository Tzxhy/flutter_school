


import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_school/pages/update_data/update_data.dart';

class LoginStatus {
  const LoginStatus({
    this.isLogin,
    this.isLoading,
  });
  final bool isLogin;
  final bool isLoading;
}

/// 一个 BLoC 单元
class SignInBloc {
  final _loadingController = StreamController<LoginStatus>();
  Stream<LoginStatus> get loadingStream => _loadingController.stream;

  void setIsLoading(bool loading) => _loadingController.add(LoginStatus(
    isLoading: loading,
    isLogin: false,
  ));

  void setIsLogin(bool isLogin) => _loadingController.add(LoginStatus(
    isLogin: isLogin,
    isLoading: false,
  ));

  Future<void> _signInAnonymously(BuildContext context) async {
    try {
      setIsLoading(true);
      await Future.delayed(Duration(milliseconds: 2000));
    } catch (e) {
      print(e);
    } finally {
      setIsLoading(false);
      setIsLogin(true);
    }
  }

  Future<void> _signOut() async {
    setIsLogin(false);
    return null;
  }

  dispose() {
    _loadingController.close();
  }
}

/// 使用 BLoC 的无状态组件
class SignInPageBloc extends StatelessWidget {
  const SignInPageBloc({Key key, @required this.bloc}) : super(key: key);
  final SignInBloc bloc;

  static Widget create(BuildContext context) {
    return SignInPageBloc(bloc: SignInBloc());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LoginStatus>(
      stream: bloc.loadingStream,
      initialData: const LoginStatus(isLoading: false, isLogin: false),
      builder: (context, snapshot) {
        final isLoading = snapshot.data.isLoading;
        final isLogin = snapshot.data.isLogin;
        return Center(
          child: SignInButton(
            text: isLogin ? '已登录' : '登录',
            loading: isLoading,
            onPressed: () {
              if (!isLogin) {
                bloc._signInAnonymously(context);
              } else {
                bloc._signOut();
              }
            },
          ),
        );
      },
    );
  }
}
