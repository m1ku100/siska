import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:dropdownfield/dropdownfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EducationUpdate extends StatefulWidget {
  final int id;
  EducationUpdate({Key key, @required this.id}) : super(key: key);
  @override
  _EducationUpdateState createState() => _EducationUpdateState(id);
}

class _EducationUpdateState extends State<EducationUpdate> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final myformat = DateFormat("yyyy-MM-dd");
  DateTime selectedDate = DateTime.now();

  TextEditingController _awardContrller = new TextEditingController();
  TextEditingController _schoolController = new TextEditingController();
  TextEditingController _startController = new TextEditingController();
  TextEditingController _endController = new TextEditingController();
  TextEditingController _nilaiController = new TextEditingController();

    int id;
  _EducationUpdateState(this.id);


  Map<String, dynamic> formData;
  List dataDegree;
  List dataJurusan;
  var dataEdu;

  String _tingkat;
  String _jurusan;
  String _token;
  bool isLoading = true;
  var data;

  Future<String> getUser() async {
    /**
     * Fetch Data from Uri
     */
    try {
      http.Response item = await http.get(
          Uri.encodeFull(
              "https://kariernesia.com/jwt/profile/edu/" + id.toString()),
          headers: {"Accept": "application/json"});

      this.setState(() {
        dataEdu = jsonDecode(item.body);
      });
      print("success get user");
    } catch (e) {
      print(e);
    }
  }

  Future<String> getjurusan() async {
    /**
     * Fetch Data from Uri
     */
    try {
      http.Response item = await http.get(
          Uri.encodeFull("https://kariernesia.com/api/clients/major"),
          headers: {"Accept": "application/json"});

      this.setState(() {
        dataJurusan = jsonDecode(item.body);
      });
      print("success");
    } catch (e) {
      print(e);
    }
  }

  Future<String> getDegree() async {
    /**
     * Fetch Data from Uri
     */
    try {
      http.Response item = await http.get(
          Uri.encodeFull("https://kariernesia.com/api/clients/degree"),
          headers: {"Accept": "application/json"});

      this.setState(() {
        dataDegree = jsonDecode(item.body);
      });
      print("success");
    } catch (e) {
      print(e);
    }
  }

  void check_connecti() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        this.getUser();
        await this.getDegree();
        await this.getjurusan();
        new Future.delayed(Duration(seconds: 2), () {
          setState(() {
            isLoading = false;
            _awardContrller.text = dataEdu["awards"];
            _schoolController.text = dataEdu["school_name"];
            _startController.text = dataEdu["start_period"];
            _endController.text = dataEdu["end_period"];
            _nilaiController.text = dataEdu["nilai"];
            _tingkat = dataEdu["tingkatpend_id"];
            _jurusan = dataEdu["jurusanpend_id"];
          });
        });
      }
    } on SocketException catch (_) {
      _showAlert(
          'Oops!!', 'Your not connected', '"assets/images/no_connection.gif"');
    }
  }

  Future<List> _save() async {
    setState(() {
      isLoading = true;
    });
    var data = jsonEncode({
      "id" : id,
      "tingkatpend_id": _tingkat == null ? "" : _tingkat,
      "jurusanpend_id": _jurusan == null ? "" : _jurusan,
      "awards": _awardContrller.text == null ? "" : _awardContrller.text,
      "school_name":
          _schoolController.text == null ? "" : _schoolController.text,
      "start_period":
          _startController.text == null ? "" : _startController.text,
      "end_period": _endController.text == null ? "" : _endController.text,
      "nilai": _nilaiController.text == null ? "" : _nilaiController.text,
    });

    final response = await http.post(
        "https://kariernesia.com/jwt/profile/edu/update?token=" + _token,
        body: data);

    var datauser = json.decode(response.body);

    if (datauser.length == 0) {
      setState(() {});
    } else {
      if (datauser['success'] == false) {
        setState(() {
          isLoading = false;
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
                  Navigator.pop(context, jsonEncode({"load": false}))),
          backgroundColor: Colors.white,
          title: const Text(
            'Update Data Education',
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
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
                          child: TextField(
                            controller: _schoolController,
                            // obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'School Name',
                            ),
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
                        child: dataDegree == null
                            ? Column(
                                children: <Widget>[
                                  new CircularProgressIndicator(
                                    backgroundColor: Colors.white,
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            Colors.orange),
                                  ),
                                  new Text("Loading"),
                                ],
                              )
                            : new DropdownButton(
                                hint: Text("Select Degree"),
                                elevation: 3,
                                items: dataDegree?.map((item) {
                                      return new DropdownMenuItem(
                                        value: item['id'].toString(),
                                        child: new Text(
                                          item['name'],
                                          style: new TextStyle(fontSize: 16.0),
                                        ),
                                      );
                                    })?.toList() ??
                                    [],
                                onChanged: (newVal) {
                                  setState(() {
                                    _tingkat = newVal;
                                  });
                                },
                                value: _tingkat,
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
                        child: dataJurusan == null
                            ? Column(
                                children: <Widget>[
                                  new CircularProgressIndicator(
                                    backgroundColor: Colors.white,
                                    valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                            Colors.orange),
                                  ),
                                  new Text("Loading"),
                                ],
                              )
                            : new DropdownButton(
                                hint: Text("Select Major"),
                                elevation: 3,
                                items: dataJurusan?.map((item) {
                                      return new DropdownMenuItem(
                                        value: item['id'].toString(),
                                        child: new Text(
                                          item['name'],
                                          style: new TextStyle(fontSize: 16.0),
                                        ),
                                      );
                                    })?.toList() ??
                                    [],
                                onChanged: (newVal) {
                                  setState(() {
                                    _jurusan = newVal;
                                  });
                                },
                                value: _jurusan,
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
                                    controller: _startController,
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
                                    controller: _endController,
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
                          padding: EdgeInsets.only(
                              bottom: 20.0, left: 25.0, right: 25.0),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: _nilaiController,
                            // obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Grade Point Average (GPA)',
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: 20.0, left: 25.0, right: 25.0),
                          child: TextField(
                            maxLines: null,
                            controller: _awardContrller,
                            // obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Your award had achieved',
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
