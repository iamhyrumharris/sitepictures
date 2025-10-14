/// Result object encapsulating save operation outcome
class SaveResult {
  final bool success;
  final int successfulCount;
  final int failedCount;
  final List<String> savedIds;
  final String? error;
  final bool sessionPreserved;

  SaveResult({
    required this.success,
    required this.successfulCount,
    required this.failedCount,
    required this.savedIds,
    this.error,
    required this.sessionPreserved,
  });

  /// Factory constructor for complete success (all photos saved)
  factory SaveResult.complete(List<String> savedIds) {
    return SaveResult(
      success: true,
      successfulCount: savedIds.length,
      failedCount: 0,
      savedIds: savedIds,
      sessionPreserved: false,
    );
  }

  /// Factory constructor for partial success (some photos saved, some failed)
  factory SaveResult.partial({
    required int successful,
    required int failed,
    required List<String> savedIds,
  }) {
    return SaveResult(
      success: false,
      successfulCount: successful,
      failedCount: failed,
      savedIds: savedIds,
      sessionPreserved: false,
    );
  }

  /// Factory constructor for critical failure (save rolled back, session preserved)
  factory SaveResult.criticalFailure({
    required String error,
    bool sessionPreserved = true,
  }) {
    return SaveResult(
      success: false,
      successfulCount: 0,
      failedCount: 0,
      savedIds: [],
      error: error,
      sessionPreserved: sessionPreserved,
    );
  }

  /// Generate user-facing message based on result
  String getUserMessage() {
    if (success) {
      return '$successfulCount photo${successfulCount > 1 ? 's' : ''} saved';
    } else if (failedCount > 0 && successfulCount > 0) {
      return '$successfulCount of ${successfulCount + failedCount} photos saved';
    } else {
      return 'Save failed: ${error ?? 'Unknown error'}';
    }
  }

  @override
  String toString() {
    return 'SaveResult(success: $success, successfulCount: $successfulCount, failedCount: $failedCount, savedIds: ${savedIds.length}, error: $error, sessionPreserved: $sessionPreserved)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaveResult &&
        other.success == success &&
        other.successfulCount == successfulCount &&
        other.failedCount == failedCount &&
        _listEquals(other.savedIds, savedIds) &&
        other.error == error &&
        other.sessionPreserved == sessionPreserved;
  }

  @override
  int get hashCode {
    return Object.hash(
      success,
      successfulCount,
      failedCount,
      Object.hashAll(savedIds),
      error,
      sessionPreserved,
    );
  }

  // Helper for list equality
  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
