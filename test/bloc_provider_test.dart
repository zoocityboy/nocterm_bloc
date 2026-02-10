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
  test('BlocProvider provides bloc to descendants', () async {
    await testNocterm('provider provides bloc', (tester) async {
      final counterCubit = CounterCubit();

      await tester.pumpComponent(
        BlocProvider.value(
          value: counterCubit,
          child: BlocBuilder<CounterCubit, int>(
            builder: (context, count) => Text('Count: $count'),
          ),
        ),
      );

      expect(tester.terminalState, containsText('Count: 0'));
    });
  });

  test('BlocProvider.value uses provided bloc', () async {
    await testNocterm('provider value', (tester) async {
      final counterCubit = CounterCubit(seed: 10);

      await tester.pumpComponent(
        BlocProvider.value(
          value: counterCubit,
          child: BlocBuilder<CounterCubit, int>(
            builder: (context, count) => Text('Count: $count'),
          ),
        ),
      );

      expect(tester.terminalState, containsText('Count: 10'));

      counterCubit.increment();
      await tester.pump(Duration(milliseconds: 100));
      expect(tester.terminalState, containsText('Count: 11'));
    });
  });

  test('BlocProvider allows nested providers', () async {
    await testNocterm('nested providers', (tester) async {
      final outerCubit = CounterCubit(seed: 1);
      final innerCubit = CounterCubit(seed: 100);

      await tester.pumpComponent(
        BlocProvider.value(
          value: outerCubit,
          child: BlocProvider.value(
            value: innerCubit,
            child: BlocBuilder<CounterCubit, int>(
              builder: (context, count) => Text('Inner: $count'),
            ),
          ),
        ),
      );

      // Should use the closest (inner) provider
      expect(tester.terminalState, containsText('Inner: 100'));
    });
  });
  test('BlocProvider with create function', () async {
    await testNocterm('provider create', (tester) async {
      await tester.pumpComponent(
        BlocProvider<CounterCubit>(
          create: (context) => CounterCubit(seed: 5),
          child: BlocBuilder<CounterCubit, int>(
            builder: (context, count) => Text('Count: $count'),
          ),
        ),
      );

      expect(tester.terminalState, containsText('Count: 5'));
    });
  });
}
