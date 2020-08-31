import 'package:flutter/material.dart';
import 'package:share/share.dart';

class ItemPage extends StatelessWidget {
  final Map _itemData;

  ItemPage(this._itemData);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _itemData["itemurl"].split("https://tenor.com/view/")[1],
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  Share.share(_itemData["media"][0]["gif"]["url"]);
                })
          ],
        ),
        backgroundColor: Colors.black,
        body: Center(
          child: Image.network(_itemData["media"][0]["gif"]["url"]),
        ),
      ),
    );
  }
}
