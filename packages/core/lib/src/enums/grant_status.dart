enum GrantStatus {
  active,
  revoked,
  expired;

  String get displayName {
    switch (this) {
      case GrantStatus.active:
        return 'Active';
      case GrantStatus.revoked:
        return 'Revoked';
      case GrantStatus.expired:
        return 'Expired';
    }
  }

  bool get isAccessible => this == GrantStatus.active;
}
