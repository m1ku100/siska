import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SkillUpdate extends StatefulWidget {
  final int id;
  SkillUpdate({Key key, @required this.id}) : super(key: key);
  @override
  _SkillUpdateState createState() => _SkillUpdateState(id);
}

class _SkillUpdateState extends State<SkillUpdate> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int id;
  _SkillUpdateState(this.id);

  TextEditingController _namecontroller = new TextEditingController();
  TextEditingController _levelcontroller = new TextEditingController();

  bool _isLoading = true;
  String _token;
  String _level;
  var dataSkill;
  var level = ["Good", "Fair", "Poor", "Rahter Not Say"];

  Future<String> getUser() async {
    /**
     * Fetch Data from Uri
     */
    try {
      http.Response item = await http.get(
          Uri.encodeFull("https://kariernesia.com/jwt/profile/skill/" +
              id.toString()),
          headers: {"Accept": "application/json"});

      this.setState(() {
        dataSkill = jsonDecode(item.body);
      });
      print("success get user");
    } catch (e) {
      print(e);
    }
  }

  Future<List> _save() async {
    setState(() {
      _isLoading = true;
    });
    var data = jsonEncode({
      "id" : id,
      "name": _namecontroller.text == null ? "" : _namecontroller.text,
      "level": _level == null ? "" : _level,
    });

    final response = await http.post(
        "https://kariernesia.com/jwt/profile/skill/update?token=" + _token,
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

   void check_connecti() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        this.getUser();
        new Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _isLoading = false;
           _namecontroller.text = dataSkill["name"];
           _level= dataSkill["level"];
          
          });
        });
      }
    } on SocketException catch (_) {
      _showAlert(
          'Oops!!', 'Your not connected', '"assets/images/no_connection.gif"');
    }
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
    print(id);
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
            'Add Data Skill',
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
                                labelText: 'Skill Name',
                                hintText: 'ex. Junior Web Programming'),
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
                          hint: Text("Select Skill Level"),
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
                              _level = newVal;
                            });
                          },
                          value: _level,
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
