import 'package:vania/vania.dart';
import 'package:mysql1/mysql1.dart';

class ProductsController extends Controller {
  static late MySqlConnection connection;

  static void setConnection(MySqlConnection conn) {
    connection = conn;
  }

  // GET All Customers (Metode Statis)
  static Future<Response> show(Request request) async {
    try {
      // Query langsung ke database
      final results = await connection.query('SELECT * FROM products');

      // Map hasil query menjadi List of Map
      final listProduct = results.map((row) => row.fields).toList();

      // Return response JSON
      return Response.json({
        'message': 'Daftar product',
        'data': listProduct,
      }, 200);
    } catch (e) {
      // Tangani jika terjadi error
      return Response.json({
        'message': 'Terjadi kesalahan saat mengambil data pelanggan.',
        'error': e.toString(),
      }, 500);
    }
  }

  // POST Add Product
  static Future<Response> create(Request request) async {
    try {
      // Parse body JSON
      final body = request.body as Map<String, dynamic>;

      // Validasi data input
      if (!body.containsKey('prod_id') ||
          !body.containsKey('vend_id') ||
          !body.containsKey('prod_name') ||
          !body.containsKey('prod_price') ||
          !body.containsKey('prod_desc')) {
        return Response.json({
          'message': 'Data produk tidak lengkap.',
        }, 400);
      }

      // Query untuk menambahkan data ke tabel
      final result = await connection.query(
        '''
        INSERT INTO products (prod_id, vend_id, prod_name, prod_price, prod_desc)
        VALUES (?, ?, ?, ?, ?)
        ''',
        [
          body['prod_id'],
          body['vend_id'],
          body['prod_name'],
          body['prod_price'],
          body['prod_desc'],
        ],
      );

      // Jika sukses
      return Response.json({
        'message': 'Produk berhasil ditambahkan.',
        'inserted_id': body['prod_id'],
      }, 201);
    } catch (e) {
      // Tangani jika terjadi error
      return Response.json({
        'message': 'Terjadi kesalahan saat menambahkan produk.',
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
    if (!body.containsKey('prod_id')) {
      return Response.json({
        'message': 'ID produk diperlukan untuk memperbarui data.',
      }, 400);
    }

    // Query untuk memperbarui data di tabel
    final result = await connection.query(
      '''
      UPDATE products
      SET vend_id = ?, prod_name = ?, prod_price = ?, prod_desc = ?
      WHERE prod_id = ?
      ''',
      [
        body['vend_id'],
        body['prod_name'],
        body['prod_price'],
        body['prod_desc'],
        body['prod_id'],
      ],
    );

    // Jika sukses
    return Response.json({
      'message': 'Data produk berhasil diperbarui.',
    }, 200);
  } catch (e) {
    // Tangani jika terjadi error
    return Response.json({
      'message': 'Terjadi kesalahan saat memperbarui data produk.',
      'error': e.toString(),
    }, 500);
  }
}

  static Future<Response> delete(int id) async {
    try {
      // Cari produk berdasarkan ID
      final results = await connection.query(
        'SELECT * FROM products WHERE prod_id = ?',
        [id],
      );

      if (results.isEmpty) {
        return Response.json({
          'message': 'Produk dengan ID $id tidak ditemukan.',
        }, 404);
      }

      // Hapus produk
      await connection.query(
        'DELETE FROM products WHERE prod_id = ?',
        [id],
      );

      return Response.json({
        'message': 'Produk berhasil dihapus.',
      }, 200);
    } catch (e) {
      return Response.json({
        'message': 'Terjadi kesalahan saat menghapus produk.',
        'error': e.toString(),
      }, 500);
    }
  }


}
