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
  test('BlocSelector rebuilds when selected value changes', () async {
    await testNocterm('selector rebuilds', (tester) async {
      final counterCubit = CounterCubit();

      await tester.pumpComponent(
        BlocProvider.value(
          value: counterCubit,
          child: BlocSelector<CounterCubit, int, int>(
            selector: (state) => state % 2,
            builder: (context, selected) => Text('Selected: $selected'),
          ),
        ),
      );

      expect(tester.terminalState, containsText('Selected: 0'));

      counterCubit.increment(); // 0 -> 1, 1 % 2 = 1, changes
      await tester.pump(Duration(milliseconds: 100));
      expect(tester.terminalState, containsText('Selected: 1'));

      counterCubit.increment(); // 1 -> 2, 2 % 2 = 0, changes
      await tester.pump(Duration(milliseconds: 100));
      expect(tester.terminalState, containsText('Selected: 0'));
    });
  });

  test(
    'BlocSelector does not rebuild when selected value does not change',
    () async {
      await testNocterm('selector no rebuild', (tester) async {
        final counterCubit = CounterCubit();

        await tester.pumpComponent(
          BlocProvider.value(
            value: counterCubit,
            child: BlocSelector<CounterCubit, int, int>(
              selector: (state) => state > 0 ? 1 : 0,
              builder: (context, selected) => Text('Selected: $selected'),
            ),
          ),
        );

        expect(tester.terminalState, containsText('Selected: 0'));

        counterCubit.increment(); // 0 -> 1, changes to 1
        await tester.pump(Duration(milliseconds: 100));
        expect(tester.terminalState, containsText('Selected: 1'));

        counterCubit.increment(); // 1 -> 2, stays 1
        await tester.pump(Duration(milliseconds: 100));
        expect(tester.terminalState, containsText('Selected: 1')); // No change
      });
    },
  );

  test('BlocSelector handles bloc change', () async {
    await testNocterm('selector bloc change', (tester) async {
      final counterCubit1 = CounterCubit();
      final counterCubit2 = CounterCubit(seed: 5);
      int buildCount = 0;

      await tester.pumpComponent(
        BlocProvider.value(
          value: counterCubit1,
          child: BlocSelector<CounterCubit, int, int>(
            selector: (state) => state,
            builder: (context, selected) {
              buildCount++;
              return Text('Selected: $selected');
            },
          ),
        ),
      );

      expect(buildCount, 1);
      expect(tester.terminalState, containsText('Selected: 0'));

      // Change to new bloc
      await tester.pumpComponent(
        BlocProvider.value(
          value: counterCubit2,
          child: BlocSelector<CounterCubit, int, int>(
            selector: (state) => state,
            builder: (context, selected) {
              buildCount++;
              return Text('Selected: $selected');
            },
          ),
        ),
      );

      expect(buildCount, 2); // Rebuilds due to bloc change
      expect(tester.terminalState, containsText('Selected: 5'));
    });
  });
}
