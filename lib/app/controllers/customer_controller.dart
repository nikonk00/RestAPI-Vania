import 'package:vania/vania.dart';
import 'package:mysql1/mysql1.dart';

class CustomersController extends Controller {
  static late MySqlConnection connection;

  static void setConnection(MySqlConnection conn) {
    connection = conn;
  }

  // GET All Customers 
  static Future<Response> show(Request request) async {
    try {
  
      final results = await connection.query('SELECT * FROM customers');

      final listCustomers = results.map((row) => row.fields).toList();

      return Response.json({
        'message': 'Daftar pelanggan.',
        'data': listCustomers,
      }, 200);
    } catch (e) {
      return Response.json({
        'message': 'Terjadi kesalahan saat mengambil data pelanggan.',
        'error': e.toString(),
      }, 500);
    }
  }

  // POST Add Customer
  static Future<Response> create(Request request) async {
    try {
      // Parse body JSON
      final body = request.body as Map<String, dynamic>;

      // Validasi data input
      if (!body.containsKey('cust_id') ||
          !body.containsKey('cust_name') ||
          !body.containsKey('cust_address') ||
          !body.containsKey('cust_city') ||
          !body.containsKey('cust_state') ||
          !body.containsKey('cust_zip') ||
          !body.containsKey('cust_country') ||
          !body.containsKey('cust_telp')) {
        return Response.json({
          'message': 'Data pelanggan tidak lengkap.',
        }, 400);
      }

      // Query untuk menambahkan data ke tabel
      final result = await connection.query(
        '''
        INSERT INTO customers (cust_id, cust_name, cust_address, cust_city, cust_state, cust_zip, cust_country, cust_telp)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          body['cust_id'],
          body['cust_name'],
          body['cust_address'],
          body['cust_city'],
          body['cust_state'],
          body['cust_zip'],
          body['cust_country'],
          body['cust_telp'],
        ],
      );

      // Jika sukses
      return Response.json({
        'message': 'Pelanggan berhasil ditambahkan.',
        'inserted_id': body['cust_id'],
      }, 201);
    } catch (e) {
      // Tangani jika terjadi error
      return Response.json({
        'message': 'Terjadi kesalahan saat menambahkan pelanggan.',
        'error': e.toString(),
      }, 500);
    }
  }

  // PUT Update Customer
  static Future<Response> update(Request request) async {
    try {
      // Parse body JSON
      final body = request.body as Map<String, dynamic>;

      // Validasi data input
      if (!body.containsKey('cust_id')) {
        return Response.json({
          'message': 'ID pelanggan diperlukan untuk memperbarui data.',
        }, 400);
      }

      // Query untuk memperbarui data di tabel
      final result = await connection.query(
        '''
        UPDATE customers
        SET cust_name = ?, cust_address = ?, cust_city = ?, cust_state = ?, cust_zip = ?, cust_country = ?, cust_telp = ?
        WHERE cust_id = ?
        ''',
        [
          body['cust_name'],
          body['cust_address'],
          body['cust_city'],
          body['cust_state'],
          body['cust_zip'],
          body['cust_country'],
          body['cust_telp'],
          body['cust_id'],
        ],
      );

      // Jika sukses
      return Response.json({
        'message': 'Data pelanggan berhasil diperbarui.',
      }, 200);
    } catch (e) {
      // Tangani jika terjadi error
      return Response.json({
        'message': 'Terjadi kesalahan saat memperbarui data pelanggan.',
        'error': e.toString(),
      }, 500);
    }
  }

  static Future<Response> delete(int id) async {
  try {
    // Cari pelanggan berdasarkan ID
    final results = await connection.query(
      'SELECT * FROM customers WHERE cust_id = ?',
      [id],
    );

    if (results.isEmpty) {
      return Response.json({
        'message': 'Pelanggan dengan ID $id tidak ditemukan.',
      }, 404);
    }

    // Hapus pelanggan
    await connection.query(
      'DELETE FROM customers WHERE cust_id = ?',
      [id],
    );

    return Response.json({
      'message': 'Pelanggan berhasil dihapus.',
    }, 200);
  } catch (e) {
    return Response.json({
      'message': 'Terjadi kesalahan saat menghapus pelanggan.',
      'error': e.toString(),
    }, 500);
  }
}

}
