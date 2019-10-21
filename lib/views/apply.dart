import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Apply extends StatefulWidget {
  @override
  _ApplyState createState() => _ApplyState();
}

class _ApplyState extends State<Apply> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: isLoading
          ? Container(
              padding: EdgeInsets.only(top: 300),
              child: Center(
                child: Column(
                  children: <Widget>[
                    CircularProgressIndicator(
                      backgroundColor: Colors.white,
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.orange),
                    ),
                    Text("Loading")
                  ],
                ),
              ))
          : SingleChildScrollView(
              child: Center(
                child: Text("Hello this is Apply screen"),
              ),
            ),
    );
  }
}
