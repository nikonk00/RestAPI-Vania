import 'package:mysql1/mysql1.dart';

class Database {
  Future<MySqlConnection> getConnection() async {
    final settings = ConnectionSettings(
      host: 'localhost',
      port: 3306,
      user: 'root',
      db: 'db_mobilelanjut',
      password: '',
    );
    return await MySqlConnection.connect(settings);
  }
}
