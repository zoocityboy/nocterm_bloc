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
  test('BlocConsumer builds and listens on state change (positive)', () async {
    await testNocterm('consumer positive', (tester) async {
      final counterCubit = CounterCubit();
      bool listenerCalled = false;

      await tester.pumpComponent(
        BlocProvider.value(
          value: counterCubit,
          child: BlocConsumer<CounterCubit, int>(
            listener: (context, state) => listenerCalled = true,
            builder: (context, count) => Text('Count: $count'),
          ),
        ),
      );

      expect(tester.terminalState, containsText('Count: 0'));
      expect(listenerCalled, isFalse); // Initial doesn't trigger listener

      counterCubit.increment();
      await tester.pump(Duration(milliseconds: 100));
      expect(tester.terminalState, containsText('Count: 1'));
      expect(listenerCalled, isTrue);
    });
  });

  test('BlocConsumer respects buildWhen (rebuilds, positive)', () async {
    await testNocterm('buildWhen allows rebuild', (tester) async {
      final counterCubit = CounterCubit();

      await tester.pumpComponent(
        BlocProvider.value(
          value: counterCubit,
          child: BlocConsumer<CounterCubit, int>(
            buildWhen: (previous, current) => current > 0,
            listener: (context, state) {},
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

  test(
    'BlocConsumer does not rebuild when buildWhen is false (negative)',
    () async {
      await testNocterm('buildWhen blocks rebuild', (tester) async {
        final counterCubit = CounterCubit();

        await tester.pumpComponent(
          BlocProvider.value(
            value: counterCubit,
            child: BlocConsumer<CounterCubit, int>(
              buildWhen: (previous, current) => false,
              listener: (context, state) {},
              builder: (context, count) => Text('Count: $count'),
            ),
          ),
        );

        expect(tester.terminalState, containsText('Count: 0'));

        counterCubit.increment();
        await tester.pump(Duration(milliseconds: 100));
        expect(tester.terminalState, containsText('Count: 0')); // No rebuild
      });
    },
  );

  test('BlocConsumer respects listenWhen (calls listener, positive)', () async {
    await testNocterm('listenWhen allows call', (tester) async {
      final counterCubit = CounterCubit();
      bool listenerCalled = false;

      await tester.pumpComponent(
        BlocProvider.value(
          value: counterCubit,
          child: BlocConsumer<CounterCubit, int>(
            listenWhen: (previous, current) => current > 0,
            listener: (context, state) => listenerCalled = true,
            builder: (context, count) => Text('Count: $count'),
          ),
        ),
      );

      counterCubit.increment(); // To 1
      await tester.pump(Duration(milliseconds: 100));
      expect(listenerCalled, isTrue);
    });
  });

  test(
    'BlocConsumer does not call listener when listenWhen is false (negative)',
    () async {
      await testNocterm('listenWhen blocks call', (tester) async {
        final counterCubit = CounterCubit();
        bool listenerCalled = false;

        await tester.pumpComponent(
          BlocProvider.value(
            value: counterCubit,
            child: BlocConsumer<CounterCubit, int>(
              listenWhen: (previous, current) => false,
              listener: (context, state) => listenerCalled = true,
              builder: (context, count) => Text('Count: $count'),
            ),
          ),
        );

        counterCubit.increment();
        await tester.pump(Duration(milliseconds: 100));
        expect(listenerCalled, isFalse);
      });
    },
  );
}
