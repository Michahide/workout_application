import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../data/gym_location_repository.dart';

final gymLocationsListProvider = StreamProvider.autoDispose<List<GymLocation>>((
  ref,
) {
  final repo = ref.watch(gymLocationRepositoryProvider);
  return repo.watchGymLocations();
});

final gymLocationDetailProvider = StreamProvider.autoDispose
    .family<GymLocation?, String>((ref, gymId) {
      final repo = ref.watch(gymLocationRepositoryProvider);
      return repo.watchGymLocationById(gymId);
    });

final gymMachinesByGymProvider = StreamProvider.autoDispose
    .family<List<GymMachineWithDetails>, String>((ref, gymId) {
      final repo = ref.watch(gymLocationRepositoryProvider);
      return repo.watchMachinesForGym(gymId);
    });

final gymMachinesByExerciseProvider = StreamProvider.autoDispose
    .family<List<GymMachineWithDetails>, String>((ref, exerciseId) {
      final repo = ref.watch(gymLocationRepositoryProvider);
      return repo.watchMachinesForExercise(exerciseId);
    });
