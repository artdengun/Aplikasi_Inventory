import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// CLASS INI AKAN MENG-HANDLE FORMAT DATA YANG DIINGINKAN
class ProductItem {
  final String id;
  final String title;
  final int stock;
  final String description;

  ProductItem(
      {@required this.id,
        @required this.title,
        @required this.stock,
        @required this.description});
}

//CLASS INI BERTINDAK UNTUK MENG-HANDLE STATE MANAGEMENT
class Products with ChangeNotifier {
  List<ProductItem> _items = []; //KITA INISIASI DATA AWAL KOSONG DENGAN TIPE LIST DAN DIDALAMNYA MEMILIKI FORMAT DATA SESUAI DENGAN PRODUCT ITEM.
  //PROPERTY DENGAN PREFIX _ MENDANDAKAN BAHWA DIA BERSIFAT PRIVATE

  //MAKA KITA BUAT LAGI SEBUAH GETTER YANG BERISI DATA DARI PROPERTY _ITEMS, DIMANA GETTERS INI YANG AKAN DIAKSES SECARA PUBLIK.
  List<ProductItem> get items {
    return [..._items];
  }

  //METHOD INI BERFUNGSI UNTUK MENGAMBIL DATA DARI SERVER
  Future<void> fetchProduct() async {
    //DIMANA BACKEND YG DIGUNAKAN ADALAH FIREBASE
    const url = 'https://dw-xxxx.firebaseio.com/products.json';
    final response = await http.get(url); //MENGGUNAKAN AWAIT UNTUK MENUNGGU PROSESNYA SEBELUM MELANJUTKAN KE CODE SELANJUTNYA
    final convertData = json.decode(response.body) as Map<String, dynamic>; //DECODE DATA DAN UBAH FORMATNYA DENGNA FORMAT MAP DAN KEYNYA ADALAH STRING, VALUENYA DYNAMIC
    final List<ProductItem> newData = []; //INISIASI LIST DATA BARU YANG KOSONG
    //JIKA HASIL DECODE KOSONG MAKA HENTIKAN PROSES
    if (convertData == null) {
      return;
    }
    //JIKA TIDAK KOSONG, INSERT DATA YANG DIDAPATKAN DARI SERVER KEDALAM NEW DATA
    convertData.forEach((key, value) {
      newData.add(ProductItem(
          id: key,
          title: value['title'],
          stock: value['stock'],
          description: value['description']));
    });
    //KEMUDIAN SEMUA DATA YANG ADA DI DALAM NEW DATA KITA MASUKKAN KE STATE _items
    _items = newData;
    notifyListeners(); //BERFUNGSI UNTUK MEMBERITAHUKAN BAHWA ADA DATA BARU SEHINGGA WIDGET AKAN DI RE-RENDER
  }
  //METHOD YANG BERFUNGSI UNTUK MENGAMBIL DATA TUNGGAL BERDASARKAN ID
  Future<ProductItem> findById(String id) async {
    final url = 'https://dw-inventory.firebaseio.com/products/$id.json';
    final response = await http.get(url);
    final convert = json.decode(response.body);
    //DATA TERSEBUT KITA RETURN MENGGUNAKAN FORM DARI CLASS PRODUCTITEM
    return ProductItem(id: id, title: convert['title'], description: convert['description'], stock: convert['stock']);
  }

//METHOD YG BERFUNGSI UNTUK MENAMBAHKAN DATA BARU
  Future<void> addProduct(ProductItem product) async {
    const url = 'https://dw-inventory.firebaseio.com/products.json';
    //METHOD YG DIGUNAKAN ADALAH POST DAN PADA PARAMETER KEDUA KITA KIRIMKAN DATANYA
    final response = await http.post(url,
        body: json.encode({
          'title': product.title,
          'stock': product.stock,
          'description': product.description
        }));
    //KEMUDIAN KITA ADD DATANYA KE LOCAL STATE AGAR TIDAK PERLU MELAKUKAN GET LG DARI SERVER
    _items.add(ProductItem(
      id: json.decode(response.body)['name'],
      title: product.title,
      stock: product.stock,
      description: product.description,
    ));
    notifyListeners(); //INFORMASIKAN UNTUK ME RE-RENDER WIDGET KARENA TERDAPAT DATA BARU
  }

//METHOD YG BERFUNGSI UNTUK MENGURANGI STOK BERDASARKAN ID
  Future<void> changeStock(String id) async {
    final url = 'https://dw-inventory.firebaseio.com/products/$id.json';
    final index = _items.indexWhere((prod) => prod.id == id);
    final stock = _items[index].stock - 1;

    await http.patch(url, body: json.encode({'stock': stock})); //UPDATE DATA DI SERVER

    //DAN UPDATE JUGA DI LOCAL STATE
    _items[index] = ProductItem(
      id: id,
      title: _items[index].title,
      description: _items[index].description,
      stock: stock,
    );
    notifyListeners();
  }

//METHOD INI UNTUK MENGUPDATE SEMUA INFORMASI DATA YANG SEDANG DI EDIT
  Future<void> updateProduct(ProductItem product) async {
    //BERDASARKAN ID PRODUCT
    final url = 'https://dw-inventory.firebaseio.com/products/${product.id}.json';
    //KEMUDIAN KITA KIRIMKAN PARAMETER DATA YANG INGIN DI PERBAHARUI
    await http.patch(url, body: json.encode({
      'title': product.title,
      'stock': product.stock,
      'description': product.description
    }));
    //KEMUDIAN KITA UPDATE JUGA LOCAL STATE
    final index = _items.indexWhere((prod) => prod.id == product.id);
    _items[index] = product;
    notifyListeners();
  }

//HAPUS PRODUK BERDASARKAN ID
  Future<void> removeProduct(String id) async {
    final url = 'https://dw-inventory.firebaseio.com/products/$id.json';
    await http.delete(url); //KIRIM PERMINTAAN KE SERVER
    _items.removeWhere((prod) => prod.id == id); //DAN HAPUS JUGA PADA LOCAL STATE
    notifyListeners();
  }
}
