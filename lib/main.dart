import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/my_data_display.dart';

void main() {
  runApp(MyApp());
}

class MyDummyData with ChangeNotifier {
  String data = 'Some initial data...';
  int counter = 0;

  void changeDataAndNotifyListeners(String newData) {
    data = newData;
    notifyListeners();
  }

  void incrementAndNotifyListeners() {
    counter++;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  final MyDummyData data = MyDummyData();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MyDummyData>.value(
      // We use ".value" to provide the existing MyDummyData (to be able to use it in the AppBar title), instead of creating a new instance
      value: data,
      // return ChangeNotifierProvider<MyDummyData>(
      //   create: (BuildContext context) => MyDummyData(), // create is called lazely by default (can be changed via the "lazy" parameter)
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text(data.data), // Note: this doesn't get updated
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => data.incrementAndNotifyListeners(),
          ),
          body: Column(
            children: [
              MyDataDisplay(),
              Expanded(child: Level1()),
            ],
          ),
        ),
      ),
    );
  }
}

class Level1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Level2();
  }
}

class Level2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(child: Level3()),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          margin: const EdgeInsets.only(bottom: 35.0, right: 75.0),
          child: TextField(
            onChanged: (value) =>
                Provider.of<MyDummyData>(context, listen: false)
                    .changeDataAndNotifyListeners(value),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class Level3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      child: ListView(
        padding: const EdgeInsets.all(15.0),
        children: [
          TestProviderListeningUsingProviderOf(),
          TestProviderNotListeningUsingProviderOf(),
          TestProviderListeningUsingContextWatch(),
          TestProviderNotListeningUsingContextRead(),
          TestProviderListeningUsingConsumer(),
          TestProviderPartlyListeningUsingContextSelect(),
          TestProviderPartlyListeningUsingSelector(),
        ],
      ),
    );
  }
}

class TestProviderListeningUsingProviderOf extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final valueProviderOf = Provider.of<MyDummyData>(context);
    return DisplayColumn(
        label: 'Provider.of<Data>(context)', value: valueProviderOf.data);
  }
}

class TestProviderListeningUsingContextWatch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Equivalent to 'Provider.of', but is accessible only inside [StatelessWidget.build] and [State.build].
    final valueContextWatch = context.watch<MyDummyData>();
    return DisplayColumn(
        label: 'context.watch<Data>()', value: valueContextWatch.data);
  }
}

class TestProviderNotListeningUsingProviderOf extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final valueProviderOfWithoutListening =
        Provider.of<MyDummyData>(context, listen: false);
    return DisplayColumn(
        label: 'Provider.of<Data>(context, listen: false)',
        value: valueProviderOfWithoutListening.data);
  }
}

class TestProviderNotListeningUsingContextRead extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final valueContextRead = context.read<MyDummyData>();
    return DisplayColumn(
        label: 'context.read<Data>()', value: valueContextRead.data);
  }
}

class TestProviderListeningUsingConsumer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MyDummyData>(
      builder: (context, myDummyDataModel, child) => DisplayColumn(
          label: 'Consumer<Data>(builder: ...)', value: myDummyDataModel.data),
    );
  }
}

class TestProviderPartlyListeningUsingContextSelect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int counter = context.select<MyDummyData, int>((data) => data.counter);
    return DisplayColumn(
        label: 'context.select<Data, int>((d) => d.counter)',
        value: counter.toString());
  }
}

class TestProviderPartlyListeningUsingSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<MyDummyData, int>(
      selector: (context, myDummyDataModel) => myDummyDataModel.counter,
      builder: (context, counter, child) => DisplayColumn(
          label: 'Selector<Data, int>(selector: ..., builder: ...)',
          value: counter.toString()),
    );
  }
}

class Level3ShowingTrapToAvoid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // WATCH OUT:
    // using all of those methods below to retrieve MyDummyData in the same widget
    // is not the right way to go, because the Level3 widget will be rebuild,
    // rebuilding everything in it:
    // - using "Provider.of<MyDummyData>(context)" and "context.watch<MyDummyData>()"
    //   will trigger the rebuild of the Level3 widget because they are listening
    //   to "class MyDummyData with ChangeNotifier"
    // - which will remake the calls to "Provider.of<MyDummyData>(context, listen: false)
    //   and "context.read<MyDummyData>()", causing them to display the updated value
    //   instead of the initial value
    final valueProviderOf = Provider.of<MyDummyData>(context);
    print('valueProviderOf = ${valueProviderOf.data}');

    // Equivalent to 'Provider.of', but is accessible only inside [StatelessWidget.build] and [State.build].
    final valueContextWatch = context.watch<MyDummyData>();
    print('valueContextWatch = ${valueContextWatch.data}');

    final valueProviderOfWithoutListening =
        Provider.of<MyDummyData>(context, listen: false);
    print(
        'valueProviderOfWithoutListening = ${valueProviderOfWithoutListening.data}');

    final valueContextRead = context.read<MyDummyData>();
    print('valueContextRead = ${valueContextRead.data}');

    Map<String, String> map = {
      'Provider.of<String>(context)': valueProviderOf.data,
      'context.watch<String>()': valueContextWatch.data,
      'Provider.of<String>(context, listen: false)':
          valueProviderOfWithoutListening.data,
      'context.read<String>()': valueContextRead.data
    };

    return Center(
      child: MyProviderTestingDisplay(map),
    );
  }
}

class MyProviderTestingDisplay extends StatelessWidget {
  final Map<String, String> map;

  const MyProviderTestingDisplay(this.map);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: map.entries
          .map((e) => DisplayColumn(label: e.key, value: e.value))
          .toList(),
    );
  }
}

class DisplayColumn extends StatelessWidget {
  final String label;
  final String value;

  const DisplayColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: const TextStyle(fontSize: 17.0, color: Colors.blue),
        ),
        const SizedBox(
          height: 15.0,
        ),
        Text(
          value,
          style:
              const TextStyle(fontSize: 23.0, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(
          height: 55.0,
        ),
      ],
    );
  }
}
