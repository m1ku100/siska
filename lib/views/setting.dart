import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'dart:io';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var dataUser;

  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _newpasswordController = new TextEditingController();
  TextEditingController _repasswordController = new TextEditingController();

  bool isLoading = true;
  bool _currentPass = true;
  bool _newPass = true;
  bool _reNewPass = true;
  bool _loginIndicator = true;

  String _token;
  String _msg;

  Future<String> getApply() async {
    try {
      http.Response item = await http.get(
          Uri.encodeFull("https://kariernesia.com/jwt/me?token=" + _token),
          headers: {"Accept": "application/json"});

      this.setState(() {
        dataUser = jsonDecode(item.body);
      });
      print("Load data success");
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

  void check_connecti() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        this.getApply();
        new Future.delayed(Duration(seconds: 1), () {
          // deleayed code here
          setState(() {
            isLoading = false;
            _emailController = new TextEditingController(
                text: dataUser == null ? "email" : dataUser["email"]);
          });
        });
      }
    } on SocketException catch (_) {
      _showAlert(
          'Oops!!', 'Your not connected', '"assets/images/no_connection.gif"');
    }
  }

  Future<List> _changePass() async {
    var data = jsonEncode({
      "password": _passwordController.text,
      "newpassword": _newpasswordController.text,
      "repassword": _repasswordController.text
    });

    final response = await http.post(
        "https://kariernesia.com/jwt/vacancy/update/password?token=" + _token,
        body: data);

    var dataChange = json.decode(response.body);

    if (dataChange.length == 0) {
      setState(() {
        _msg = "Login Fail";
      });
    } else {
      if (dataChange['success'] == false) {
        _showAlert("Oops!!", dataChange['message'], "assets/images/load.gif");
      } else if (dataChange['success'] == true) {
       _showAlert("Yeey!!", dataChange['message'], "assets/images/nutmeg.gif");
        setState(() {
         _passwordController.text = "";
         _newpasswordController.text = "";
         _repasswordController.text = ""; 
        });
      }
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
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text("Setting Account"),
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
                    controller: _emailController,
                    enabled: false,
                    // obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Email',
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  "Change Password",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              Container(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 10.0, bottom: 20.0, left: 25.0, right: 25.0),
                  child: TextField(
                    obscureText: _currentPass,
                    controller: _passwordController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Current Password',
                        suffixIcon: GestureDetector(
                          onTap: () {
                            _toggleCurrent();
                          },
                          child: Icon(
                            _currentPass
                                ? FontAwesomeIcons.eye
                                : FontAwesomeIcons.eyeSlash,
                            size: 15.0,
                            color: Colors.black,
                          ),
                        )),
                  ),
                ),
              ),
              Container(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 10.0, bottom: 20.0, left: 25.0, right: 25.0),
                  child: TextField(
                    obscureText: _newPass,
                    controller: _newpasswordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'New Password',
                      suffixIcon: GestureDetector(
                        onTap: () {
                          _toggleNew();
                        },
                        child: Icon(
                          _newPass
                              ? FontAwesomeIcons.eye
                              : FontAwesomeIcons.eyeSlash,
                          size: 15.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 10.0, bottom: 20.0, left: 25.0, right: 25.0),
                  child: TextField(
                    obscureText: _reNewPass,
                    controller: _repasswordController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Re-type New Password',
                      suffixIcon: GestureDetector(
                        onTap: () {
                          _toggleRenew();
                        },
                        child: Icon(
                          _reNewPass
                              ? FontAwesomeIcons.eye
                              : FontAwesomeIcons.eyeSlash,
                          size: 15.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 10.0, bottom: 20.0, left: 25.0, right: 25.0),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(5.0),
                    ),
                    elevation: 3,
                    color: Colors.orangeAccent,
                    onPressed: () {
                      _changePass();
                    },
                    child: Text(
                      "Change Password",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleCurrent() {
    setState(() {
      _currentPass = !_currentPass;
    });
  }

  void _toggleNew() {
    setState(() {
      _newPass = !_newPass;
    });
  }

  void _toggleRenew() {
    setState(() {
      _reNewPass = !_reNewPass;
    });
  }
}
