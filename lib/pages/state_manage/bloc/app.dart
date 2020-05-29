import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_school/pages/state_manage/bloc/bloc.dart';

class MyBLoCApp extends StatelessWidget {

  const MyBLoCApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<CounterBloc>(create: (context) => CounterBloc()),
          BlocProvider<BalanceBloc>(create: (context) => BalanceBloc()),
        ],
        child: const CounterPage(),
      ),
    );
  }

}

class CounterPage extends StatelessWidget {
  const CounterPage();

  @override
  Widget build(BuildContext context) {
    // return Container();
    // ignore: close_sinks
    final CounterBloc counterBloc = BlocProvider.of<CounterBloc>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: FloatingActionButton(
                heroTag: 'add',
                child: Icon(Icons.add),
                onPressed: () {
                  counterBloc.add(CounterEvent.increment);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: FloatingActionButton(
                heroTag: 'des',
                child: Icon(Icons.remove),
                onPressed: () {
                  counterBloc.add(CounterEvent.decrement);
                },
              ),
            ),
            const Page(),
          ],
        ),
      ),
    );
  }
}


class Page extends StatelessWidget {

  const Page();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        BlocBuilder<CounterBloc, int>(
          builder: (context, int state) {
            return Text(
                state.toString(),
              style: TextStyle(fontSize: 24.0),
            );
          }
        ),
        BlocBuilder<BalanceBloc, Balance>(
          builder: (context, Balance balance) {
            return Text(
                balance.rmb.toString() + ' ' + balance.dollar.toString(),
              style: TextStyle(fontSize: 24.0),
            );
          }
        ),
      ],
    );
  }

}
