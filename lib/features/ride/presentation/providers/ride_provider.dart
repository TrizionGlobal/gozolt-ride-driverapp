import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../../data/datasources/ride_remote_datasource.dart';
import '../../data/repositories/ride_repository_impl.dart';
import '../../domain/repositories/ride_repository.dart';

final rideRepositoryProvider = Provider<RideRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return RideRepositoryImpl(
    remoteDataSource: RideRemoteDataSource(dio),
  );
});
