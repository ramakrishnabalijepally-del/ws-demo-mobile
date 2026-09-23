import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worksettle_mobile/app/router/app_router.dart';
import 'package:worksettle_mobile/app/router/routes.dart';
import 'package:worksettle_mobile/app/theme/theme.dart';
import 'package:worksettle_mobile/features/assistant/assistant.dart';
import 'package:worksettle_mobile/shared/shared.dart';

/// The AI Agent tab opens straight into the conversation.
void main() {
  testWidgets(
      'the AI Agent tab is the chat, with the globe and the frequently asked '
      'questions', (tester) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, _) => MaterialApp.router(
            theme: WorkSettleTheme.light,
            routerConfig: ref.watch(routerProvider),
            // The globe turns forever unless motion is reduced.
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
          ),
        ),
      ),
    );
    container.read(routerProvider).go(Routes.assistant);
    await tester.pumpAndSettle();

    expect(find.byType(AssistantScreen), findsOneWidget);
    expect(find.byType(WsGlobe), findsOneWidget);
    expect(find.text('Frequently asked questions'), findsOneWidget);
    // A tab root carries the profile avatar, not a Back arrow.
    expect(find.byType(WsProfileButton), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);

    // Every question listed has a scripted answer behind it.
    expect(
      find.text('What is my CRS score and is it competitive?'),
      findsOneWidget,
    );
    expect(find.text('What does a Canadian resume look like?'), findsNothing);
  });
}
