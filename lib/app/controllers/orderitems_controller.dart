import 'package:vania/vania.dart';
import 'package:mysql1/mysql1.dart';

class OrderitemsController extends Controller {
  static late MySqlConnection connection;

  static void setConnection(MySqlConnection conn) {
    connection = conn;
  }

  // GET All Customers (Metode Statis)
  static Future<Response> show(Request request) async {
    try {
      // Query langsung ke database
      final results = await connection.query('SELECT * FROM orderitems');

      // Map hasil query menjadi List of Map
      final listOrderitems = results.map((row) => row.fields).toList();

      // Return response JSON
      return Response.json({
        'message': 'Daftar orderitem',
        'data': listOrderitems,
      }, 200);
    } catch (e) {
      // Tangani jika terjadi error
      return Response.json({
        'message': 'Terjadi kesalahan saat mengambil data pelanggan.',
        'error': e.toString(),
      }, 500);
    }
  }

  // POST Add Order Item
  static Future<Response> create(Request request) async {
    try {
      // Parse body JSON
      final body = request.body as Map<String, dynamic>;

      // Validasi data input
      if (!body.containsKey('order_item') ||
          !body.containsKey('order_num') ||
          !body.containsKey('prod_id') ||
          !body.containsKey('quantity') ||
          !body.containsKey('size')) {
        return Response.json({
          'message': 'Data item pesanan tidak lengkap.',
        }, 400);
      }

      // Query untuk menambahkan data ke tabel
      final result = await connection.query(
        '''
        INSERT INTO orderitems (order_item, order_num, prod_id, quantity, size)
        VALUES (?, ?, ?, ?, ?)
        ''',
        [
          body['order_item'],
          body['order_num'],
          body['prod_id'],
          body['quantity'],
          body['size'],
        ],
      );

      // Jika sukses
      return Response.json({
        'message': 'Item pesanan berhasil ditambahkan.',
        'inserted_id': body['order_item'],
      }, 201);
    } catch (e) {
      // Tangani jika terjadi error
      return Response.json({
        'message': 'Terjadi kesalahan saat menambahkan item pesanan.',
        'error': e.toString(),
      }, 500);
    }
  }

  // PUT Update OrderItems
  static Future<Response> update(Request request) async {
    try {
      // Parse body JSON
      final body = request.body as Map<String, dynamic>;

      // Validasi data input
      if (!body.containsKey('order_item')) {
        return Response.json({
          'message': 'Order item ID diperlukan untuk memperbarui data.',
        }, 400);
      }

      // Query untuk memperbarui data di tabel
      final result = await connection.query(
        '''
        UPDATE orderitems
        SET order_num = ?, prod_id = ?, quantity = ?, size = ?
        WHERE order_item = ?
        '''
        , [
          body['order_num'],
          body['prod_id'],
          body['quantity'],
          body['size'],
          body['order_item'],
        ],
      );

      // Jika sukses
      return Response.json({
        'message': 'Data order item berhasil diperbarui.',
      }, 200);
    } catch (e) {
      // Tangani jika terjadi error
      return Response.json({
        'message': 'Terjadi kesalahan saat memperbarui data order item.',
        'error': e.toString(),
      }, 500);
    }
  }

  static Future<Response> delete(int id) async {
  try {
    // Cari item pesanan berdasarkan ID
    final results = await connection.query(
      'SELECT * FROM orderitems WHERE order_item = ?',
      [id],
    );

    if (results.isEmpty) {
      return Response.json({
        'message': 'Item pesanan dengan ID $id tidak ditemukan.',
      }, 404);
    }

    // Hapus item pesanan
    await connection.query(
      'DELETE FROM orderitems WHERE order_item = ?',
      [id],
    );

    return Response.json({
      'message': 'Item pesanan berhasil dihapus.',
    }, 200);
  } catch (e) {
    return Response.json({
      'message': 'Terjadi kesalahan saat menghapus item pesanan.',
      'error': e.toString(),
    }, 500);
  }
}


}
