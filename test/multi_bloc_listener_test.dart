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
  test('MultiBlocListener calls multiple listeners on state changes', () async {
    await testNocterm('multi listener', (tester) async {
      final counterCubit1 = CounterCubit();
      final counterCubit2 = CounterCubit(seed: 10);
      bool listener1Called = false;
      bool listener2Called = false;

      await tester.pumpComponent(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: counterCubit1),
            BlocProvider.value(value: counterCubit2),
          ],
          child: MultiBlocListener(
            listeners: [
              BlocListener<CounterCubit, int>(
                bloc: counterCubit1,
                listener: (context, state) => listener1Called = true,
              ),
              BlocListener<CounterCubit, int>(
                bloc: counterCubit2,
                listener: (context, state) => listener2Called = true,
              ),
            ],
            child: const Text('Child'),
          ),
        ),
      );

      expect(listener1Called, isFalse);
      expect(listener2Called, isFalse);

      counterCubit1.increment();
      await tester.pump(Duration(milliseconds: 100));
      expect(listener1Called, isTrue);
      expect(listener2Called, isFalse);

      counterCubit2.increment();
      await tester.pump(Duration(milliseconds: 100));
      expect(listener1Called, isTrue);
      expect(listener2Called, isTrue);
    });
  });
}
