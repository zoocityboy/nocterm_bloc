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
}
