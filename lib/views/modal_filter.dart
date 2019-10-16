import 'package:flutter/material.dart';

import 'dart:convert';

class ModalFilter extends StatefulWidget {
  @override
  _ModalFilterState createState() => _ModalFilterState();
}

class _ModalFilterState extends State<ModalFilter> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController _controller = new TextEditingController();
  TextEditingController loginPasswordController = new TextEditingController();

  String _text = "";
  var data;

  void _saveText() {
    setState(() {
      data = jsonEncode({"a": _controller.text, "b": "ini B"});
    });
    print("success");
    Navigator.pop(context, data);
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.close),
            color: Colors.orangeAccent,
            onPressed: () => Navigator.pop(context, _controller.text),
          ),
          backgroundColor: Colors.white,
          title: const Text(
            'Filter',
            style: TextStyle(color: Colors.orangeAccent),
          ),
          actions: [
            new FlatButton(
                onPressed: () {
                  //TODO: Handle save
                  _saveText();
                },
                child: new Text('SAVE',
                    style: Theme.of(context)
                        .textTheme
                        .subhead
                        .copyWith(color: Colors.orangeAccent))),
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                    child: TextField(
                      controller: _controller,
                      // obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Center(
                    child: Text(_controller.text),
                  ),
                ),
                Container(
                  child: Center(
                    child: Text(data == null ? "data from state" : data),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
