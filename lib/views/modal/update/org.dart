import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrgUpdate extends StatefulWidget {
  final int id;
  OrgUpdate({Key key, @required this.id}) : super(key: key);
  @override
  _OrgUpdateState createState() => _OrgUpdateState(id);
}

class _OrgUpdateState extends State<OrgUpdate> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final myformat = DateFormat("yyyy-MM-dd");
  DateTime selectedDate = DateTime.now();

   int id;
  _OrgUpdateState(this.id);

  TextEditingController _nameController = new TextEditingController();
  TextEditingController _startcontroller = new TextEditingController();
  TextEditingController _tillcontroller = new TextEditingController();
  TextEditingController _titleController = new TextEditingController();
  TextEditingController _descriptController = new TextEditingController();

  String _token;
  bool _isLoading = true;
  var dataOrg;

  Future<String> getUser() async {
    /**
     * Fetch Data from Uri
     */
    try {
      http.Response item = await http.get(
          Uri.encodeFull(
              "https://kariernesia.com/jwt/profile/organization/" + id.toString()),
          headers: {"Accept": "application/json"});

      this.setState(() {
        dataOrg = jsonDecode(item.body);
      });
      print("success get user");
    } catch (e) {
      print(e);
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

  Future<List> _save() async {
    setState(() {
      _isLoading = true;
    });
    var data = jsonEncode({
      "id" : id,
      "name": _nameController.text == null ? "" : _nameController.text,
      "start_period": _startcontroller.text == null ? "" : _startcontroller.text,
      "end_period": _tillcontroller.text == null ? "" : _tillcontroller.text,
      "title": _titleController.text == null ? "" : _titleController.text,
      "descript": _descriptController.text == null ? "" : _descriptController.text,
    });

    final response = await http.post(
        "https://kariernesia.com/jwt/profile/organization/update?token=" + _token,
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

   void check_connecti() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        this.getUser();
        new Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _isLoading = false;
           _nameController.text = dataOrg["name"];
           _startcontroller.text = dataOrg["start_period"];
           _tillcontroller.text = dataOrg["end_period"];
           _titleController.text = dataOrg["title"];
           _descriptController.text = dataOrg["descript"];
          });
        });
      }
    } on SocketException catch (_) {
      _showAlert(
          'Oops!!', 'Your not connected', '"assets/images/no_connection.gif"');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this._loadToken();
    this.check_connecti();
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
            'Update Data Organization',
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
        body:  _isLoading
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
            :  SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                Container(
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                    child: TextField(
                      controller: _nameController,
                      // obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Organization\'s name',
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Padding(
                    padding:
                        EdgeInsets.only(bottom: 20.0, left: 25.0, right: 25.0),
                    child: TextField(
                      controller: _titleController,
                      // obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Organization Title',
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom: 20.0, left: 25.0, right: 25.0),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              controller: _startcontroller,
                              // obscureText: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Start Period',
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: Padding(
                            padding: EdgeInsets.only(
                                bottom: 20.0, left: 25.0, right: 25.0),
                            child: TextField(
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              controller: _tillcontroller,
                              // obscureText: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'End Period',
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  child: Padding(
                    padding:
                        EdgeInsets.only(bottom: 20.0, left: 25.0, right: 25.0),
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
