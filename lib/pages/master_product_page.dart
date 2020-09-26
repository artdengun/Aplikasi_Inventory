import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../components/side_bar.dart';
import '../components/product_list.dart';
import '../providers/products.dart';

class MasterProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //FUNGSI UNTUK ME-LOAD DATA BARANG YANG TERBARU.
    Future<void> _fetchData(BuildContext context) async {
      await Provider.of<Products>(context, listen: false).fetchProduct();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Manage Inventory"),
        actions: <Widget>[
          //DI APPBAR, KITA BUAT TOMBOL UNTUK BERPINDAH KE PAGE ADD PRODUCT
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed('/add-product');
            },
          )
        ],
      ),
      drawer: SideBar(), //SIDEBARNYA KITA GUNAKAN CLASS YANG SAMA
      body: FutureBuilder(
        //LOAD DATA MENGGUNAKAN FUTURE BUILDER
        future: Provider.of<Products>(context, listen: false).fetchProduct(),
        //PENJELASAN BAGIAN INI SAMA DENGAN PENJELASAN YANG ADA DI PRODUCT_PAGE.DART
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.error != null) {
              return Center(
                child: Text("Error Loading Data"),
              );
            } else {
              return Padding(
                padding: EdgeInsets.all(10),
                child: RefreshIndicator(
                  onRefresh: () => _fetchData(context),
                  child: Consumer<Products>(
                    builder: (context, product, child) => ListView.builder(
                      itemCount: product.items.length,
                      //BAGIAN INI JUGA SAMA SEPERTI SEBELUMNYA. KITA GUNAKAN PRODUCTLIST UNTUK MENAMPILKAN SETIAP ITEM BARANG
                      itemBuilder: (ctx, i) => ProductList(
                        product.items[i].id,
                        product.items[i].title,
                        product.items[i].description,
                        product.items[i].stock,
                        true,
                      ),
                    ),
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
