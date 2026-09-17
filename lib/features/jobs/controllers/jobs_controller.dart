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
    this.salaryMin = mockSalaryFloor,
    this.salaryMax = mockSalaryCeiling,
    this.employment,
    this.location = '',
    this.permitFriendlyOnly = false,
    this.newOnly = false,
  });

  final String field;

  /// The salary slider's two thumbs. At the floor and ceiling they filter
  /// nothing, and the ceiling reads as "and above".
  final int salaryMin;
  final int salaryMax;

  final Employment? employment;

  /// Free text from the location field, or a one-tap pick. Empty is anywhere.
  final String location;

  final bool permitFriendlyOnly;

  /// The New button in the jobs bar: postings from the last 48 hours only.
  final bool newOnly;

  bool get salaryIsAny =>
      salaryMin == mockSalaryFloor && salaryMax == mockSalaryCeiling;

  bool get isDefault => activeCount == 0;

  int get activeCount => [
        field != 'All',
        !salaryIsAny,
        employment != null,
        location.trim().isNotEmpty,
        permitFriendlyOnly,
        newOnly,
      ].where((on) => on).length;

  JobFilters copyWith({
    String? field,
    int? salaryMin,
    int? salaryMax,
    Employment? employment,
    bool clearEmployment = false,
    String? location,
    bool? permitFriendlyOnly,
    bool? newOnly,
  }) {
    return JobFilters(
      field: field ?? this.field,
      salaryMin: salaryMin ?? this.salaryMin,
      salaryMax: salaryMax ?? this.salaryMax,
      employment: clearEmployment ? null : (employment ?? this.employment),
      location: location ?? this.location,
      permitFriendlyOnly: permitFriendlyOnly ?? this.permitFriendlyOnly,
      newOnly: newOnly ?? this.newOnly,
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
final filteredJobsProvider = Provider<List<Job>>(
  (ref) => applyJobFilters(
    ref.watch(allJobsProvider),
    ref.watch(jobQueryProvider),
    ref.watch(jobFiltersProvider),
  ),
);

/// The matching rule on its own, so the filter sheet can count what its draft
/// would show before the filters are applied.
List<Job> applyJobFilters(
  List<Job> jobs,
  String rawQuery,
  JobFilters filters,
) {
  final query = rawQuery.trim().toLowerCase();
  final location = filters.location.trim().toLowerCase();

  return jobs.where((job) {
    if (query.isNotEmpty) {
      final haystack =
          '${job.title} ${job.company} ${job.category} ${job.location}'
              .toLowerCase();
      if (!haystack.contains(query)) return false;
    }
    if (filters.field != 'All' && job.category != filters.field) return false;
    if (filters.employment != null && !job.types.contains(filters.employment)) {
      return false;
    }
    if (location.isNotEmpty && !job.location.toLowerCase().contains(location)) {
      return false;
    }
    if (filters.permitFriendlyOnly && !job.permitFriendly) return false;
    if (filters.newOnly && !job.isNew) return false;
    if (!filters.salaryIsAny) {
      // A job matches when its advertised range overlaps the chosen one. The
      // ceiling is open-ended, so a max thumb there accepts anything above.
      final aboveMin = job.salaryHigh >= filters.salaryMin;
      final belowMax = filters.salaryMax == mockSalaryCeiling ||
          job.salaryLow <= filters.salaryMax;
      if (!aboveMin || !belowMax) return false;
    }
    return true;
  }).toList();
}

/// The Most searched bar: the top roles by search volume, highest first.
final topSearchedJobsProvider = Provider<List<Job>>((ref) {
  final jobs = [...ref.watch(allJobsProvider)]
    ..sort((a, b) => b.searchCount.compareTo(a.searchCount));
  return jobs.take(mockTopJobsCount).toList();
});

/// How many postings are young enough to carry the New badge.
final newJobsCountProvider = Provider<int>(
  (ref) => ref.watch(allJobsProvider).where((job) => job.isNew).length,
);

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
