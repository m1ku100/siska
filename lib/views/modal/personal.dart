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

class Personal extends StatefulWidget {
  @override
  _PersonalState createState() => _PersonalState();
}

enum GenderType { male, female }

class _PersonalState extends State<Personal> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final myformat = DateFormat("yyyy-MM-dd");
  DateTime selectedDate = DateTime.now();

  TextEditingController _nameController = new TextEditingController();
  TextEditingController _startcontroller = new TextEditingController();
  TextEditingController _startSalary = new TextEditingController();
  TextEditingController _tillSalary = new TextEditingController();

  Map<String, dynamic> formData;
  List dataNations;

  String _text = "";
  String _mySelection;
  String _nations;
  String _token;
  String _gender;
  DateTime start;
  bool isLoading = true;
  GenderType _genderType = GenderType.male;

  var gender = ["male", "female", "rahter not say"];

  var data;
  var dataUser;

  Future<String> getUser() async {
    /**
     * Fetch Data from Uri
     */
    try {
      http.Response item = await http.get(
          Uri.encodeFull(
              "https://kariernesia.com/jwt/profile/me?token=" + _token),
          headers: {"Accept": "application/json"});

      this.setState(() {
        dataUser = jsonDecode(item.body);
      });
      print("get user success");
    } catch (e) {
      print(e);
    }
  }

  Future<String> getNations() async {
    /**
     * Fetch Data from Uri
     */
    try {
      http.Response item = await http.get(
          Uri.encodeFull("https://kariernesia.com/api/clients/nations"),
          headers: {"Accept": "application/json"});

      this.setState(() {
        dataNations = jsonDecode(item.body);
      });
      print("get nations success");
    } catch (e) {
      print(e);
    }
  }

  Future<List> _save() async {
    setState(() {
      isLoading = true;
    });
    var data = jsonEncode({
      "name": _nameController.text,
      "birthday": _startcontroller.text,
      "gender": _gender,
      "relationship": "",
      "nationality": _nations,
      "lowest_salary": _startSalary.text,
      "highest_salary": _tillSalary.text,
    });

    final response = await http.post(
        "https://kariernesia.com/jwt/profile/personal/save?token=" + _token,
        body: data);

    var datauser = json.decode(response.body);

    if (datauser.length == 0) {
      setState(() {});
    } else {
      if (datauser['success'] == false) {
        setState(() {
          isLoading = false;
        });
      } else if (datauser['success'] == true) {
        Navigator.pop(context, jsonEncode({"load": true}));
      }
    }
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
        _startcontroller.text = myformat.format(selectedDate);
      });
  }

  void check_connecti() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        this.getUser();
        await this.getNations();
        new Future.delayed(Duration(seconds: 2), () {
          setState(() {
            isLoading = false;
            _nameController.text = dataUser["name"];
            _startcontroller.text = dataUser["seeker"]["data"]["birthday"];
            _gender = dataUser["seeker"]["data"]["gender"];
            _startSalary.text = dataUser["seeker"]["data"]["lowest_salary"];
            _tillSalary.text = dataUser["seeker"]["data"]["highest_salary"];
            _nations = dataUser["seeker"]["data"]["nationality"];
          });
        });
      }
    } on SocketException catch (_) {
      _showAlert("You'are not connected");
    }
  }

  _loadToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      _token = (preferences.getString("token") ?? "");
    });
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
    super.initState();
    this._loadToken();
    this.check_connecti();
  }

  void _saveText() {
    var data = jsonEncode({
      // "q": _nameController.text ==null? "": _nameController.text,
      // "agen": "",
      // "loc": _mySelection == null ? "" : _mySelection,
      // "salary_ids": _salary == null ? "" : _salary,
      // "jobfunc_ids": _jobfunc == null ? "":_jobfunc,
      // "industry_ids": _indus == null ? "" : _indus,
      // "degree_ids": _degree == null ? "" : _degree,
      // "major_ids": "",
      // "load" : true
    });

    // setState(() {
    //   data = jsonEncode({"a": _nameController.text, "b": "ini B"});
    // });
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
            onPressed: () =>
                Navigator.pop(context, jsonEncode({"load": false})),
          ),
          backgroundColor: Colors.white,
          title: const Text(
            'Edit Data Personal',
            style: TextStyle(color: Colors.orangeAccent),
          ),
          actions: [
            new FlatButton(
                onPressed: () {
                  //TODO: Handle save
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
                            controller: _nameController,
                            // obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Full Name',
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
                        child: new DropdownButton(
                          hint: Text("Select Nationality"),
                          isExpanded: true,
                          elevation: 3,
                          items: gender?.map((item) {
                                return new DropdownMenuItem(
                                  value: item,
                                  child: new Text(
                                    item  ,
                                    style: new TextStyle(fontSize: 16.0),
                                  ),
                                );
                              })?.toList() ??
                              [],
                          onChanged: (newVal) {
                            setState(() {
                              _gender = newVal;
                            });
                          },
                          value: _gender,
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
                                    controller: _startcontroller,
                                    decoration: new InputDecoration(
                                      hintText: selectedDate.toString(),
                                      border: OutlineInputBorder(),
                                      labelText: "Date of Birth",
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
                        child: dataNations == null
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
                                hint: Text("Select Nationality"),
                                isExpanded: true,
                                elevation: 3,
                                items: dataNations?.map((item) {
                                      return new DropdownMenuItem(
                                        value: item['name'].toString(),
                                        child: new Text(
                                          item['name'],
                                          style: new TextStyle(fontSize: 16.0),
                                        ),
                                      );
                                    })?.toList() ??
                                    [],
                                onChanged: (newVal) {
                                  setState(() {
                                    _nations = newVal;
                                  });
                                },
                                value: _nations,
                              ),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            bottom: 20.0, left: 25.0, right: 25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: _startSalary,
                                keyboardType: TextInputType.number,
                                // obscureText: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Expected Salary From',
                                ),
                              ),
                            ),
                            Container(
                              width: 10.0,
                            ),
                            Expanded(
                              child: TextField(
                                controller: _tillSalary,
                                keyboardType: TextInputType.number,
                                // obscureText: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Expected Salary Till',
                                ),
                              ),
                            ),
                          ],
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
