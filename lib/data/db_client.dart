import 'package:postgres/postgres.dart';
import 'package:smartlib_staff_app/core/config/db_config.dart';

class DbClient {
  DbClient._internal();

  static final DbClient instance = DbClient._internal();

  PostgreSQLConnection? _connection;
  bool _isOpening = false;

  Future<PostgreSQLConnection> _getConnection() async {
    if (_connection != null && _connection!.isClosed == false) {
      return _connection!;
    }
    if (_isOpening) {
      while (_isOpening) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return _connection!;
    }

    _isOpening = true;

    final conn = PostgreSQLConnection(
      DbConfig.host,
      DbConfig.port,
      DbConfig.databaseName,
      username: DbConfig.username,
      password: DbConfig.password,
    );

    await conn.open();
    _connection = conn;
    _isOpening = false;

    return _connection!;
  }

  Future<List<Map<String, dynamic>>> query(
    String sql, {
    Map<String, dynamic>? params,
  }) async {
    final conn = await _getConnection();

    final results = await conn.mappedResultsQuery(
      sql,
      substitutionValues: params ?? const {},
    );

    final flattened = <Map<String, dynamic>>[];

    for (final row in results) {
      final merged = <String, dynamic>{};
      for (final tableMap in row.values) {
        merged.addAll(tableMap);
      }
      flattened.add(merged);
    }

    return flattened;
  }

  Future<int> execute(String sql, {Map<String, dynamic>? params}) async {
    final conn = await _getConnection();
    return conn.execute(sql, substitutionValues: params ?? const {});
  }

  Future<void> close() async {
    if (_connection != null && _connection!.isClosed == false) {
      await _connection!.close();
      _connection = null;
    }
  }
}
