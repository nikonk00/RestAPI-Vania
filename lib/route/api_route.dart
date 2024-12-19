import 'package:vania/vania.dart';
import 'package:restapi/app/controllers/customer_controller.dart';
import 'package:restapi/app/controllers/order_controller.dart';
import 'package:restapi/app/controllers/vendor_controller.dart';
import 'package:restapi/app/controllers/product_controller.dart';
import 'package:restapi/app/controllers/productnotes_controller.dart';
import 'package:restapi/app/controllers/orderitems_controller.dart';
import 'package:restapi/app/controllers/user_controller.dart';
import 'package:restapi/app/controllers/auth_controller.dart';
import 'package:restapi/app/controllers/todo_controller.dart';
import 'package:restapi/app/http/middleware/authenticate.dart';
import 'package:mysql1/mysql1.dart';

class ApiRoute implements Route {
  static MySqlConnection? _connection; 

  // Metode untuk inisialisasi koneksi database
  static Future<void> initializeDatabase() async {
    try {
      final settings = ConnectionSettings(
        host: 'localhost',   
        port: 3306,          
        user: 'root',        
        db: 'db_mobilelanjut',  
      );

      _connection = await MySqlConnection.connect(settings);

      // Set koneksi database 
      CustomersController.setConnection(_connection!);
      OrdersController.setConnection(_connection!);
      VendorsController.setConnection(_connection!);
      ProductsController.setConnection(_connection!);
      ProductnotesController.setConnection(_connection!);
      OrderitemsController.setConnection(_connection!);

      print('Koneksi database berhasil diinisialisasi.');
    } catch (e) {
      print('Gagal menghubungkan ke database: $e');
      rethrow; 
    }
  }

  @override
  void register() {
    // Inisialisasi koneksi database sebelum mendaftarkan rute
    initializeDatabase().then((_) {
      Router.basePrefix('api');

      Router.get('/customers', CustomersController.show);
      Router.get('/orders', OrdersController.show);
      Router.get('/vendors', VendorsController.show);
      Router.get('/products', ProductsController.show);
      Router.get('/productnotes', ProductnotesController.show);
      Router.get('/orderitems', OrderitemsController.show);

      Router.post('/customers', CustomersController.create);
      Router.post('/orders', OrdersController.create);
      Router.post('/orderitems', OrderitemsController.create);
      Router.post('/productnotes', ProductnotesController.create);
      Router.post('/products', ProductsController.create);
      Router.post('/vendors', VendorsController.create);

      Router.put('/customers', CustomersController.update);
      Router.put('/orders', OrdersController.update);
      Router.put('/orderitems', OrderitemsController.update);
      Router.put('/productnotes', ProductnotesController.update);
      Router.put('/products', ProductsController.update);
      Router.put('/vendors', VendorsController.update);
    
      Router.delete('/customers/{id}', CustomersController.delete);
      Router.delete('/vendors/{id}', VendorsController.delete);
      Router.delete('/orders/{id}', OrdersController.delete);
      Router.delete('/orderitems/{id}', OrderitemsController.delete);
      Router.delete('/products/{id}', ProductsController.delete);
      Router.delete('/productnotes/{id}', ProductnotesController.delete);

      Router.group(() {
      Router.post('register', authController.register);
      Router.post('login', authController.login);
      }, prefix: 'auth');

      Router.group(() {
        Router.patch('update-password', userController.updatePassword);
        Router.get('', userController.index);
      }, prefix: 'user', middleware: [AuthenticateMiddleware()]);

      Router.group(() {
        Router.post('todo', todoController.store);
      }, prefix: 'todo', middleware: [AuthenticateMiddleware()]);

    }).catchError((e) {
      print('Error saat mendaftarkan rute: $e');
    });
  }
}

