import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/theme.dart';
import '../../../../shared/data/mock_candidate.dart';
import '../../../../shared/shared.dart';
import '../../controllers/registration_controller.dart';
import '../screens/registration_screen.dart';

/// C7 — Almost There.
///
/// **Every field entered is echoed back with an inline Edit link**, so the user
/// never has to walk the whole flow again to change one answer (design system
/// Pattern A). Edit jumps to that step; Continue brings you straight back here.
class StepReview extends ConsumerWidget {
  const StepReview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(registrationProvider).draft;
    final controller = ref.read(registrationProvider.notifier);

    String orDash(String value) => value.isEmpty ? '—' : value;

    return RegistrationStepScaffold(
      headline: 'Almost there',
      supporting: 'Check this over before we build your profile. Nothing is '
          'saved until you confirm.',
      primaryLabel: 'Create My Profile',
      onPrimary: () {
        // Commit the draft over the mock candidate so every later screen shows
        // what was actually entered.
        final current = ref.read(candidateProvider);
        ref.read(candidateProvider.notifier).update(
              current.copyWith(
                firstName: draft.firstName.isEmpty
                    ? current.firstName
                    : draft.firstName,
                lastName:
                    draft.lastName.isEmpty ? current.lastName : draft.lastName,
                email: draft.email.isEmpty ? current.email : draft.email,
                phone: draft.phone.isEmpty ? current.phone : draft.phone,
                dateOfBirth: draft.dateOfBirth.isEmpty
                    ? current.dateOfBirth
                    : draft.dateOfBirth,
                city: draft.city.isEmpty ? current.city : draft.city,
                province:
                    draft.province.isEmpty ? current.province : draft.province,
                countryOfOrigin: draft.countryOfOrigin.isEmpty
                    ? current.countryOfOrigin
                    : draft.countryOfOrigin,
                profileType: draft.profileType.isEmpty
                    ? current.profileType
                    : draft.profileType,
                goals: draft.goals.isEmpty ? current.goals : draft.goals,
                jobCategories: draft.jobCategories.isEmpty
                    ? current.jobCategories
                    : draft.jobCategories,
              ),
            );
        context.go(Routes.accountCreated);
      },
      children: [
        _ReviewSection(
          title: 'Basic Information',
          onEdit: () => controller.goTo(RegistrationStep.basicInfo),
          rows: [
            ('Name', orDash('${draft.firstName} ${draft.lastName}'.trim())),
            ('Date of Birth', orDash(draft.dateOfBirth)),
            ('Country of Origin', orDash(draft.countryOfOrigin)),
          ],
        ),
        _ReviewSection(
          title: 'Contact',
          onEdit: () => controller.goTo(RegistrationStep.contact),
          rows: [
            ('Email', orDash(draft.email)),
            ('Phone', orDash(draft.phone)),
            (
              'Location',
              orDash(
                [draft.city, draft.province]
                    .where((s) => s.isNotEmpty)
                    .join(', '),
              ),
            ),
          ],
        ),
        _ReviewSection(
          title: 'Profile Type',
          onEdit: () => controller.goTo(RegistrationStep.profileType),
          rows: [('You are a', orDash(draft.profileType))],
        ),
        _ReviewSection(
          title: 'Goals',
          onEdit: () => controller.goTo(RegistrationStep.goals),
          rows: [
            ('Selected', orDash(draft.goals.join('\n'))),
          ],
        ),
        _ReviewSection(
          title: 'Job Interests',
          onEdit: () => controller.goTo(RegistrationStep.jobCategories),
          rows: [('Categories', orDash(draft.jobCategories.join(', ')))],
        ),
      ],
    );
  }
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({
    required this.title,
    required this.rows,
    required this.onEdit,
  });

  final String title;
  final List<(String, String)> rows;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: WsSpacing.md),
      child: WsCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: context.text.titleMedium)),
                WsLink(label: 'Edit', onPressed: onEdit),
              ],
            ),
            const SizedBox(height: WsSpacing.sm),
            for (final (label, value) in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: WsSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        label,
                        style: context.text.bodySmall
                            ?.copyWith(color: context.ws.caption),
                      ),
                    ),
                    Expanded(
                      child: Text(value, style: context.text.bodyMedium),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
