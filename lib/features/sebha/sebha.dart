/// Electronic Sebha Feature.
///
/// Phase 3: Interactive counter with haptic feedback and state persistence.
/// This module contains:
/// - Domain: [SebhaEntity], [SebhaRepository] contract
/// - Data: [SebhaRepositoryImpl] using KeyValueStorage
/// - Presentation: [SebhaCubit], [SebhaPage] with animated counter circle
library;

export 'data/data.dart';
export 'domain/domain.dart';
export 'presentation/presentation.dart';