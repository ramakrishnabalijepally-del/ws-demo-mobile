import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_applications.dart';
import '../data/mock_jobs.dart';
import '../models/job.dart';

/// Everything the jobs feature reads goes through here, even though every
/// answer comes from a fixture. **Swapping in the real API is then a one-file
/// change rather than a rewrite** (`.agents/rules/02-structure.md`).

/// The current search text.
final jobQueryProvider = StateProvider<String>((ref) => '');

/// The active filters.
class JobFilters {
  const JobFilters({
    this.field = 'All',
    this.salaryBand = 'Any',
    this.employment,
    this.location = 'Anywhere',
    this.permitFriendlyOnly = false,
  });

  final String field;
  final String salaryBand;
  final Employment? employment;
  final String location;
  final bool permitFriendlyOnly;

  bool get isDefault =>
      field == 'All' &&
      salaryBand == 'Any' &&
      employment == null &&
      location == 'Anywhere' &&
      !permitFriendlyOnly;

  int get activeCount => [
        field != 'All',
        salaryBand != 'Any',
        employment != null,
        location != 'Anywhere',
        permitFriendlyOnly,
      ].where((on) => on).length;

  JobFilters copyWith({
    String? field,
    String? salaryBand,
    Employment? employment,
    bool clearEmployment = false,
    String? location,
    bool? permitFriendlyOnly,
  }) {
    return JobFilters(
      field: field ?? this.field,
      salaryBand: salaryBand ?? this.salaryBand,
      employment: clearEmployment ? null : (employment ?? this.employment),
      location: location ?? this.location,
      permitFriendlyOnly: permitFriendlyOnly ?? this.permitFriendlyOnly,
    );
  }
}

final jobFiltersProvider =
    NotifierProvider<JobFiltersNotifier, JobFilters>(JobFiltersNotifier.new);

class JobFiltersNotifier extends Notifier<JobFilters> {
  @override
  JobFilters build() => const JobFilters();

  void set(JobFilters next) => state = next;
  void clear() => state = const JobFilters();
}

/// Saved job ids. Bookmarking is in memory only.
final savedJobIdsProvider =
    NotifierProvider<SavedJobsNotifier, Set<String>>(SavedJobsNotifier.new);

class SavedJobsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {'j1', 'j3', 'j6', 'j7', 'j14', 'j16', 'j20'};

  void toggle(String id) {
    final next = {...state};
    next.contains(id) ? next.remove(id) : next.add(id);
    state = next;
  }

  bool contains(String id) => state.contains(id);
}

/// The full board, with the saved flag applied.
final allJobsProvider = Provider<List<Job>>((ref) {
  final saved = ref.watch(savedJobIdsProvider);
  return [
    for (final job in mockJobs) job.copyWith(saved: saved.contains(job.id)),
  ];
});

/// Search plus filters.
final filteredJobsProvider = Provider<List<Job>>((ref) {
  final jobs = ref.watch(allJobsProvider);
  final query = ref.watch(jobQueryProvider).trim().toLowerCase();
  final filters = ref.watch(jobFiltersProvider);

  bool matchesSalary(Job job) => switch (filters.salaryBand) {
        'Under \$60k' => job.salaryLow < 60000,
        '\$60k–\$90k' => job.salaryLow >= 60000 && job.salaryLow < 90000,
        '\$90k–\$120k' => job.salaryLow >= 90000 && job.salaryLow < 120000,
        'Over \$120k' => job.salaryLow >= 120000,
        _ => true,
      };

  return jobs.where((job) {
    if (query.isNotEmpty) {
      final haystack =
          '${job.title} ${job.company} ${job.category} ${job.location}'
              .toLowerCase();
      if (!haystack.contains(query)) return false;
    }
    if (filters.field != 'All' && job.category != filters.field) return false;
    if (filters.employment != null && job.employment != filters.employment) {
      return false;
    }
    if (filters.location != 'Anywhere' &&
        !job.location.contains(filters.location)) {
      return false;
    }
    if (filters.permitFriendlyOnly && !job.permitFriendly) return false;
    return matchesSalary(job);
  }).toList();
});

final savedJobsProvider = Provider<List<Job>>((ref) {
  final saved = ref.watch(savedJobIdsProvider);
  return ref
      .watch(allJobsProvider)
      .where((job) => saved.contains(job.id))
      .toList();
});

Job? jobById(WidgetRef ref, String id) =>
    ref.read(allJobsProvider).where((j) => j.id == id).firstOrNull;

/// Applications. Also in memory: applying from the mock flow appends here.
final applicationsProvider =
    NotifierProvider<ApplicationsNotifier, List<JobApplication>>(
  ApplicationsNotifier.new,
);

class ApplicationsNotifier extends Notifier<List<JobApplication>> {
  @override
  List<JobApplication> build() => mockApplications;

  void add(JobApplication application) => state = [application, ...state];
}

/// How many times the mock upload and the mock submit have been tried.
///
/// These live outside the screen so a retry is a real retry: the second attempt
/// succeeds, rather than the counter resetting with the widget and looping the
/// reader through the same failure forever. Both failure states in the deck
/// (F3 upload failed, F6 application failed) are reachable exactly once each,
/// which is what makes them reviewable without a debug menu.
final uploadAttemptsProvider = StateProvider<int>((ref) => 0);
final submitAttemptsProvider = StateProvider<int>((ref) => 0);
