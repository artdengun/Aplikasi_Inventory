import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './pages/master_product_page.dart';
import './pages/add_new_product.dart';
import './pages/product_page.dart';
import './providers/products.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //
    return MultiProvider(
      providers: [
        //BERFUNGSI UNTUK ME-LOAD PROVIDER Products
        //JIKA MENGGUNAKAN LEBIH DARI 1 PROVIDER CUKUP PISAHKAN DENGAN COMMAND DI DALAM ARRAY providers.
        ChangeNotifierProvider.value(
          value: Products(),
        ),
        // ChangeNotifierProvider.value(
        //   value: ProviderLain(),
        // ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Daengweb.id',
        theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: Colors.pink,
            accentColor: Colors.yellow),
        //ROUTING UNTUK MENGATUR SETIAP PAGE YANG DI-LOAD
        routes: {
          '/': (ctx) => ProductPage(),
          '/manage-product': (ctx) => MasterProductPage(), //TAMBAHKAN LINE INI
          '/add-product': (ctx) => AddNewProduct() //TAMBAHKAN LINE INI
        },
      ),
    );
  }
}
