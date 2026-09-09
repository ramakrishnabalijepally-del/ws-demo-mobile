import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';
import '../../../data/mock_profile.dart';

/// N5 — help.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.xxxl,
        ),
        children: [
          WsCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                WsListRow(
                  leading: const WsIconTile(icon: Icons.quiz_outlined),
                  title: 'Frequently asked questions',
                  onTap: () => context.push(Routes.faq),
                ),
                Divider(color: context.colors.outlineVariant, height: 1),
                WsListRow(
                  leading: const WsIconTile(icon: Icons.gavel_outlined),
                  title: 'Terms and Conditions',
                  onTap: () => context.push(Routes.terms),
                ),
                Divider(color: context.colors.outlineVariant, height: 1),
                WsListRow(
                  leading: const WsIconTile(icon: Icons.shield_outlined),
                  title: 'Privacy Policy',
                  onTap: () => context.push(Routes.privacy),
                ),
              ],
            ),
          ),
          const SizedBox(height: WsSpacing.xxl),
          Text('Still stuck?', style: context.text.titleLarge),
          const SizedBox(height: WsSpacing.sm),
          Text(
            'The assistant answers most questions about your own situation. '
            'For anything about your account, email support@worksettle.ca.',
            style: context.text.bodyMedium
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: WsSpacing.lg),
          WsSecondaryButton(
            label: 'Ask the assistant',
            icon: Icons.forum_outlined,
            onPressed: () => context.push(Routes.assistant),
          ),
        ],
      ),
    );
  }
}

/// N6 — FAQ, with category chips and an accordion.
class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  String _category = mockFaqCategories.first;

  @override
  Widget build(BuildContext context) {
    final entries = mockFaq.where((e) => e.category == _category).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: WsSpacing.gutter,
              itemCount: mockFaqCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: WsSpacing.sm),
              itemBuilder: (context, i) => ChoiceChip(
                label: Text(mockFaqCategories[i]),
                selected: _category == mockFaqCategories[i],
                onSelected: (_) =>
                    setState(() => _category = mockFaqCategories[i]),
                labelStyle: WsTypography.chip(
                  _category == mockFaqCategories[i]
                      ? context.colors.onPrimary
                      : context.colors.onSurface,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                WsSpacing.xl,
                WsSpacing.lg,
                WsSpacing.xl,
                WsSpacing.xxxl,
              ),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: WsSpacing.md),
              itemBuilder: (context, i) => WsCard(
                padding: EdgeInsets.zero,
                child: Theme(
                  // The expansion tile's own divider would double the card's
                  // hairline.
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: WsSpacing.lg,
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(
                      WsSpacing.lg,
                      0,
                      WsSpacing.lg,
                      WsSpacing.lg,
                    ),
                    iconColor: context.colors.primary,
                    collapsedIconColor: context.ws.placeholder,
                    title: Text(
                      entries[i].question,
                      style: context.text.titleMedium,
                    ),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          entries[i].answer,
                          style: context.text.bodyMedium?.copyWith(
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// N7–N8 — the legal pages.
class LegalScreen extends StatelessWidget {
  const LegalScreen.terms({super.key})
      : title = 'Terms and Conditions',
        paragraphs = mockTerms;

  const LegalScreen.privacy({super.key})
      : title = 'Privacy Policy',
        paragraphs = mockPrivacy;

  final String title;
  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.huge,
        ),
        children: [
          Text(
            'Last updated 8 September 2026',
            style: context.text.bodySmall?.copyWith(color: context.ws.caption),
          ),
          const SizedBox(height: WsSpacing.xl),
          for (final paragraph in paragraphs) ...[
            Text(
              paragraph,
              style: context.text.bodyMedium
                  ?.copyWith(color: context.colors.onSurfaceVariant),
            ),
            const SizedBox(height: WsSpacing.lg),
          ],
        ],
      ),
    );
  }
}
