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

class Work extends StatefulWidget {
  @override
  _WorkState createState() => _WorkState();
}

class _WorkState extends State<Work> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final myformat = DateFormat("yyyy-MM-dd");
  DateTime selectedDate = DateTime.now();
  DateTime selectedDatetill = DateTime.now();

  TextEditingController _jobController = new TextEditingController();
  TextEditingController _startcontroller = new TextEditingController();
  TextEditingController _tillcontroller = new TextEditingController();
  TextEditingController _reportController = new TextEditingController();
  TextEditingController _companyController = new TextEditingController();
  TextEditingController _jobDescController = new TextEditingController();

  Map<String, dynamic> formData;
  List dataNations;
  List dataJoblevel;
  List dataFungsi;
  List dataindustri;
  List dataSalary;
  List dataJobtype;
  List dataCities;

  String _text = "";
  String _joblevel;
  String _jobtype;
  String _fungsikerja;
  String _token;
  String _industri;
  String _city;
  String _salary;
  DateTime start;
  bool isLoading = true;

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

  Future<List> _save() async {
    setState(() {
      isLoading = true;
    });
    var data = jsonEncode({
      "job_title": _jobController.text == null ? "" : _jobController.text,
      "joblevel_id": _joblevel,
      "company": _companyController.text == null ? "" : _companyController.text,
      "fungsikerja_id": _fungsikerja,
      "industri_id": _industri,
      "city_id": _city,
      "salary_id": _salary,
      "start_date": _startcontroller.text == null ? "" : _startcontroller.text,
      "end_date": _tillcontroller.text == null ? "" : _tillcontroller.text,
      "jobtype_id": _jobtype,
      "report_to": _reportController.text == null ? "" : _reportController.text,
      "job_desc": _jobDescController.text == null ? "" : _jobDescController.text
    });

    final response = await http.post(
        "https://kariernesia.com/jwt/profile/exp/save?token=" + _token,
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

  Future<String> getJobfunc() async {
    /**
     * Fetch Data from Uri
     */
    try {
      http.Response item = await http.get(
          Uri.encodeFull("https://kariernesia.com/api/clients/jobfunction"),
          headers: {"Accept": "application/json"});

      this.setState(() {
        dataFungsi = jsonDecode(item.body);
      });
      print("success");
    } catch (e) {
      print(e);
    }
  }

  Future<String> getIndus() async {
    /**
     * Fetch Data from Uri
     */
    try {
      http.Response item = await http.get(
          Uri.encodeFull("https://kariernesia.com/api/clients/industries"),
          headers: {"Accept": "application/json"});

      this.setState(() {
        dataindustri = jsonDecode(item.body);
      });
      print("success");
    } catch (e) {
      print(e);
    }
  }

  Future<String> getCities() async {
    /**
     * Fetch Data from Uri
     */
    try {
      http.Response item = await http.get(
          Uri.encodeFull("https://kariernesia.com/api/clients/cities"),
          headers: {"Accept": "application/json"});

      this.setState(() {
        dataCities = jsonDecode(item.body);
      });
      print("success");
    } catch (e) {
      print(e);
    }
  }

  Future<String> getSalaries() async {
    /**
     * Fetch Data from Uri
     */
    try {
      http.Response item = await http.get(
          Uri.encodeFull("https://kariernesia.com/api/clients/salaries"),
          headers: {"Accept": "application/json"});

      this.setState(() {
        dataSalary = jsonDecode(item.body);
      });
      print("success");
    } catch (e) {
      print(e);
    }
  }

  Future<String> getJoblevel() async {
    /**
     * Fetch Data from Uri
     */
    try {
      http.Response item = await http.get(
          Uri.encodeFull("https://kariernesia.com/api/clients/joblevel"),
          headers: {"Accept": "application/json"});

      this.setState(() {
        dataJoblevel = jsonDecode(item.body);
      });
      print("success");
    } catch (e) {
      print(e);
    }
  }

  Future<String> getJobtype() async {
    /**
     * Fetch Data from Uri
     */
    try {
      http.Response item = await http.get(
          Uri.encodeFull("https://kariernesia.com/api/clients/jobtype"),
          headers: {"Accept": "application/json"});

      this.setState(() {
        dataJobtype = jsonDecode(item.body);
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
        await this.getJobfunc();
        await this.getIndus();
        await this.getCities();
        await this.getSalaries();
        await this.getJoblevel();
        await this.getJobtype();
        new Future.delayed(Duration(seconds: 2), () {
          setState(() {
            isLoading = false;
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
        _startcontroller.text = myformat.format(selectedDate);
      });
  }

  Future<Null> _selectDateTill(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDatetill,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDatetill)
      setState(() {
        selectedDatetill = picked;
        _tillcontroller.text = myformat.format(selectedDatetill);
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
                Navigator.pop(context, jsonEncode({"load": false})),
          ),
          backgroundColor: Colors.white,
          title: const Text(
            'Add Work Experience',
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
                            controller: _jobController,
                            // obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Job Title',
                            ),
                          ),
                        ),
                      ),
                      
                      Container(
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: 20.0, left: 25.0, right: 25.0),
                          child: TextField(
                            controller: _companyController,
                            // obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Company Name',
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: 20.0, left: 25.0, right: 25.0),
                          child: TextField(
                            controller: _reportController,
                            // obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Report To',
                            ),
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
                                    controller: _startcontroller,
                                    decoration: new InputDecoration(
                                      hintText: selectedDate.toString(),
                                      border: OutlineInputBorder(),
                                      labelText: "Work From",
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
                        padding: EdgeInsets.only(
                            bottom: 20.0, left: 25.0, right: 25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  _selectDateTill(
                                      context); // Call Function that has showDatePicker()
                                },
                                child: IgnorePointer(
                                  child: new TextFormField(
                                    controller: _tillcontroller,
                                    decoration: new InputDecoration(
                                      hintText: _selectDateTill.toString(),
                                      border: OutlineInputBorder(),
                                      labelText: "Work Till",
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
                        child: dataSalary == null
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
                                hint: Text("Select Salary"),
                                elevation: 3,
                                items: dataSalary?.map((item) {
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
                                    _salary = newVal;
                                  });
                                },
                                value: _salary,
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
                        child: dataFungsi == null
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
                                hint: Text("Select Job Function"),
                                elevation: 3,
                                items: dataFungsi?.map((item) {
                                      return new DropdownMenuItem(
                                        value: item['id'].toString(),
                                        child: new Text(
                                          item['nama'],
                                          style: new TextStyle(fontSize: 16.0),
                                        ),
                                      );
                                    })?.toList() ??
                                    [],
                                onChanged: (newVal) {
                                  setState(() {
                                    _fungsikerja = newVal;
                                  });
                                },
                                value: _fungsikerja,
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
                        child: dataJoblevel == null
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
                                hint: Text("Select Job Level"),
                                elevation: 3,
                                items: dataJoblevel?.map((item) {
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
                                    _joblevel = newVal;
                                  });
                                },
                                value: _joblevel,
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
                        child: dataindustri == null
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
                                hint: Text("Select Industri"),
                                elevation: 3,
                                items: dataindustri?.map((item) {
                                      return new DropdownMenuItem(
                                        value: item['id'].toString(),
                                        child: new Text(
                                          item['nama'],
                                          style: new TextStyle(fontSize: 16.0),
                                        ),
                                      );
                                    })?.toList() ??
                                    [],
                                onChanged: (newVal) {
                                  setState(() {
                                    _industri = newVal;
                                  });
                                },
                                value: _industri,
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
                        child: dataCities == null
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
                                hint: Text("Select City"),
                                elevation: 3,
                                isExpanded: true,
                                items: dataCities?.map((item) {
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
                                    _city = newVal;
                                  });
                                },
                                value: _city,
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
                        child: dataJobtype == null
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
                                hint: Text("Select Job Type"),
                                elevation: 3,
                                items: dataJobtype?.map((item) {
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
                                    _jobtype = newVal;
                                  });
                                },
                                value: _jobtype,
                              ),
                      ),
                      Container(
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: 20.0, left: 25.0, right: 25.0),
                          child: TextField(
                            maxLines: null,
                            controller: _jobDescController,
                            // obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Job Description',
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
