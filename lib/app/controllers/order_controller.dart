import 'package:vania/vania.dart';
import 'package:mysql1/mysql1.dart';

class OrdersController extends Controller {
  static late MySqlConnection connection;

  static void setConnection(MySqlConnection conn) {
    connection = conn;
  }

  // GET All Customers (Metode Statis)
  static Future<Response> show(Request request) async {
    try {
      // Query langsung ke database
      final results = await connection.query('SELECT * FROM orders');

      // Map hasil query menjadi List of Map
      final listOrders = results.map((row) {
      final map = row.fields;

      // Serialisasi order_date jika ada
      if (map['order_date'] != null && map['order_date'] is DateTime) {
        map['order_date'] = (map['order_date'] as DateTime).toIso8601String();
      }

      return map;
      }).toList();

      // Return response JSON
      return Response.json({
        'message': 'Daftar order',
        'data': listOrders,
      }, 200);
    } catch (e) {
      // Tangani jika terjadi error
      return Response.json({
        'message': 'Terjadi kesalahan saat mengambil data pelanggan.',
        'error': e.toString(),
      }, 500);
    }
  }

  // POST Add Order
  static Future<Response> create(Request request) async {
    try {
      // Parse body JSON
      final body = request.body as Map<String, dynamic>;

      // Validasi data input
      if (!body.containsKey('order_num') ||
          !body.containsKey('order_date') ||
          !body.containsKey('cust_id')) {
        return Response.json({
          'message': 'Data pesanan tidak lengkap.',
        }, 400);
      }

      // Query untuk menambahkan data ke tabel
      final result = await connection.query(
        '''
        INSERT INTO orders (order_num, order_date, cust_id)
        VALUES (?, ?, ?)
        ''',
        [
          body['order_num'],
          body['order_date'],
          body['cust_id'],
        ],
      );

      // Jika sukses
      return Response.json({
        'message': 'Pesanan berhasil ditambahkan.',
        'inserted_id': body['order_num'],
      }, 201);
    } catch (e) {
      // Tangani jika terjadi error
      return Response.json({
        'message': 'Terjadi kesalahan saat menambahkan pesanan.',
        'error': e.toString(),
      }, 500);
    }
  }

  // PUT Update Order
  static Future<Response> update(Request request) async {
    try {
      // Parse body JSON
      final body = request.body as Map<String, dynamic>;

      // Validasi data input
      if (!body.containsKey('order_num')) {
        return Response.json({
          'message': 'Nomor pesanan diperlukan untuk memperbarui data.',
        }, 400);
      }

      // Query untuk memperbarui data di tabel
      final result = await connection.query(
        '''
        UPDATE orders
        SET order_date = ?, cust_id = ?
        WHERE order_num = ?
        ''',
        [
          body['order_date'],
          body['cust_id'],
          body['order_num'],
        ],
      );

      // Jika sukses
      return Response.json({
        'message': 'Data pesanan berhasil diperbarui.',
      }, 200);
    } catch (e) {
      // Tangani jika terjadi error
      return Response.json({
        'message': 'Terjadi kesalahan saat memperbarui data pesanan.',
        'error': e.toString(),
      }, 500);
    }
  }

  static Future<Response> delete(int id) async {
  try {
    // Cari pesanan berdasarkan ID
    final results = await connection.query(
      'SELECT * FROM orders WHERE order_num = ?',
      [id],
    );

    if (results.isEmpty) {
      return Response.json({
        'message': 'Pesanan dengan ID $id tidak ditemukan.',
      }, 404);
    }

    // Hapus pesanan
    await connection.query(
      'DELETE FROM orders WHERE order_num = ?',
      [id],
    );

    return Response.json({
      'message': 'Pesanan berhasil dihapus.',
    }, 200);
  } catch (e) {
    return Response.json({
      'message': 'Terjadi kesalahan saat menghapus pesanan.',
      'error': e.toString(),
    }, 500);
  }
}


}
