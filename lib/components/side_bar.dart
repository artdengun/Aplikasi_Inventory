import 'package:flutter/material.dart';
class SideBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(children: <Widget>[
        //KITA BUAT HEADER SIDEBARNYA
        AppBar(title: Text('Daengweb.id'), automaticallyImplyLeading: false,),
        Divider(), //GARIS PEMISAH

        //UNTUK SETIAP MENUNYA KITA GUNAKAN LIST TILE DIMANA LEADINGNYA BERISI ICON DAN TITLENYA BERISI NAMA MENU. ADAPUN KETIKA DI TAP MAKA AKAN MENUJU KE PAGENYA MASING-MASING
        ListTile(leading: Icon(Icons.devices), title: Text('Inventory'), onTap: () {
          Navigator.of(context).pushReplacementNamed('/');
        },),
        Divider(),
        ListTile(leading: Icon(Icons.lens), title: Text('Manage Inventory'), onTap: () {
          Navigator.of(context).pushReplacementNamed('/manage-product');
        },),
      ],),
    );
  }
}