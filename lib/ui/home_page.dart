import 'dart:async';
import 'dart:convert';
import 'package:busca_gif/ui/item_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

final String _apiKey = "OIM1E06VYG84";

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _baseURL = "https://api.tenor.com/v1";
  String _querySearch;
  String _nextPageValue;

  Future<Null> _buildSearch(text) async {
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _nextPageValue = null;
      _querySearch = text;
    });

    return null;
  }

  Future<Map> _getGifs() async {
    http.Response response;
    String next = _nextPageValue != null ? "&pos=$_nextPageValue" : "";

    if (_querySearch == null || _querySearch.isEmpty) {
      response = await http.get(
          "$_baseURL/trending?key=$_apiKey&locale=pt_BR&limit=20&media_filter=minimal$next");
      return json.decode(response.body);
    }

    response = await http.get(
        "$_baseURL/search?key=$_apiKey&q=$_querySearch&locale=pt_BR&limit=19&media_filter=minimal$next");

    return json.decode(response.body);
  }

  int _getDataSize(List data) {
    if (_querySearch == null || _querySearch.isEmpty) return data.length;
    return data.length + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Row(
            children: <Widget>[
              Image(
                  image: ResizeImage(
                      NetworkImage(
                          "https://e7.pngegg.com/pngimages/651/434/png-clipart-tenor-google-logo-gboard-others-blue-text.png"),
                      width: 100,
                      height: 100)),
              Padding(padding: EdgeInsets.only(right: 10.0)),
              Expanded(
                  child: Text(
                "Buscador de GIFs",
                style: TextStyle(fontFamily: 'GothicA1', fontSize: 25.0),
              )),
            ],
          ),
        ),
        backgroundColor: Colors.black,
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(10.0, 10.0, 14.0, 10.0),
              child: TextField(
                decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    border: OutlineInputBorder()),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontFamily: 'GothicA1'),
                onChanged: (text) {
                  _buildSearch(text);
                },
              ),
            ),
            Expanded(
                child: FutureBuilder(
                    future: _getGifs(),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return Container(
                            width: 200.0,
                            height: 200.0,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 5.0,
                            ),
                          );
                        default:
                          if (snapshot.hasError) return Container();
                          return _createGifGrid(context, snapshot);
                      }
                    }))
          ],
        ));
  }

  Widget _createGifGrid(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.only(left: 10.0, right: 14.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
        itemCount: _getDataSize(snapshot.data["results"]),
        itemBuilder: (context, index) {
          if (_querySearch == null || index < snapshot.data["results"].length) {
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data["results"][index]["media"][0]["gif"]
                    ["url"],
                fit: BoxFit.cover,
                height: 300.0,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ItemPage(snapshot.data["results"][index])));
              },
              onLongPress: () {
                Share.share(
                    snapshot.data["results"][index]["media"][0]["gif"]["url"]);
              },
            );
          }

          return Container(
            child: GestureDetector(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add_box,
                    color: Colors.white,
                    size: 70.0,
                  ),
                  Text(
                    "Carregar mais...",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontFamily: 'GothicA1'),
                  )
                ],
              ),
              onTap: () {
                setState(() {
                  _nextPageValue = snapshot.data["next"];
                });
              },
            ),
          );
        });
  }
}
