import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart'; //IMPORT PROVIDER products YANG TELAH DIBUAT TADI
import '../components/product_list.dart';
import '../components/side_bar.dart';

class ProductPage extends StatelessWidget {
  //FUNGSI UNTUK ME-LOAD DATA TERBARU
  Future<void> _refreshData(BuildContext context) async {
    //CALL FUNGSI fetchProduct() DARI PROVIDERS Products.dart
    await Provider.of<Products>(context, listen: false).fetchProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DW Data Barang'),
      ),
      drawer: SideBar(), //DRAWER BERFUNGSI UNTUK MENGATUR SIDEBAR MENU
      body: RefreshIndicator(
        onRefresh: () => _refreshData(context), //KETIKA DIPULL DOWN, MAKA FUNGSI _refreshData() DIJALANKAN
        child: FutureBuilder(
          //LOAD DATA MENGGUNAKAN FUTUREBUILDER
          future: Provider.of<Products>(context, listen: false).fetchProduct(),
          builder: (ctx, snapshop) {
            //KETIKA MASIH LOADING
            if (snapshop.connectionState == ConnectionState.waiting) {
              //MAKA RENDER WIDGET LOADING
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              //JIKA TERDAPAT ERROR
              if (snapshop.error != null) {
                //MAKA TAMPILKAN TEXT ERROR
                return Center(
                  child: Text("Error Loading Data"),
                );
              } else {
                //KETIKA LOADING DATA SELESAI DAN TIDAK ADA ERROR
                //MAKA KITA AMBIL STATE PRODUCTS MENGGUNAKAN CONSUMER
                return Consumer<Products>(
                  builder: (ctx, product, child) => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      //DIMANA STATE YANG DIAMBIL DARI PRODUCT YANG DIDALAMNYA TERDAPAT STATE ITEMS
                      itemCount: product.items.length,
                      //ADAPUN TAMPILANNYA AKAN DI-HANDLE OLEH CUSTOM COMPONENTS
                      //MAKA KITA TINGGAL MENGIRIMKAN DATA SETIAP ITEM KE CUSTOM COMPONENTS TERSEBUT
                      itemBuilder: (ctx, i) => ProductList(
                        product.items[i].id,
                        product.items[i].title,
                        product.items[i].description,
                        product.items[i].stock,
                        false,
                      ),
                    ),
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
