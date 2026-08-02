/// Azkar Feature.
///
/// Phase 4: Morning, Evening, Sleep, and Post-Prayer azkar with
/// progressive per-zekr counters and haptic feedback.
/// This module contains:
/// - Domain: [ZekrEntity], [AzkarCategoryEntity], [AzkarRepository] contract
/// - Data: [AzkarRepositoryImpl] + [AzkarLocalDataSource] with authentic texts
/// - Presentation: [AzkarCubit], [AzkarCategoriesPage], [AzkarDetailsPage]
library;

export 'data/data.dart';
export 'domain/domain.dart';
export 'presentation/presentation.dart';