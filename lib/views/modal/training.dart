import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Training extends StatefulWidget {
  @override
  _TrainingState createState() => _TrainingState();
}

class _TrainingState extends State<Training> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final myformat = DateFormat("yyyy-MM-dd");
  DateTime selectedDate = DateTime.now();

  TextEditingController _namecontroller = new TextEditingController();
  TextEditingController _issuedateController = new TextEditingController();
  TextEditingController _issuedbyController = new TextEditingController();
  TextEditingController _descriptController = new TextEditingController();

  bool _isLoading = false;
  String _token;
  String _level;
  var data;
  var level = ["Good", "Fair", "Poor", "Rahter Not Say"];

  Future<List> _save() async {
    setState(() {
      _isLoading = true;
    });
    var data = jsonEncode({
      "name": _namecontroller.text == null ? "" : _namecontroller.text,
      "issueddate":
          _issuedateController.text == null ? "" : _issuedateController.text,
      "issuedby":
          _issuedbyController.text == null ? "" : _issuedbyController.text,
      "descript":
          _descriptController.text == null ? "" : _descriptController.text,
    });

    final response = await http.post(
        "https://kariernesia.com/jwt/profile/training/save?token=" + _token,
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

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        _issuedateController.text = myformat.format(selectedDate);
      });
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
            'Add Data Training',
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
                                labelText: 'Training Name',
                                hintText: 'ex. Junior Web Training'),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            bottom: 20.0, left: 25.0, right: 25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  _selectDate(
                                      context); // Call Function that has showDatePicker()
                                },
                                child: IgnorePointer(
                                  child: new TextFormField(
                                    controller: _issuedateController,
                                    decoration: new InputDecoration(
                                      hintText: selectedDate.toString(),
                                      border: OutlineInputBorder(),
                                      labelText: "Issue Date",
                                    ),
                                    onSaved: (String val) {},
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: 20.0, left: 25.0, right: 25.0),
                          child: TextField(
                            controller: _issuedbyController,
                            // obscureText: true,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Issued by',
                                hintText: 'ex. BNSP'),
                          ),
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: 20.0, left: 25.0, right: 25.0),
                          child: TextField(
                            controller: _descriptController,
                            maxLines: null,
                            // obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Description',
                            ),
                          ),
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
