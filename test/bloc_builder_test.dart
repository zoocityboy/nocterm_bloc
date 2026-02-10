// ignore_for_file: prefer_file_naming_conventions
import 'package:nocterm/nocterm.dart';
import 'package:test/test.dart';

import 'package:nocterm_bloc/nocterm_bloc.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit({int seed = 0}) : super(seed);

  void increment() => emit(state + 1);

  @override
  void onChange(Change<int> change) {
    print(
      'CounterCubit changed: ${change.currentState} -> ${change.nextState}',
    );
    super.onChange(change);
  }
}

void main() {
  test('BlocBuilder displays initial state', () async {
    await testNocterm('initial state', (tester) async {
      final counterCubit = CounterCubit();

      await tester.pumpComponent(
        BlocProvider.value(
          value: counterCubit,
          child: BlocBuilder<CounterCubit, int>(
            builder: (context, count) {
              return Text('Count: $count');
            },
          ),
        ),
      );

      expect(tester.terminalState, containsText('Count: 0'));
    });
  });

  test('BlocBuilder rebuilds when state changes', () async {
    await testNocterm('state changes', (tester) async {
      final counterCubit = CounterCubit();

      await tester.pumpComponent(
        BlocProvider.value(
          value: counterCubit,
          child: BlocBuilder<CounterCubit, int>(
            builder: (context, count) {
              return Text('Count: $count');
            },
          ),
        ),
      );
      expect(tester.terminalState, containsText('Count: 0'));

      counterCubit.increment();
      await tester.pump(Duration(milliseconds: 100));
      expect(tester.terminalState, containsText('Count: 1'));
    });
  });

  test('BlocBuilder respects buildWhen', () async {
    await testNocterm('buildWhen', (tester) async {
      final counterCubit = CounterCubit();

      await tester.pumpComponent(
        BlocProvider.value(
          value: counterCubit,
          child: BlocBuilder<CounterCubit, int>(
            buildWhen: (previous, current) => current > 0,
            builder: (context, count) => Text('Count: $count'),
          ),
        ),
      );

      expect(tester.terminalState, containsText('Count: 0'));

      counterCubit.increment(); // To 1
      await tester.pump(Duration(milliseconds: 100));
      expect(tester.terminalState, containsText('Count: 1'));
    });
  });

  test('BlocBuilder does not rebuild when buildWhen is false', () async {
    await testNocterm('buildWhen false', (tester) async {
      final counterCubit = CounterCubit();

      await tester.pumpComponent(
        BlocProvider.value(
          value: counterCubit,
          child: BlocBuilder<CounterCubit, int>(
            buildWhen: (previous, current) => false,
            builder: (context, count) => Text('Count: $count'),
          ),
        ),
      );

      expect(tester.terminalState, containsText('Count: 0'));

      counterCubit.increment();
      await tester.pump(Duration(milliseconds: 100));
      expect(tester.terminalState, containsText('Count: 0')); // No rebuild
    });
  });

  test('BlocBuilder handles bloc change', () async {
    await testNocterm('builder bloc change', (tester) async {
      final counterCubit1 = CounterCubit();
      final counterCubit2 = CounterCubit(seed: 10);

      await tester.pumpComponent(
        BlocProvider.value(
          value: counterCubit1,
          child: BlocBuilder<CounterCubit, int>(
            builder: (context, count) => Text('Count: $count'),
          ),
        ),
      );

      expect(tester.terminalState, containsText('Count: 0'));

      // Change to new bloc
      await tester.pumpComponent(
        BlocProvider.value(
          value: counterCubit2,
          child: BlocBuilder<CounterCubit, int>(
            builder: (context, count) => Text('Count: $count'),
          ),
        ),
      );

      expect(tester.terminalState, containsText('Count: 10'));
    });
  });
}
