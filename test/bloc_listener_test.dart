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
  test('BlocListener calls listener when state changes', () async {
    await testNocterm('listener called on state change', (tester) async {
      final counterCubit = CounterCubit();
      bool listenerCalled = false;

      await tester.pumpComponent(
        BlocProvider.value(
          value: counterCubit,
          child: BlocListener<CounterCubit, int>(
            listener: (context, state) => listenerCalled = true,
            child: const Text('Child'),
          ),
        ),
      );

      expect(listenerCalled, isFalse); // Initial state doesn't trigger

      counterCubit.increment();
      await tester.pump(Duration(milliseconds: 100));
      expect(listenerCalled, isTrue);
    });
  });

  test('BlocListener respects listenWhen (calls listener)', () async {
    await testNocterm('listenWhen allows call', (tester) async {
      final counterCubit = CounterCubit();
      bool listenerCalled = false;

      await tester.pumpComponent(
        BlocProvider.value(
          value: counterCubit,
          child: BlocListener<CounterCubit, int>(
            listenWhen: (previous, current) => current > 0,
            listener: (context, state) => listenerCalled = true,
            child: const Text('Child'),
          ),
        ),
      );

      counterCubit.increment(); // State changes to 1
      await tester.pump(Duration(milliseconds: 100));
      expect(listenerCalled, isTrue);
    });
  });

  test(
    'BlocListener does not call listener when listenWhen is false',
    () async {
      await testNocterm('listenWhen blocks call', (tester) async {
        final counterCubit = CounterCubit();
        bool listenerCalled = false;

        await tester.pumpComponent(
          BlocProvider.value(
            value: counterCubit,
            child: BlocListener<CounterCubit, int>(
              listenWhen: (previous, current) => false,
              listener: (context, state) => listenerCalled = true,
              child: const Text('Child'),
            ),
          ),
        );

        counterCubit.increment();
        await tester.pump(Duration(milliseconds: 100));
        expect(listenerCalled, isFalse);
      });
    },
  );

  test('BlocListener handles bloc change', () async {
    await testNocterm('bloc change resubscribes', (tester) async {
      final counterCubit1 = CounterCubit();
      final counterCubit2 = CounterCubit(seed: 10);
      bool listenerCalled = false;

      await tester.pumpComponent(
        BlocProvider.value(
          value: counterCubit1,
          child: BlocListener<CounterCubit, int>(
            listener: (context, state) => listenerCalled = true,
            child: const Text('Child'),
          ),
        ),
      );

      // Change to new bloc
      await tester.pumpComponent(
        BlocProvider.value(
          value: counterCubit2,
          child: BlocListener<CounterCubit, int>(
            listener: (context, state) => listenerCalled = true,
            child: const Text('Child'),
          ),
        ),
      );

      counterCubit2.increment(); // New bloc state changes
      await tester.pump(Duration(milliseconds: 100));
      expect(listenerCalled, isTrue);
    });
  });
}
