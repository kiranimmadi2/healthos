import 'package:supabase_flutter/supabase_flutter.dart';

import '../client_initializer.dart';

typedef RealtimeCallback = void Function(Map<String, dynamic> payload);

class RealtimeService {
  SupabaseClient get _client => SupabaseClientInitializer.client;
  final List<RealtimeChannel> _channels = [];

  RealtimeChannel subscribeToTable({
    required String table,
    required RealtimeCallback onInsert,
    RealtimeCallback? onUpdate,
    RealtimeCallback? onDelete,
    String? filterColumn,
    String? filterValue,
  }) {
    var channel = _client.channel('public:$table');

    final filter = filterColumn != null && filterValue != null
        ? '$filterColumn=eq.$filterValue'
        : null;

    channel = channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: table,
          filter: filter != null ? PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: filterColumn!,
            value: filterValue!,
          ) : null,
          callback: (payload) => onInsert(payload.newRecord),
        );

    if (onUpdate != null) {
      channel = channel.onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: table,
        filter: filter != null ? PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: filterColumn!,
          value: filterValue!,
        ) : null,
        callback: (payload) => onUpdate(payload.newRecord),
      );
    }

    if (onDelete != null) {
      channel = channel.onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: table,
        filter: filter != null ? PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: filterColumn!,
          value: filterValue!,
        ) : null,
        callback: (payload) => onDelete(payload.oldRecord),
      );
    }

    channel.subscribe();
    _channels.add(channel);
    return channel;
  }

  void unsubscribe(RealtimeChannel channel) {
    _client.removeChannel(channel);
    _channels.remove(channel);
  }

  void unsubscribeAll() {
    for (final channel in _channels) {
      _client.removeChannel(channel);
    }
    _channels.clear();
  }
}
