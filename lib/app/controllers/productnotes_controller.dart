import 'package:vania/vania.dart';
import 'package:mysql1/mysql1.dart';

class ProductnotesController extends Controller {
  static late MySqlConnection connection;

  static void setConnection(MySqlConnection conn) {
    connection = conn;
  }

  // GET All Customers (Metode Statis)
  static Future<Response> show(Request request) async {
    try {
      // Query langsung ke database
      final results = await connection.query('SELECT * FROM productnotes');

      // Map hasil query menjadi List of Map
      final listProductnotes = results.map((row) {
      final map = row.fields;

      // Serialisasi order_date jika ada
      if (map['order_date'] != null && map['order_date'] is DateTime) {
        map['order_date'] = (map['order_date'] as DateTime).toIso8601String();
      }

      return map;
      }).toList();

      // Return response JSON
      return Response.json({
        'message': 'Daftar productnote',
        'data': listProductnotes,
      }, 200);
    } catch (e) {
      // Tangani jika terjadi error
      return Response.json({
        'message': 'Terjadi kesalahan saat mengambil data pelanggan.',
        'error': e.toString(),
      }, 500);
    }
  }

  // POST Add Product Note
  static Future<Response> create(Request request) async {
    try {
      // Parse body JSON
      final body = request.body as Map<String, dynamic>;

      // Validasi data input
      if (!body.containsKey('note_id') ||
          !body.containsKey('prod_id') ||
          !body.containsKey('note_date') ||
          !body.containsKey('note_text')) {
        return Response.json({
          'message': 'Data catatan produk tidak lengkap.',
        }, 400);
      }

      // Query untuk menambahkan data ke tabel
      final result = await connection.query(
        '''
        INSERT INTO productnotes (note_id, prod_id, note_date, note_text)
        VALUES (?, ?, ?, ?)
        ''',
        [
          body['note_id'],
          body['prod_id'],
          body['note_date'],
          body['note_text'],
        ],
      );

      // Jika sukses
      return Response.json({
        'message': 'Catatan produk berhasil ditambahkan.',
        'inserted_id': body['note_id'],
      }, 201);
    } catch (e) {
      // Tangani jika terjadi error
      return Response.json({
        'message': 'Terjadi kesalahan saat menambahkan catatan produk.',
        'error': e.toString(),
      }, 500);
    }
  }

  // PUT Update Product Note
  static Future<Response> update(Request request) async {
    try {
      // Parse body JSON
      final body = request.body as Map<String, dynamic>;

      // Validasi data input
      if (!body.containsKey('note_id')) {
        return Response.json({
          'message': 'ID catatan diperlukan untuk memperbarui data.',
        }, 400);
      }

      // Query untuk memperbarui data di tabel
      final result = await connection.query(
        '''
        UPDATE productnotes
        SET prod_id = ?, note_date = ?, note_text = ?
        WHERE note_id = ?
        ''',
        [
          body['prod_id'],
          body['note_date'],
          body['note_text'],
          body['note_id'],
        ],
      );

      // Jika sukses
      return Response.json({
        'message': 'Data catatan produk berhasil diperbarui.',
      }, 200);
    } catch (e) {
      // Tangani jika terjadi error
      return Response.json({
        'message': 'Terjadi kesalahan saat memperbarui data catatan produk.',
        'error': e.toString(),
      }, 500);
    }
  }

  static Future<Response> delete(int id) async {
  try {
    // Cari catatan produk berdasarkan ID
    final results = await connection.query(
      'SELECT * FROM productnotes WHERE note_id = ?',
      [id],
    );

    if (results.isEmpty) {
      return Response.json({
        'message': 'Catatan produk dengan ID $id tidak ditemukan.',
      }, 404);
    }

    // Hapus catatan produk
    await connection.query(
      'DELETE FROM productnotes WHERE note_id = ?',
      [id],
    );

    return Response.json({
      'message': 'Catatan produk berhasil dihapus.',
    }, 200);
  } catch (e) {
    return Response.json({
      'message': 'Terjadi kesalahan saat menghapus catatan produk.',
      'error': e.toString(),
    }, 500);
  }
}

}
