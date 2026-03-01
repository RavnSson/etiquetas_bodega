class PrintState {
  final bool isPrinting;
  final String? lastOk;
  final String? error;

  const PrintState({
    required this.isPrinting,
    required this.lastOk,
    required this.error,
  });

  factory PrintState.initial() => const PrintState(
        isPrinting: false,
        lastOk: null,
        error: null,
      );

  PrintState copyWith({
    bool? isPrinting,
    String? lastOk,
    String? error,
  }) {
    return PrintState(
      isPrinting: isPrinting ?? this.isPrinting,
      lastOk: lastOk,
      error: error,
    );
  }
}