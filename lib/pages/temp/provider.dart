// ignore_for_file: public_member_api_docs, lines_longer_than_80_chars
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// This is an example of a counter application using `provider` + [ChangeNotifier].
///
/// It builds a typical `+` button, with a twist: the texts using the counter
/// are built using the localization framework.
///
/// This shows how to bind our custom [ChangeNotifier] to things like [LocalizationsDelegate].

// void main() => runApp(MyApp());
int i = 0;
class Counter with ChangeNotifier {
  int _count = 0;
  int get count => _count;

  Color color = Colors.black;

  void increment() {
    _count++;
    notifyListeners();
  }

  void changeColor() {
    if (color == Colors.black) {
      color = Colors.pink;
    } else {
      color = Colors.black;
    }
    notifyListeners();
  }
}


class ColorConfig extends ChangeNotifier {
  Color textColor = Colors.black;

  void changeTextColor() {
    textColor = Color(0xff000000 + Random().nextInt(0xffffff));
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ChangeNotifierProvider(create: (_) => Counter());
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Counter()),
        ChangeNotifierProvider(create: (_) => ColorConfig()),
      ],
      child: Consumer<Counter>(
        builder: (context, counter, _) {
          return MaterialApp(
            supportedLocales: const [Locale('en')],
            localizationsDelegates: [
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
              _ExampleLocalizationsDelegate(counter.count),
            ],
            home: const MyHomePage(),
          );
        },
      ),
    );
  }
}

class ExampleLocalizations {
  static ExampleLocalizations of(BuildContext context) {
    return Localizations.of<ExampleLocalizations>(context, ExampleLocalizations);
  }

  const ExampleLocalizations(this._count);

  final int _count;

  String get title => 'Tapped $_count times';
}

class _ExampleLocalizationsDelegate extends LocalizationsDelegate<ExampleLocalizations> {
  _ExampleLocalizationsDelegate(this.count);

  final int count;

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<ExampleLocalizations> load(Locale locale) {
    return SynchronousFuture(ExampleLocalizations(count));
  }

  @override
  bool shouldReload(_ExampleLocalizationsDelegate old) => old.count != count;
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Title()),
      body: const Center(child: CounterLabel()),
      floatingActionButton: const IncrementCounterButton(),
    );
  }
}

class IncrementCounterButton extends StatelessWidget {
  const IncrementCounterButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('IncrementCounterButton ' + (i++).toString());
    return FloatingActionButton(
      onPressed: () {
        Provider.of<Counter>(context, listen: false).increment();
      },
      tooltip: 'Increment',
      child: const Icon(Icons.add),
    );
  }
}

class CounterLabel extends StatelessWidget {
  const CounterLabel({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('CounterLabel ' + (i++).toString());
    final counter = Provider.of<Counter>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          'You have pushed the button this many times:',
        ),
        Text(
          '${counter.count}',
          // ignore: deprecated_member_use
          style: Theme.of(context).textTheme.display1,
        ),
        const TestText(),
      ],
    );
  }
}

class TestText extends StatelessWidget {
  const TestText();
  @override
  Widget build(BuildContext context) {
    print('TestText ' + (i++).toString());
    Color color = Provider.of<Counter>(context).color;
    return GestureDetector(
      onTap: () {
        Provider.of<Counter>(context).changeColor();
      },
      child: Text('hhhh', style: TextStyle(color: color)),
    );
  }

}

class Title extends StatelessWidget {
  const Title({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Title ' + (i++).toString());
    return Text(ExampleLocalizations.of(context).title);
  }
}
