import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:giffy_dialog/giffy_dialog.dart';

class Detail extends StatefulWidget {
  final int id;
  Detail({Key key, @required this.id}) : super(key: key);
  @override
  _DetailState createState() => _DetailState(id);
}

class _DetailState extends State<Detail> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var dataJson;

  final bool horizontal = true;
  int id;
  _DetailState(this.id);

  Future<String> getData() async {
    /**
     * Fetch Data from Uri
     */
    http.Response item = await http.get(
        Uri.encodeFull(
            "http://siska.org/api/clients/vacancies/" + id.toString()),
        headers: {"Accept": "application/json"});

    this.setState(() {
      dataJson = json.decode(item.body);
    });
    print("success");
  }

  void check_connecti() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        this.getData();
      }
    } on SocketException catch (_) {
      _showAlert("You'are not connected");
    }
  }

  void _showSnackbar(String str) {
    if (str.isEmpty) return;

    scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(str),
      duration: new Duration(seconds: 2),
    ));
  }

  void _showAlert(String str) {
    if (str.isEmpty) return; //if text is empty

    AssetGiffyDialog alert = new AssetGiffyDialog(
      image: Image.asset("assets/images/no_connection.gif"),
      title: Text(
        str,
        style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
      ),
      description: Text("Turn On your data or Wi-Fi"),
      onOkButtonPressed: () {
        Navigator.pop(context);
      },
      buttonOkColor: Colors.orange[200],
    );

    showDialog(context: context, child: alert);
  }

  @override
  void initState() {
    // TODO: implement initState
    this.check_connecti();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange[200],
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(dataJson == null ? " " : dataJson["judul"]),
        ),
        body: new SingleChildScrollView(
          child: Container(
            child: Center(  
              child: Text("Hello"),
            ),
          ),
        ) 
        );
  }
}
