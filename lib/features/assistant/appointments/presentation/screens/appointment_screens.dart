import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';
import '../../../data/mock_appointments.dart';

/// Booking a licensed consultant.
///
/// These screens moved out of Settlement and in with the AI agent: the agent
/// is what works out that a question needs a human, so the booking belongs at
/// the end of its flow rather than in a list of settlement tasks.

/// The consultation list.
class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.xxxl,
        ),
        children: [
          WsBanner(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Talk to a licensed consultant',
                  style: context.text.titleMedium,
                ),
                const SizedBox(height: WsSpacing.xs),
                Text(
                  'Every consultant here is a Regulated Canadian Immigration '
                  'Consultant in good standing. WorkSettle does not give legal '
                  'advice; they do.',
                  style: context.text.bodySmall
                      ?.copyWith(color: context.colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: WsSpacing.xl),
          for (final (i, consultation) in mockConsultations.indexed)
            WsAppear(
              delay: i * 0.08,
              duration: WsMotion.entranceSequence,
              child: Padding(
                padding: const EdgeInsets.only(bottom: WsSpacing.md),
                child: WsCard(
                  onTap: () => context.push(
                    Routes.withId(Routes.appointmentDetail, consultation.id),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(consultation.title, style: context.text.titleMedium),
                      const SizedBox(height: WsSpacing.xs),
                      Text(
                        consultation.summary,
                        style: context.text.bodySmall
                            ?.copyWith(color: context.ws.caption),
                      ),
                      const SizedBox(height: WsSpacing.md),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 14,
                            color: context.ws.placeholder,
                          ),
                          const SizedBox(width: WsSpacing.xs + 2),
                          Text(
                            '${consultation.minutes} min',
                            style: context.text.bodySmall
                                ?.copyWith(color: context.ws.caption),
                          ),
                          const Spacer(),
                          Text(
                            consultation.price == 0
                                ? 'Free'
                                : '\$${consultation.price}',
                            style: context.text.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One consultation, and booking it.
class AppointmentDetailScreen extends StatelessWidget {
  const AppointmentDetailScreen({required this.consultationId, super.key});

  final String consultationId;

  @override
  Widget build(BuildContext context) {
    final consultation =
        mockConsultations.where((c) => c.id == consultationId).firstOrNull;

    if (consultation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Appointments')),
        body: WsEmptyState(
          icon: Icons.event_busy_outlined,
          headline: 'That consultation is not available',
          body: 'The list of what we currently offer is one screen back.',
          actionLabel: 'Back to appointments',
          onAction: () => context.pop(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Book a consultation')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.huge,
        ),
        children: [
          Text(consultation.title, style: context.text.headlineLarge),
          const SizedBox(height: WsSpacing.md),
          Text(
            consultation.summary,
            style: context.text.bodyMedium
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: WsSpacing.xl),
          WsCard(
            child: Row(
              children: [
                const WsIconTile(icon: Icons.verified_user_rounded),
                const SizedBox(width: WsSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        consultation.consultant,
                        style: context.text.titleMedium,
                      ),
                      Text(
                        consultation.credential,
                        style: context.text.bodySmall
                            ?.copyWith(color: context.ws.caption),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: WsSpacing.md),
          WsCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Length',
                        style: context.text.bodyMedium
                            ?.copyWith(color: context.ws.caption),
                      ),
                    ),
                    Text(
                      '${consultation.minutes} minutes',
                      style: context.text.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                Divider(
                  color: context.colors.outlineVariant,
                  height: WsSpacing.xxl,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Price',
                        style: context.text.bodyMedium
                            ?.copyWith(color: context.ws.caption),
                      ),
                    ),
                    Text(
                      consultation.price == 0
                          ? 'Free'
                          : '\$${consultation.price} CAD',
                      style: context.text.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            WsSpacing.xl,
            WsSpacing.md,
            WsSpacing.xl,
            WsSpacing.lg,
          ),
          child: WsPrimaryButton(
            label: 'Book this',
            // TODO(backend): no calendar, no payment. This goes straight to the
            // confirmation so the flow is walkable.
            onPressed: () => context.push(Routes.appointmentBooked),
          ),
        ),
      ),
    );
  }
}

/// Booking confirmed.
class AppointmentBookedScreen extends StatelessWidget {
  const AppointmentBookedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WsSuccessScreen(
      // A booking is a transaction settled, so it takes the filled ink disc.
      milestone: WsMilestone.settled,
      headline: 'Your consultation is booked',
      body: 'You will get a calendar invitation and a reminder the day before. '
          'Bring your questions written down — the time goes quickly.',
      primaryLabel: 'Back to the agent',
      onPrimary: () => context.go(Routes.assistant),
    );
  }
}
