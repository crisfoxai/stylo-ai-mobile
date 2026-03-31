import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylo_ai/core/utils/app_lifecycle_observer.dart';
import 'package:stylo_ai/shared/providers/weather_provider.dart';

void main() {
  group('AppLifecycleObserver', () {
    testWidgets('invalidates weatherProvider on resume', (tester) async {
      var invalidated = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weatherProvider.overrideWith((ref) {
              ref.onDispose(() => invalidated = true);
              throw UnimplementedError('not needed');
            }),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              // Force-read to initialize the provider
              ref.watch(weatherProvider);

              return _LifecycleTestWidget(ref: ref);
            },
          ),
        ),
      );

      await tester.pump();

      // Trigger resume
      final state = tester.state<_LifecycleTestWidgetState>(
        find.byType(_LifecycleTestWidget),
      );
      state.observer.didChangeAppLifecycleState(AppLifecycleState.resumed);

      // After resume, weatherProvider should be invalidated (disposed + recreated)
      expect(invalidated, isTrue);
    });

    testWidgets('does nothing on paused', (tester) async {
      var invalidated = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weatherProvider.overrideWith((ref) {
              ref.onDispose(() => invalidated = true);
              throw UnimplementedError('not needed');
            }),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              ref.watch(weatherProvider);
              return _LifecycleTestWidget(ref: ref);
            },
          ),
        ),
      );

      await tester.pump();

      final state = tester.state<_LifecycleTestWidgetState>(
        find.byType(_LifecycleTestWidget),
      );
      state.observer.didChangeAppLifecycleState(AppLifecycleState.paused);

      expect(invalidated, isFalse);
    });

    testWidgets('does nothing on inactive', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, _) {
              return _LifecycleTestWidget(ref: ref);
            },
          ),
        ),
      );

      await tester.pump();

      final state = tester.state<_LifecycleTestWidgetState>(
        find.byType(_LifecycleTestWidget),
      );
      // Should not throw
      state.observer.didChangeAppLifecycleState(AppLifecycleState.inactive);
      state.observer.didChangeAppLifecycleState(AppLifecycleState.detached);
      state.observer.didChangeAppLifecycleState(AppLifecycleState.hidden);
    });
  });
}

class _LifecycleTestWidget extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const _LifecycleTestWidget({required this.ref});

  @override
  ConsumerState<_LifecycleTestWidget> createState() =>
      _LifecycleTestWidgetState();
}

class _LifecycleTestWidgetState extends ConsumerState<_LifecycleTestWidget> {
  late final AppLifecycleObserver observer;

  @override
  void initState() {
    super.initState();
    observer = AppLifecycleObserver(widget.ref);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
