import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

class ProductList extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final int stock;
  final bool type;

  //BUAT CONSTRUCTOR UNTUK MEMINTA DATA DARI WIDGET YANG MENGGUNAKANNYA
  ProductList(this.id, this.title, this.description, this.stock, this.type);

  @override
  Widget build(BuildContext context) {
    //DISMISSIBLE, KETIKA ITEM PRODUKNYA DI GESER MAKA KITA AKAN MENJALANKAN ACTIONS
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.call_missed_outgoing,
          size: 40,
          color: Colors.white,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
      ),
      //ARAH GESERNYA LITA SET DARI KANAN KE KIRI
      direction: DismissDirection.endToStart,
      //KETIKA DI GESER
      confirmDismiss: (dismiss) {
        //MAKA AKAN MENAMPILKAN DIALOG
        showDialog(
          context: context,
          //DIMANA ISI DIALOGNYA ADALAH ALERTDIALOG
          builder: (ctx) => AlertDialog(
            title: Text("Kamu Yakin?"),
            content: Text("Kamu Akan Mengurangi Stok?"),
            actions: <Widget>[
              //KETIKA TOMBOL INI DITEKAN MAKA AKAN MENUTUP ALERT DENGAN MENGIRIMKAN VALUE FALSE
              FlatButton(
                child: Text(
                  "No",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
              ),
              //DAN TOMBOL INI BERFUNGSI SAMA TAPI MENGIRIMKAN VALUE TRUE
              FlatButton(
                child: Text(
                  "Yes",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
              )
            ],
          ),
        ).then((result) {
          //KITA CEK, JIKA VALUENYA BERNILAI TRUE
          if (result) {
            //DAN STOKNYA ADA
            if (stock > 0) {
              //MAKA FUNGSI CHANGESTOCK DARI PROVIDERS AKAN DIJALANKAN
              Provider.of<Products>(context, listen: false).changeStock(id);
            } else {
              //SELAIN ITU AKAN MENAMPILKAN SNACKBAR UNTUK INFORMASI
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text("Stok Kosong"),
                duration: Duration(seconds: 2),
              ));
            }
          }
        });
      },
      child: Card(
        elevation: 4,
        //ADAPUN TAMPILANNYA KITA GUNAKAN LISTTILE, DIMANA TERDAPAT 3 BAGIAN: LEADING, TITLE DAN TRAILING
        child: ListTile(
          //LEADING AKAN DI-RENDER PADA POSISI KIRI
          //BAGIAN INI AKAN KITA GUNAKAN UNTUK MENAMPILKAN STOK
          leading: CircleAvatar(
            child: Text(stock.toString()),
          ),
          //TITLE AKAN DI-RENDER DITENGAH SETELAH LEADING, DAN BAGIAN INI AKAN MENAMPILKAN NAMA BARANG
          title: Text(title),
          //SUBTITLE AKAN DI-RENDER DIBAWAH TITLE. BAGIAN INI AKAN DIGUNAKAN UNTUK MENAMPILKAN DESKRIPS
          subtitle: Text(
            'Deskripsi: $description',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          //TRAILING AKAN DI-RENDER DISEBELAH KANAN
          //LALU KITA CEK JIKA TYPENYA FALSE, KITA AKAN MENAMPILKAN STATUS STOK
          trailing: !type
              ? Text(
            stock > 0 ? 'In Stock' : 'Sold Out',
            style:
            TextStyle(color: stock > 0 ? Colors.green : Colors.red),
          )
          //DAN JIKA TRUE, MAKA AKAN MENAMPILKAN TOMBOL EDIT DAN HAPUS
              : Container(
            width: 100,
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    //EDIT BERISI FUNGSI UNTUK BERPINDAH PAGE DENGAN MENGIRIMKAN ARGUMENTS ID
                    Navigator.of(context)
                        .pushNamed('/add-product', arguments: id);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    //SEDANGKAN DELETE AKAN MENAMPILKAN ALERT DIALOG LAGI UNTUK KONFIRMASI
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text("Kamu Yakin?"),
                        content: Text("Proses Ini Akan Menghapus Data"),
                        actions: <Widget>[
                          FlatButton(
                            child: Text(
                              "Batal",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                          FlatButton(
                            child: Text(
                              "Lanjutkan",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              //JIKA YES, MAKA FUNGSI removeProduct AKAN DIJALANKAN
                              Provider.of<Products>(context,
                                  listen: false)
                                  .removeProduct(id)
                                  .then((_) {
                                Navigator.of(context).pop(false);
                              });
                            },
                          )
                        ],
                      ),
                    );
                  },
                  color: Theme.of(context).errorColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
