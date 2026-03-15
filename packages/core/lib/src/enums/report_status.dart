enum ReportStatus {
  pending,
  processing,
  ready,
  error;

  String get displayName {
    switch (this) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.processing:
        return 'Processing';
      case ReportStatus.ready:
        return 'Ready';
      case ReportStatus.error:
        return 'Error';
    }
  }

  bool get isTerminal => this == ReportStatus.ready || this == ReportStatus.error;
}
