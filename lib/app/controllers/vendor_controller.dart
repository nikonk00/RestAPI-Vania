import 'package:vania/vania.dart';
import 'package:mysql1/mysql1.dart';

class VendorsController extends Controller {
  static late MySqlConnection connection;

  static void setConnection(MySqlConnection conn) {
    connection = conn;
  }

  // GET All Customers (Metode Statis)
  static Future<Response> show(Request request) async {
    try {
      // Query langsung ke database
      final results = await connection.query('SELECT * FROM vendors');

      // Map hasil query menjadi List of Map
      final listVendors = results.map((row) => row.fields).toList();
      

      // Return response JSON
      return Response.json({
        'message': 'Daftar vendor',
        'data': listVendors,
      }, 200);
    } catch (e) {
      // Tangani jika terjadi error
      return Response.json({
        'message': 'Terjadi kesalahan saat mengambil data pelanggan.',
        'error': e.toString(),
      }, 500);
    }
  }

  // POST Add Vendor
  static Future<Response> create(Request request) async {
    try {
      // Parse body JSON
      final body = request.body as Map<String, dynamic>;

      // Validasi data input
      if (!body.containsKey('vend_id') ||
          !body.containsKey('vend_name') ||
          !body.containsKey('vend_address') ||
          !body.containsKey('vend_kota') ||
          !body.containsKey('vend_state') ||
          !body.containsKey('vend_zip') ||
          !body.containsKey('vend_country')) {
        return Response.json({
          'message': 'Data vendor tidak lengkap.',
        }, 400);
      }

      // Query untuk menambahkan data ke tabel
      final result = await connection.query(
        '''
        INSERT INTO vendors (vend_id, vend_name, vend_address, vend_kota, vend_state, vend_zip, vend_country)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          body['vend_id'],
          body['vend_name'],
          body['vend_address'],
          body['vend_kota'],
          body['vend_state'],
          body['vend_zip'],
          body['vend_country'],
        ],
      );

      // Jika sukses
      return Response.json({
        'message': 'Vendor berhasil ditambahkan.',
        'inserted_id': body['vend_id'],
      }, 201);
    } catch (e) {
      // Tangani jika terjadi error
      return Response.json({
        'message': 'Terjadi kesalahan saat menambahkan vendor.',
        'error': e.toString(),
      }, 500);
    }
  }

  // PUT Update Product
  static Future<Response> update(Request request) async {
  try {
    // Parse body JSON
    final body = request.body as Map<String, dynamic>;

    // Validasi data input
    if (!body.containsKey('vend_id')) {
      return Response.json({
        'message': 'ID vendor diperlukan untuk memperbarui data.',
      }, 400);
    }

    // Query untuk memperbarui data di tabel
    final result = await connection.query(
      '''
      UPDATE vendors
      SET vend_name = ?, vend_address = ?, vend_kota = ?, vend_state = ?, vend_zip = ?, vend_country = ?
      WHERE vend_id = ?
      ''',
      [
        body['vend_name'],
        body['vend_address'],
        body['vend_kota'],
        body['vend_state'],
        body['vend_zip'],
        body['vend_country'],
        body['vend_id'],
      ],
    );

    // Jika sukses
    return Response.json({
      'message': 'Data vendor berhasil diperbarui.',
    }, 200);
  } catch (e) {
    // Tangani jika terjadi error
    return Response.json({
      'message': 'Terjadi kesalahan saat memperbarui data vendor.',
      'error': e.toString(),
    }, 500);
  }
}

  static Future<Response> delete(int id) async {
    try {
      // Cari vendor berdasarkan ID
      final results = await connection.query(
        'SELECT * FROM vendors WHERE vend_id = ?',
        [id],
      );

      if (results.isEmpty) {
        return Response.json({
          'message': 'Vendor dengan ID $id tidak ditemukan.',
        }, 404);
      }

      // Hapus vendor
      await connection.query(
        'DELETE FROM vendors WHERE vend_id = ?',
        [id],
      );

      return Response.json({
        'message': 'Vendor berhasil dihapus.',
      }, 200);
    } catch (e) {
      return Response.json({
        'message': 'Terjadi kesalahan saat menghapus vendor.',
        'error': e.toString(),
      }, 500);
    }
  }

}
