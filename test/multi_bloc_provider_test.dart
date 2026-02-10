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
  test('MultiBlocProvider provides multiple blocs', () async {
    await testNocterm('multi provider', (tester) async {
      final counterCubit1 = CounterCubit();
      final counterCubit2 = CounterCubit(seed: 20);

      await tester.pumpComponent(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: counterCubit1),
            BlocProvider.value(value: counterCubit2),
          ],
          child: Column(
            children: [
              BlocBuilder<CounterCubit, int>(
                bloc: counterCubit1,
                builder: (context, count) => Text('Count1: $count'),
              ),
              BlocBuilder<CounterCubit, int>(
                bloc: counterCubit2,
                builder: (context, count) => Text('Count2: $count'),
              ),
            ],
          ),
        ),
      );

      expect(tester.terminalState, containsText('Count1: 0'));
      expect(tester.terminalState, containsText('Count2: 20'));
    });
  });
}
