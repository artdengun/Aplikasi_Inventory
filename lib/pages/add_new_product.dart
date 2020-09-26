import 'package:provider/provider.dart';

import '../providers/products.dart';
import 'package:flutter/material.dart';

class AddNewProduct extends StatefulWidget {
  @override
  _AddNewProductState createState() => _AddNewProductState();
}

class _AddNewProductState extends State<AddNewProduct> {
  final _titleDispose = FocusNode();
  final _priceDispose = FocusNode();
  final _descriptionDispose = FocusNode();

  final _titleController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _form = GlobalKey<FormState>();  //MEMBUAT GLOBAL KEY UNTUK FORM() WIDGET
  var _isLoading = false;
  var _initValue = true;
  String id;

  @override
  void didChangeDependencies() async {
    //KETIKA TERJADI PERUBAHANGAN MAKA FUNGSI INI DIJALANKAN, KITA CEK JIKA BERNILAI TRUE
    if (_initValue) {
      //MAKA _isLoading DIUBAH JADI TRUE
      setState(() {
        _isLoading = true;
      });
      //MENGAMBIL ID  YANG DIKIRIMKAN JIKA ADA (ID INI DIKIRIMKAN KETIKA TOMBOL EDIT DITEKAN)
      id = ModalRoute.of(context).settings.arguments as String;
      //DI CEK JIKA ID NYA TIDAK KOSONG, YANG BERARTI DARI EDIT AKAN BERISI ID. SEDANGKAN DARI ADD NEW ID NYA KOSONG
      if (id != null) {
        //MAKA AKAN MENJALANKAN FUNGSI findById()
        final response = await Provider.of<Products>(context).findById(id);
        //KEMUDIAN DATA YANG DITERIMA AKAN DI ASSIGN
        _titleController.text = response.title;
        _stockController.text = response.stock.toString();
        _descriptionController.text = response.description;
      }
      //UBAH KEMBALI LOADING JADI FALSE
      setState(() {
        _isLoading = false;
      });
    }
    //INIT VALUE DI SET JADI FALSE AGAR TIDAK DIJALANKAN KEMBALI SEHINGGA FUNGSI DIATAS HANYA AKAN DIJALANKAN SEKALI KETIKA HALAMAN DILOAD
    _initValue = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _titleDispose.dispose();
    _priceDispose.dispose();
    _descriptionDispose.dispose();
    super.dispose();
  }

  //FUNGSI SUBMIT UNTUK MENYIMPAN DATA
  Future<void> _submit() async {
    final isValid = _form.currentState.validate(); //JALANKAN VALIDASI, DIMANA FUNGSI INI TELAH DISEDIAKAN OLEH FORM WIDGET()
    //JIKA TIDAK VALID
    if (!isValid) {
      return; //MAKA HENTIKAN PROSES
    }
    _form.currentState.save(); //JIKA VALID MAKA FUNGSI SAVE() DIJALANKAN, DIMANA FUNGSI INI JUGA DARI FORM WIDGET
    //SET LOADING JADI TRUE
    setState(() {
      _isLoading = true;
    });

    //KARENA FORM INI REUSABLE, MAKA CEK JIKA ID NULL
    if (id == null) {
      //MAKA YANG DIJALANKAN ADALAH FUNGSI ADD PRODUCT
      await Provider.of<Products>(context, listen: false)
          .addProduct(ProductItem(
        id: null,
        title: _titleController.text,
        stock: int.parse(_stockController.text),
        description: _descriptionController.text,
      ));
      //SELAIN ITU MAKA FUNGSI YANG DIJALANKAN ADALAH UPDATE PRODUCT
    } else {
      await Provider.of<Products>(context, listen: false)
          .updateProduct(ProductItem(
        id: id,
        title: _titleController.text,
        stock: int.parse(_stockController.text),
        description: _descriptionController.text,
      ));
    }
    //SET KEMBALI LOADING JADI FALSE
    setState(() {
      _isLoading = false;
    });
    //KEMBALI KE HALAMAN SEBELUMNYA
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(id == null ? 'Add New Product':'Edit Product'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _submit, //TOMBOL SIMPAN YANG KETIKA DITEKAN MAKA AKAN MENJALANKAN FUNGSI _submit YANG TELAH DIBUAT SEBELUMNYA
          )
        ],
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(), //KETIKA ISLOADING BERNILAI TRUE MAKA INDIKATOR LOADING AKAN DIRENDER
      )
          : Padding(
        padding: EdgeInsets.all(10),
        //SELAIN ITU AKAN MENAMPILKAN FORM INPUT
        child: Form(
          key: _form, //GLOBAL KEY YANG TELAH DIBUAT SEBELUMNYA DIGUNAKAN DISINI
          child: Column(
            children: <Widget>[
              //INPUTAN YANG MENGHANDLE NAMA BARANG
              TextFormField(
                decoration: InputDecoration(labelText: 'Nama Barang'),
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) {
                  FocusScope.of(context).requestFocus(_priceDispose);
                },
                //VALIDASI INPUTAN BARANG
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Nama Barang Tidak Boleh Kosong';
                  }
                  return null;
                },
                controller: _titleController, //ADAPUN VALUENYA TELAH DIHANDLE OLEH CONTROLLER MASING-MASING
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Stok'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                onFieldSubmitted: (_) {
                  FocusScope.of(context)
                      .requestFocus(_descriptionDispose);
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Stok Tidak Boleh Kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Value Harus Berisi Angkat';
                  }
                  if (int.parse(value) <= 0) {
                    return 'Stok Harus Lebih Besar Dari 0';
                  }
                  return null;
                },
                controller: _stockController,
              ),
              TextFormField(
                maxLines: 3,
                decoration: InputDecoration(labelText: 'Deskripsi'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Deskripsi Tidak Boleh Kosong';
                  }
                  return null;
                },
                controller: _descriptionController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}