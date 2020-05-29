import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.decrement:
        yield state - 1;
        break;
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }

  @override
  void onTransition(Transition<CounterEvent, int> transition) {
    print(transition);
  }
}

class Balance {
  const Balance({
    this.rmb,
    this.dollar,
  });
  final double rmb;
  final double dollar;
}

@immutable
class BalanceEvent {
  const BalanceEvent({
    this.isPay,
    this.rmb,
    this.dollar,
  });

  final bool isPay;
  final double rmb;
  final double dollar;
}

class BalanceBloc extends Bloc<BalanceEvent, Balance> {
  @override
  Balance get initialState => Balance(rmb: 0, dollar: 0);

  @override
  Stream<Balance> mapEventToState(BalanceEvent event) async* {
    if (event.isPay) { // 付钱
      yield Balance(
        rmb: state.rmb - event.rmb,
        dollar: state.dollar - event.dollar,
      );
    } else {
      yield Balance(
        rmb: state.rmb + event.rmb,
        dollar: state.dollar + event.dollar,
      );
    }
  }
}

