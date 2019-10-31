import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:async/async.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:siska/views/Widgets/custom_shape.dart';
import 'package:siska/constant/Constant.dart';

import 'package:siska/views/modal/contact.dart';
import 'package:siska/views/modal/education.dart';
import 'package:siska/views/modal/language.dart';
import 'package:siska/views/modal/org.dart';
import 'package:siska/views/modal/personal.dart';
import 'package:siska/views/modal/skill.dart';
import 'package:siska/views/modal/training.dart';
import 'package:siska/views/modal/work.dart';

import 'package:siska/views/modal/update/work.dart';
import 'package:siska/views/modal/update/education.dart';
import 'package:siska/views/modal/update/org.dart';
import 'package:siska/views/modal/update/skill.dart';
import 'package:siska/views/modal/update/language.dart';
import 'package:siska/views/modal/update/training.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var dataJson, upload_res;

  double _height;
  double _width;
  String _token;
  bool _isLoading = true;
  File _image;
  List _edu;
  List _exp;
  List _org;
  List _training;
  List _skill;
  List _lang;

  Future<String> getLatest() async {
    try {
      http.Response item = await http.get(
          Uri.encodeFull(AUTH + "profile/me?token=" + _token),
          headers: {"Accept": "application/json"});

      this.setState(() {
        dataJson = jsonDecode(item.body);
      });
      print("Success user");
    } catch (e) {
      print(e);
    }
  }

  Future<String> getEdu() async {
    try {
      http.Response item = await http.get(
          Uri.encodeFull(AUTH + "profile/show/edu?token=" + _token),
          headers: {"Accept": "application/json"});

      this.setState(() {
        _edu = jsonDecode(item.body);
      });
      print("Success edu");
    } catch (e) {
      print(e);
    }
  }

  Future<String> getExp() async {
    try {
      http.Response item = await http.get(
          Uri.encodeFull(AUTH + "profile/show/exp?token=" + _token),
          headers: {"Accept": "application/json"});

      this.setState(() {
        _exp = jsonDecode(item.body);
      });
      print("Success exp");
    } catch (e) {
      print(e);
    }
  }

  Future<String> getOrg() async {
    try {
      http.Response item = await http.get(
          Uri.encodeFull(AUTH + "profile/show/org?token=" + _token),
          headers: {"Accept": "application/json"});

      this.setState(() {
        _org = jsonDecode(item.body);
      });
      print("Success org");
    } catch (e) {
      print(e);
    }
  }

  Future<String> getTraining() async {
    try {
      http.Response item = await http.get(
          Uri.encodeFull(AUTH + "profile/show/training?token=" + _token),
          headers: {"Accept": "application/json"});

      this.setState(() {
        _training = jsonDecode(item.body);
      });
      print("Success org");
    } catch (e) {
      print(e);
    }
  }

  Future<String> getSkill() async {
    try {
      http.Response item = await http.get(
          Uri.encodeFull(AUTH + "profile/show/skill?token=" + _token),
          headers: {"Accept": "application/json"});

      this.setState(() {
        _skill = jsonDecode(item.body);
      });
      print("Success org");
    } catch (e) {
      print(e);
    }
  }

  Future<String> getlang() async {
    try {
      http.Response item = await http.get(
          Uri.encodeFull(AUTH + "profile/show/lang?token=" + _token),
          headers: {"Accept": "application/json"});

      this.setState(() {
        _lang = jsonDecode(item.body);
      });
      print("Success org");
    } catch (e) {
      print(e);
    }
  }

  Future upload(File image) async {
    setState(() {
      _isLoading = true;
    });
    var stream = new http.ByteStream(DelegatingStream.typed(image.openRead()));
    var length = await image.length();
    var uri = Uri.parse(AUTH + "profile/upload/ava?token=" + _token);

    var request = new http.MultipartRequest("POST", uri);

//set value dan dikirim ke server
    var multipart = new http.MultipartFile("image", stream, length,
        filename: path.basename(image.path));

    request.files.add(multipart);

    var response = await request.send();
    // this.setState(() {
    //   upload_res = jsonDecode(response.);
    // });
    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
      });
      _showAlert("Yeey!!", "upload Success", "assets/images/nutmeg.gif");
    } else if (response.statusCode == 500) {
      setState(() {
        _isLoading = false;
      });
      _showAlert('Oops!!', 'Internal Serve Error. Please try again',
          "assets/images/load.gif");
    } else {
      setState(() {
        _isLoading = false;
      });
      _showAlert('Oops!!', 'upload failed', "assets/images/load.gif");
    }
  }

  Future getImageGallery() async {
    var imageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 600, maxWidth: 800);

    setState(() {
      _image = imageFile;
    });
  }

  Future getImageCamera() async {
    var imageFile = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = imageFile;
    });
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
        this.getLatest();
        await this.getEdu();
        await this.getExp();
        await this.getOrg();
        await this.getTraining();
        await this.getSkill();
        await this.getlang();
        new Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _isLoading = false;
          });
        });
      }
    } on SocketException catch (_) {
      _showAlert(
          'Oops!!', 'Your not connected', '"assets/images/no_connection.gif"');
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

  void _openPersonal(BuildContext context) async {
    var result = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (BuildContext context) => new Personal(),
          fullscreenDialog: true,
        ));

    var data = jsonDecode(result);
    // print("hasil filter :"+data.toString());

    if (data["load"]) {
      setState(() {
        _isLoading = true;
      });

      check_connecti();
    }
  }

  void _openContact(BuildContext context) async {
    var result = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (BuildContext context) => new Contact(),
          fullscreenDialog: true,
        ));

    var data = jsonDecode(result);
    // print("hasil filter :"+data.toString());
    setState(() {});

    check_connecti();
  }

  void _openWork(BuildContext context) async {
    var result = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (BuildContext context) => new Work(),
          fullscreenDialog: true,
        ));

    var data = jsonDecode(result);
    // print("hasil filter :"+data.toString());
    setState(() {});

    check_connecti();
  }

  void _openWorkupdate(BuildContext context, int id) async {
    var result = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => WorkUpdate(
            id: id,
          ),
          fullscreenDialog: true,
        ));

    var data = jsonDecode(result);
    // print("hasil filter :"+data.toString());
    setState(() {});

    check_connecti();
  }

  Future<void> deleteExp(id) async {
    final response = await http.post(
      "https://kariernesia.com/jwt/profile/exp/delete/" +
          id.toString() +
          "?token=" +
          _token,
    );
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
        check_connecti();
        _showAlert(
            "Yeey!!", "Data Successfully Deleted", "assets/images/nutmeg.gif");
      }
    }
  }

  Future<void> deleteEdu(id) async {
    final response = await http.post(
      "https://kariernesia.com/jwt/profile/edu/delete/" +
          id.toString() +
          "?token=" +
          _token,
    );
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
        check_connecti();
        _showAlert(
            "Yeey!!", "Data Successfully Deleted", "assets/images/nutmeg.gif");
      }
    }
  }

  Future<void> deleteOrg(id) async {
    final response = await http.post(
      "https://kariernesia.com/jwt/profile/organization/delete/" +
          id.toString() +
          "?token=" +
          _token,
    );
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
        check_connecti();
        _showAlert(
            "Yeey!!", "Data Successfully Deleted", "assets/images/nutmeg.gif");
      }
    }
  }

  Future<void> deleteSkill(id) async {
    final response = await http.post(
      "https://kariernesia.com/jwt/profile/skill/delete/" +
          id.toString() +
          "?token=" +
          _token,
    );
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
        check_connecti();
        _showAlert(
            "Yeey!!", "Data Successfully Deleted", "assets/images/nutmeg.gif");
      }
    }
  }

  Future<void> deleteLang(id) async {
    final response = await http.post(
      "https://kariernesia.com/jwt/profile/lang/delete/" +
          id.toString() +
          "?token=" +
          _token,
    );
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
        check_connecti();
        _showAlert(
            "Yeey!!", "Data Successfully Deleted", "assets/images/nutmeg.gif");
      }
    }
  }

  Future<void> deleteTraining(id) async {
    final response = await http.post(
      "https://kariernesia.com/jwt/profile/training/delete/" +
          id.toString() +
          "?token=" +
          _token,
    );
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
        check_connecti();
        _showAlert(
            "Yeey!!", "Data Successfully Deleted", "assets/images/nutmeg.gif");
      }
    }
  }

  void _showDialogdelete(String type, int id) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Warning"),
          content: new Text("Are you sure want to delete this data ?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text(
                "Delete",
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                if (type == "exp") {
                  deleteExp(id);
                } else if (type == "edu") {
                  deleteEdu(id);
                } else if (type == "org") {
                  deleteOrg(id);
                } else if (type == "skill") {
                  deleteSkill(id);
                } else if (type == "lang") {
                  deleteLang(id);
                } else if (type == "training") {
                  deleteTraining(id);
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _openEdu(BuildContext context) async {
    var result = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (BuildContext context) => new Education(),
          fullscreenDialog: true,
        ));

    var data = jsonDecode(result);
    // print("hasil filter :"+data.toString());
    setState(() {});

    check_connecti();
  }

  void _openWorkEdu(BuildContext context, int id) async {
    var result = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => EducationUpdate(
            id: id,
          ),
          fullscreenDialog: true,
        ));

    var data = jsonDecode(result);
    // print("hasil filter :"+data.toString());
    setState(() {});

    check_connecti();
  }

  void _openTraining(BuildContext context) async {
    var result = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (BuildContext context) => new Training(),
          fullscreenDialog: true,
        ));

    var data = jsonDecode(result);
    // print("hasil filter :"+data.toString());
    setState(() {});

    check_connecti();
  }

  void _openTrainingUpdate(BuildContext context, int id) async {
    var result = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => TrainingUpdate(
            id: id,
          ),
          fullscreenDialog: true,
        ));

    var data = jsonDecode(result);
    // print("hasil filter :"+data.toString());
    setState(() {});

    check_connecti();
  }

  void _openOrg(BuildContext context) async {
    var result = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (BuildContext context) => new Org(),
          fullscreenDialog: true,
        ));

    var data = jsonDecode(result);
    // print("hasil filter :"+data.toString());
    setState(() {});

    check_connecti();
  }

  void _openOrgupdate(BuildContext context, int id) async {
    var result = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => OrgUpdate(
            id: id,
          ),
          fullscreenDialog: true,
        ));

    var data = jsonDecode(result);
    // print("hasil filter :"+data.toString());
    setState(() {});

    check_connecti();
  }

  void _openSkill(BuildContext context) async {
    var result = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (BuildContext context) => new Skill(),
          fullscreenDialog: true,
        ));

    var data = jsonDecode(result);
    // print("hasil filter :"+data.toString());
    setState(() {});

    check_connecti();
  }

  void _openSkillUpdate(BuildContext context, int id) async {
    var result = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => SkillUpdate(
            id: id,
          ),
          fullscreenDialog: true,
        ));

    var data = jsonDecode(result);
    // print("hasil filter :"+data.toString());
    setState(() {});

    check_connecti();
  }

  void _openLanguage(BuildContext context) async {
    var result = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (BuildContext context) => new Language(),
          fullscreenDialog: true,
        ));

    var data = jsonDecode(result);
    // print("hasil filter :"+data.toString());
    setState(() {});

    check_connecti();
  }

  void _openLanguageUpdate(BuildContext context, int id) async {
    var result = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (context) => LanguageUpdate(
            id: id,
          ),
          fullscreenDialog: true,
        ));

    var data = jsonDecode(result);
    // print("hasil filter :"+data.toString());
    setState(() {});

    check_connecti();
  }

  @override
  void initState() {
    // TODO: implement initState
    // super.initState();
    this._loadToken();
    this.check_connecti();
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return new Scaffold(
        key: scaffoldKey,
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
                child: Column(
                  children: <Widget>[
                    clipShape(),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 30, top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Personal Data", style: TextStyle(fontSize: 16)),
                          GestureDetector(
                              onTap: () {
                                // Navigator.of(context).pushNamed(TRENDING_UI);
                                _openPersonal(context);
                              },
                              child: Text(
                                'Edit Data',
                                style: TextStyle(
                                  color: Colors.orange[300],
                                ),
                              ))
                        ],
                      ),
                    ),
                    Divider(),
                    Center(
                      child: Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              child: ButtonBar(
                                children: <Widget>[],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Icon(Icons.assignment_ind),
                                      Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text(dataJson == null
                                            ? " "
                                            : dataJson["name"]),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Icon(Icons.cake),
                                      Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text(dataJson == null
                                            ? " "
                                            : dataJson["seeker"]["data"]
                                                ["birthday"]),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Icon(Icons.wc),
                                      Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text(dataJson == null
                                            ? " "
                                            : dataJson["seeker"]["data"]
                                                ["gender"]),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Icon(Icons.wc),
                                      Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text(dataJson == null
                                            ? " "
                                            : dataJson["seeker"]["data"]
                                                ["relationship"]),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Icon(Icons.flag),
                                      Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text(dataJson == null
                                            ? " "
                                            : dataJson["seeker"]["data"]
                                                ["nationality"]),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Icon(Icons.attach_money),
                                      Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text(dataJson == null
                                            ? " "
                                            : dataJson["seeker"]["data"]
                                                    ["lowest_salary"] +
                                                " - " +
                                                dataJson["seeker"]["data"]
                                                    ["highest_salary"]),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ButtonTheme.bar(
                              // make buttons use the appropriate styles for cards
                              child: ButtonBar(
                                children: <Widget>[],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 30, top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Contact", style: TextStyle(fontSize: 16)),
                          GestureDetector(
                              onTap: () {
                                // Navigator.of(context).pushNamed(TRENDING_UI);
                                _openContact(context);
                              },
                              child: Text(
                                'Edit Data',
                                style: TextStyle(
                                  color: Colors.orange[300],
                                ),
                              ))
                        ],
                      ),
                    ),
                    Divider(),
                    Container(
                      margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                      child: Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              child: ButtonBar(
                                children: <Widget>[],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Icon(Icons.email),
                                      Container(
                                          margin: EdgeInsets.only(left: 10),
                                          child: Text(dataJson == null
                                              ? " "
                                              : dataJson["email"]))
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Icon(Icons.phone),
                                      Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text(dataJson == null
                                            ? " "
                                            : dataJson["seeker"]["data"]
                                                ["phone"]),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Icon(Icons.home),
                                      Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text(dataJson == null
                                            ? " "
                                            : dataJson["seeker"]["data"]
                                                ["address"]),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Icon(Icons.chrome_reader_mode),
                                      Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text(dataJson == null
                                            ? " "
                                            : dataJson["seeker"]["data"]
                                                ["zip_code"]),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ButtonTheme.bar(
                              // make buttons use the appropriate styles for cards
                              child: ButtonBar(
                                children: <Widget>[],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 30, top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("WORK EXPERIENCE",
                              style: TextStyle(fontSize: 16)),
                          GestureDetector(
                              onTap: () {
                                // Navigator.of(context).pushNamed(TRENDING_UI);
                                _openWork(context);
                              },
                              child: Text(
                                'Add Data',
                                style: TextStyle(
                                  color: Colors.orange[300],
                                ),
                              ))
                        ],
                      ),
                    ),
                    Divider(),
                    Container(
                        margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                        child: SingleChildScrollView(
                          child: _exp.length == 0
                              ? cardNUll()
                              : ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.all(5),
                                  shrinkWrap: true,
                                  itemCount: _exp == null ? 0 : _exp.length,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, i) {
                                    return new GestureDetector(
                                      onTap: () {},
                                      child: Card(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            ListTile(
                                              leading: Image(
                                                image: AssetImage(
                                                    "assets/menu/exp.png"),
                                              ),
                                              title: Text(_exp[i]["company"]),
                                              subtitle: Text(
                                                  'Music by Julie Gable. Lyrics by Sidney Stein.'),
                                            ),
                                            ButtonTheme.bar(
                                              // make buttons use the appropriate styles for cards
                                              child: ButtonBar(
                                                children: <Widget>[
                                                  FlatButton(
                                                    child: Row(
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.delete,
                                                          color:
                                                              Colors.redAccent,
                                                        ),
                                                        Text(
                                                          'DELETE',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .redAccent),
                                                        )
                                                      ],
                                                    ),
                                                    onPressed: () {
                                                      _showDialogdelete(
                                                          "exp", _exp[i]["id"]);
                                                    },
                                                  ),
                                                  FlatButton(
                                                    child: Row(
                                                      children: <Widget>[
                                                        Icon(Icons.edit),
                                                        Text(
                                                          'EDIT',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .blueAccent),
                                                        )
                                                      ],
                                                    ),
                                                    onPressed: () {
                                                      /* Edit Work */
                                                      _openWorkupdate(context,
                                                          _exp[i]["id"]);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        )),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 30, top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Education", style: TextStyle(fontSize: 16)),
                          GestureDetector(
                              onTap: () {
                                // Navigator.of(context).pushNamed(TRENDING_UI);
                                _openEdu(context);
                              },
                              child: Text(
                                'Add Data',
                                style: TextStyle(
                                  color: Colors.orange[300],
                                ),
                              ))
                        ],
                      ),
                    ),
                    Divider(),
                    Container(
                        margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                        child: SingleChildScrollView(
                          child: _edu.length == 0
                              ? cardNUll()
                              : ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.all(5),
                                  shrinkWrap: true,
                                  itemCount: _edu == null ? 0 : _edu.length,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, i) {
                                    return new GestureDetector(
                                      onTap: () {},
                                      child: Card(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            ListTile(
                                              leading: Image(
                                                image: AssetImage(
                                                    "assets/menu/edu.png"),
                                              ),
                                              title:
                                                  Text(_edu[i]["school_name"]),
                                              subtitle: Text(
                                                  'Music by Julie Gable. Lyrics by Sidney Stein.'),
                                            ),
                                            ButtonTheme.bar(
                                              // make buttons use the appropriate styles for cards
                                              child: ButtonBar(
                                                children: <Widget>[
                                                  FlatButton(
                                                    child: Row(
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.delete,
                                                          color:
                                                              Colors.redAccent,
                                                        ),
                                                        Text(
                                                          'DELETE',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .redAccent),
                                                        )
                                                      ],
                                                    ),
                                                    onPressed: () {
                                                      _showDialogdelete(
                                                          "edu", _edu[i]["id"]);
                                                    },
                                                  ),
                                                  FlatButton(
                                                    child: Row(
                                                      children: <Widget>[
                                                        Icon(Icons.edit),
                                                        Text(
                                                          'EDIT',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .blueAccent),
                                                        )
                                                      ],
                                                    ),
                                                    onPressed: () {
                                                      _openWorkEdu(context,
                                                          _edu[i]["id"]);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        )),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 30, top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Training / Certification",
                              style: TextStyle(fontSize: 16)),
                          GestureDetector(
                              onTap: () {
                                // Navigator.of(context).pushNamed(TRENDING_UI);
                                _openTraining(context);
                              },
                              child: Text(
                                'Add Data',
                                style: TextStyle(
                                  color: Colors.orange[300],
                                ),
                              ))
                        ],
                      ),
                    ),
                    Divider(),
                    Container(
                        margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                        child: _training.length == 0
                            ? cardNUll()
                            : SingleChildScrollView(
                                child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.all(5),
                                  shrinkWrap: true,
                                  itemCount:
                                      _training == null ? 0 : _training.length,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, i) {
                                    return new GestureDetector(
                                      onTap: () {},
                                      child: Card(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            const ListTile(
                                              leading: Image(
                                                image: AssetImage(
                                                    "assets/menu/cert.png"),
                                              ),
                                              title: Text(
                                                  'The Enchanted Nightingale'),
                                              subtitle: Text(
                                                  'Music by Julie Gable. Lyrics by Sidney Stein.'),
                                            ),
                                            ButtonTheme.bar(
                                              // make buttons use the appropriate styles for cards
                                              child: ButtonBar(
                                                children: <Widget>[
                                                  FlatButton(
                                                    child: Row(
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.delete,
                                                          color:
                                                              Colors.redAccent,
                                                        ),
                                                        Text(
                                                          'DELETE',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .redAccent),
                                                        )
                                                      ],
                                                    ),
                                                    onPressed: () {_showDialogdelete("training", _training[i]["id"]);},
                                                  ),
                                                  FlatButton(
                                                    child: Row(
                                                      children: <Widget>[
                                                        Icon(Icons.edit),
                                                        Text(
                                                          'EDIT',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .blueAccent),
                                                        )
                                                      ],
                                                    ),
                                                    onPressed: () {
                                                      _openTrainingUpdate(
                                                          context,
                                                          _training[i]["id"]);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 30, top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Organization Experiece",
                              style: TextStyle(fontSize: 16)),
                          GestureDetector(
                              onTap: () {
                                // Navigator.of(context).pushNamed(TRENDING_UI);
                                _openOrg(context);
                              },
                              child: Text(
                                'Add Data',
                                style: TextStyle(
                                  color: Colors.orange[300],
                                ),
                              ))
                        ],
                      ),
                    ),
                    Divider(),
                    Container(
                        margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                        child: _org.length == 0
                            ? cardNUll()
                            : SingleChildScrollView(
                                child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.all(5),
                                  shrinkWrap: true,
                                  itemCount: _org == null ? 0 : _org.length,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, i) {
                                    return new GestureDetector(
                                      onTap: () {},
                                      child: Card(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            const ListTile(
                                              leading: Image(
                                                image: AssetImage(
                                                    "assets/menu/org.png"),
                                              ),
                                              title: Text(
                                                  'The Enchanted Nightingale'),
                                              subtitle: Text(
                                                  'Music by Julie Gable. Lyrics by Sidney Stein.'),
                                            ),
                                            ButtonTheme.bar(
                                              // make buttons use the appropriate styles for cards
                                              child: ButtonBar(
                                                children: <Widget>[
                                                  FlatButton(
                                                    child: Row(
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.delete,
                                                          color:
                                                              Colors.redAccent,
                                                        ),
                                                        Text(
                                                          'DELETE',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .redAccent),
                                                        )
                                                      ],
                                                    ),
                                                    onPressed: () {
                                                      _showDialogdelete(
                                                          "org", _org[i]["id"]);
                                                    },
                                                  ),
                                                  FlatButton(
                                                    child: Row(
                                                      children: <Widget>[
                                                        Icon(Icons.edit),
                                                        Text(
                                                          'EDIT',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .blueAccent),
                                                        )
                                                      ],
                                                    ),
                                                    onPressed: () {
                                                      _openOrgupdate(context,
                                                          _org[i]["id"]);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 30, top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Skill", style: TextStyle(fontSize: 16)),
                          GestureDetector(
                              onTap: () {
                                // Navigator.of(context).pushNamed(TRENDING_UI);
                                _openSkill(context);
                              },
                              child: Text(
                                'Add Data',
                                style: TextStyle(
                                  color: Colors.orange[300],
                                ),
                              ))
                        ],
                      ),
                    ),
                    Divider(),
                    Container(
                        margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                        child: _skill.length == 0
                            ? cardNUll()
                            : SingleChildScrollView(
                                child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.all(5),
                                  shrinkWrap: true,
                                  itemCount: _skill == null ? 0 : _skill.length,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, i) {
                                    return new GestureDetector(
                                      onTap: () {},
                                      child: Card(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            const ListTile(
                                              leading: Image(
                                                image: AssetImage(
                                                    "assets/menu/skill.png"),
                                              ),
                                              title: Text(
                                                  'The Enchanted Nightingale'),
                                              subtitle: Text(
                                                  'Music by Julie Gable. Lyrics by Sidney Stein.'),
                                            ),
                                            ButtonTheme.bar(
                                              // make buttons use the appropriate styles for cards
                                              child: ButtonBar(
                                                children: <Widget>[
                                                  FlatButton(
                                                    child: Row(
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.delete,
                                                          color:
                                                              Colors.redAccent,
                                                        ),
                                                        Text(
                                                          'DELETE',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .redAccent),
                                                        )
                                                      ],
                                                    ),
                                                    onPressed: () {
                                                      _showDialogdelete("skill",
                                                          _skill[i]["id"]);
                                                    },
                                                  ),
                                                  FlatButton(
                                                    child: Row(
                                                      children: <Widget>[
                                                        Icon(Icons.edit),
                                                        Text(
                                                          'EDIT',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .blueAccent),
                                                        )
                                                      ],
                                                    ),
                                                    onPressed: () {
                                                      _openSkillUpdate(context,
                                                          _skill[i]["id"]);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )),
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 30, top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Language Skill",
                              style: TextStyle(fontSize: 16)),
                          GestureDetector(
                              onTap: () {
                                // Navigator.of(context).pushNamed(TRENDING_UI);
                                _openLanguage(context);
                              },
                              child: Text(
                                'Add Data',
                                style: TextStyle(
                                  color: Colors.orange[300],
                                ),
                              ))
                        ],
                      ),
                    ),
                    Divider(),
                    Container(
                        margin: EdgeInsets.only(left: 10, right: 10, top: 5),
                        child: _lang.length == 0
                            ? cardNUll()
                            : SingleChildScrollView(
                                child: ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.all(5),
                                  shrinkWrap: true,
                                  itemCount: _lang == null ? 0 : _lang.length,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, i) {
                                    return new GestureDetector(
                                      onTap: () {},
                                      child: Card(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            const ListTile(
                                              leading: Image(
                                                image: AssetImage(
                                                    "assets/menu/lang.png"),
                                              ),
                                              title: Text(
                                                  'The Enchanted Nightingale'),
                                              subtitle: Text(
                                                  'Music by Julie Gable. Lyrics by Sidney Stein.'),
                                            ),
                                            ButtonTheme.bar(
                                              // make buttons use the appropriate styles for cards
                                              child: ButtonBar(
                                                children: <Widget>[
                                                  FlatButton(
                                                    child: Row(
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.delete,
                                                          color:
                                                              Colors.redAccent,
                                                        ),
                                                        Text(
                                                          'DELETE',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .redAccent),
                                                        )
                                                      ],
                                                    ),
                                                    onPressed: () {
                                                      _showDialogdelete("lang",
                                                          _lang[i]["id"]);
                                                    },
                                                  ),
                                                  FlatButton(
                                                    child: Row(
                                                      children: <Widget>[
                                                        Icon(Icons.edit),
                                                        Text(
                                                          'EDIT',
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .blueAccent),
                                                        )
                                                      ],
                                                    ),
                                                    onPressed: () {
                                                      _openLanguageUpdate(
                                                          context,
                                                          _lang[i]["id"]);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )),
                  ],
                ),
              ));
  }

  Widget clipShape() {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 0.5,
          child: ClipPath(
            clipper: CustomShapeClipper2(),
            child: Container(
              height: _height / 3.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[200], Colors.pinkAccent],
                ),
              ),
            ),
          ),
        ),
        Opacity(
          opacity: 0.25,
          child: ClipPath(
            clipper: CustomShapeClipper3(),
            child: Container(
              height: _height / 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange[200], Colors.pinkAccent],
                ),
              ),
            ),
          ),
        ),
        Container(
            margin: EdgeInsets.only(left: 40, right: 40, top: _height / 3.15),
            child: Container(
                child: Center(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin:
                                EdgeInsets.only(left: 45, right: 10, top: 20),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  "Applied",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                      fontSize: _height / 40),
                                ),
                                Container(
                                  height: 15.0,
                                ),
                                Text(
                                  "120",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[300],
                                      fontSize: _height / 40),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin:
                                EdgeInsets.only(left: 20, right: 10, top: 20),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  "Bookmarked",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                      fontSize: _height / 40),
                                ),
                                Container(
                                  height: 15.0,
                                ),
                                Text(
                                  "120",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[300],
                                      fontSize: _height / 40),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ButtonTheme.bar(
                      // make buttons use the appropriate styles for cards
                      child: ButtonBar(
                        children: <Widget>[],
                      ),
                    ),
                  ],
                ),
              ),
            ))),
        Container(
            // color: Colors.blue,
            margin: EdgeInsets.only(left: 20, right: 20, top: _height / 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Opacity(
                  opacity: 0.8,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back,
                        )),
                  ),
                ),
                // Opacity(
                //   opacity: 0.5,
                //   child: GestureDetector(
                //       onTap: () {},
                //       child: Icon(
                //         Icons.notifications,
                //         color: Colors.black,
                //         size: _height / 30,
                //       )),
                // ),
              ],
            )),
        Container(
          margin: EdgeInsets.only(
            left: _width / 3.5,
            right: 20,
            top: _height / 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  print("Profile has tapped");
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: Container(
                            height: _height / 3,
                            child: Form(
                              child: Column(
                                children: <Widget>[
                                  FlatButton(
                                    child: Row(
                                      children: <Widget>[
                                        Icon(Icons.image),
                                        Text(" Take photo from gallery")
                                      ],
                                    ),
                                    onPressed: getImageGallery,
                                  ),
                                  FlatButton(
                                    child: Row(
                                      children: <Widget>[
                                        Icon(Icons.camera_alt),
                                        Text(" Take photo from camera")
                                      ],
                                    ),
                                    onPressed: getImageCamera,
                                  ),
                                  // Padding(
                                  //   padding: EdgeInsets.all(8.0),
                                  //   child: TextFormField(),
                                  // ),
                                  // Padding(
                                  //   padding: EdgeInsets.all(8.0),
                                  //   child: TextFormField(),
                                  // ),
                                  Expanded(
                                    child: Container(),
                                  ),
                                  Container(
                                    child: _isLoading
                                        ? CircularProgressIndicator(
                                            backgroundColor:
                                                Colors.orangeAccent,
                                            valueColor: AlwaysStoppedAnimation(
                                                Colors.white),
                                          )
                                        : RaisedButton(
                                            color: Colors.orangeAccent,
                                            onPressed: () {
                                              upload(_image);
                                            },
                                            child: Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.file_upload,
                                                  color: Colors.white,
                                                ),
                                                Text(
                                                  " Upload Ava",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )
                                              ],
                                            ),
                                          ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                },
                child: Container(
                  width: 150.0,
                  height: 150.0,
                  decoration: BoxDecoration(
                      color: Colors.orange[200],
                      image: DecorationImage(
                          image: _image == null
                              ? NetworkImage(dataJson == null
                                  ? " "
                                  : dataJson["source"]["ava"])
                              : FileImage(_image),
                          fit: BoxFit.cover),
                      borderRadius: BorderRadius.all(Radius.circular(75.0)),
                      boxShadow: [
                        BoxShadow(blurRadius: 7.0, color: Colors.black)
                      ]),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Text(dataJson == null ? " " : dataJson["name"],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        fontSize: _height / 40)),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget cardNUll() {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
            child: Image.asset(
              "assets/images/empty_data.png",
              height: 150.0,
              width: 300.0,
            ),
          ),
          Center(
            child: Text("Your data is empty",
                style:
                    TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ButtonTheme.bar(
            // make buttons use the appropriate styles for cards
            child: ButtonBar(
              children: <Widget>[],
            ),
          ),
        ],
      ),
    );
  }
}
