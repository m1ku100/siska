import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Language extends StatefulWidget {
  @override
  _LanguageState createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final myformat = DateFormat("yyyy-MM-dd");
  DateTime selectedDate = DateTime.now();

  TextEditingController _namecontroller = new TextEditingController();
  TextEditingController _levelcontroller = new TextEditingController();

  bool _isLoading = false;
  String _token;
  String _levelSpoken;
  String _levelWritten;
  var data;
  var level = ["Good", "Fair", "Poor", "Rahter Not Say"];

  Future<List> _save() async {
    setState(() {
      _isLoading = true;
    });
    var data = jsonEncode({
      "name": _namecontroller.text == null ? "" : _namecontroller.text,
      "spoken_lvl": _levelSpoken == null ? "" : _levelSpoken,
      "written_lvl": _levelWritten == null ? "" : _levelWritten,
    });

    final response = await http.post(
        "https://kariernesia.com/jwt/profile/lang/save?token=" + _token,
        body: data);

    var datauser = json.decode(response.body);

    if (datauser.length == 0) {
      setState(() {});
    } else {
      if (datauser['success'] == false) {
        setState(() {
          _isLoading = false;
        });
        _showAlert("Oops!!", datauser['message'], "assets/images/load.gif");
      } else if (datauser['success'] == true) {
        Navigator.pop(context, jsonEncode({"load": true}));
      }
    }
  }

  void _showAlert(String titl, String desc, String assets) {
    if (titl.isEmpty) return; //if text is empty

    AssetGiffyDialog alert = new AssetGiffyDialog(
      image: Image.asset(assets),
      title: Text(
        titl,
        style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
      ),
      description: Text(desc),
      onOkButtonPressed: () {
        Navigator.pop(context);
      },
      onlyOkButton: true,
      buttonOkColor: Colors.orange[200],
    );

    showDialog(context: context, child: alert);
  }

  _loadToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      _token = (preferences.getString("token") ?? "");
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this._loadToken();
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
            onPressed: () =>
                Navigator.pop(context, jsonEncode({"load": false})),
          ),
          backgroundColor: Colors.white,
          title: const Text(
            'Add Data Language',
            style: TextStyle(color: Colors.orangeAccent),
          ),
          actions: [
            new FlatButton(
                onPressed: () {
                  _save();
                },
                child: new Text('SAVE',
                    style: Theme.of(context)
                        .textTheme
                        .subhead
                        .copyWith(color: Colors.orangeAccent))),
          ],
        ),
        body: _isLoading
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
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                          child: TextField(
                            controller: _namecontroller,
                            // obscureText: true,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Language',
                                hintText: 'ex. Japanese'),
                          ),
                        ),
                      ),
                      Container(
                        width: 345.0,
                        margin: EdgeInsets.only(
                            bottom: 20.0, left: 25.0, right: 25.0),
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Colors.grey,
                                width: 1.0,
                                style: BorderStyle.solid),
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                          ),
                        ),
                        child: new DropdownButton(
                          hint: Text("Speaking Level"),
                          isExpanded: true,
                          elevation: 3,
                          items: level?.map((item) {
                                return new DropdownMenuItem(
                                  value: item,
                                  child: new Text(
                                    item,
                                    style: new TextStyle(fontSize: 16.0),
                                  ),
                                );
                              })?.toList() ??
                              [],
                          onChanged: (newVal) {
                            setState(() {
                              _levelSpoken = newVal;
                            });
                          },
                          value: _levelSpoken,
                        ),
                      ),
                      Container(
                        width: 345.0,
                        margin: EdgeInsets.only(
                            bottom: 20.0, left: 25.0, right: 25.0),
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Colors.grey,
                                width: 1.0,
                                style: BorderStyle.solid),
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                          ),
                        ),
                        child: new DropdownButton(
                          hint: Text("Written Level"),
                          isExpanded: true,
                          elevation: 3,
                          items: level?.map((item) {
                                return new DropdownMenuItem(
                                  value: item,
                                  child: new Text(
                                    item,
                                    style: new TextStyle(fontSize: 16.0),
                                  ),
                                );
                              })?.toList() ??
                              [],
                          onChanged: (newVal) {
                            setState(() {
                              _levelWritten = newVal;
                            });
                          },
                          value: _levelWritten,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
