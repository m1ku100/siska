import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:dropdownfield/dropdownfield.dart';

class Skill extends StatefulWidget {
  @override
  _SkillState createState() => _SkillState();
}

class _SkillState extends State<Skill> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = GlobalKey<FormState>();
  final myformat = DateFormat("yyyy-MM-dd");
  DateTime selectedDate = DateTime.now();

  TextEditingController _controller = new TextEditingController();
  TextEditingController _startcontroller = new TextEditingController();
  TextEditingController _tillcontroller = new TextEditingController();
  
  Map<String, dynamic> formData;
  List dataSalary;
  List dataJobfunc;
  List dataIndus;
  List dataDegree;
  List dataCities;
  List dataSalaries;

  String _text = "";
  String _mySelection;
  String _indus;
  String _jobfunc;
  String _degree;
  String _salary;
  DateTime start;
  var data;

  Future<String> getSalary() async {
    /**
     * Fetch Data from Uri
     */
    try {
      http.Response item = await http.get(
          Uri.encodeFull("https://kariernesia.com/api/clients/vacancies/get/"),
          headers: {"Accept": "application/json"});

      this.setState(() {
        dataSalary = jsonDecode(item.body);
      });
      print("success");
    } catch (e) {
      print(e);
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
        dataJobfunc = jsonDecode(item.body);
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
        dataIndus = jsonDecode(item.body);
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
        dataSalaries = jsonDecode(item.body);
      });
      print("success");
    } catch (e) {
      print(e);
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
      });
  }

  void check_connecti() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        this.getJobfunc();
        await this.getIndus();
        await this.getDegree();
        await this.getCities();
        await this.getSalaries();
      }
    } on SocketException catch (_) {
      _showAlert("You'are not connected");
    }
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
    this.check_connecti();
  }

  void _saveText() {
    var data = jsonEncode({
      "q": _controller.text ==null? "": _controller.text,
      "agen": "",
      "loc": _mySelection == null ? "" : _mySelection,
      "salary_ids": _salary == null ? "" : _salary,
      "jobfunc_ids": _jobfunc == null ? "":_jobfunc,
      "industry_ids": _indus == null ? "" : _indus,
      "degree_ids": _degree == null ? "" : _degree,
      "major_ids": ""
    });

    // setState(() {
    //   data = jsonEncode({"a": _controller.text, "b": "ini B"});
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
            onPressed: () => Navigator.pop(
              context,
              _controller.text,
            ),
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
                        labelText: 'Job Title',
                      ),
                    ),
                  ),
                ),
                // Container(
                //   child: Center(
                //     child: Text(_controller.text == ""
                //         ? "Recruitment Date"
                //         : _controller.text.toUpperCase() +
                //             '\'s Recruitment Date'),
                //   ),
                // ),
                // Container(
                //   padding:
                //       EdgeInsets.only(bottom: 20.0, left: 25.0, right: 25.0),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                //     children: <Widget>[
                //       Expanded(
                //         child: InkWell(
                //           onTap: () {
                //             _selectDate(
                //                 context); // Call Function that has showDatePicker()
                //           },
                //           child: IgnorePointer(
                //             child: new TextFormField(
                //               controller: _startcontroller,
                //               decoration: new InputDecoration(
                //                 hintText: selectedDate.toString(),
                //                 border: OutlineInputBorder(),
                //                 labelText: "${myformat.format(selectedDate)}",
                //               ),
                //               onSaved: (String val) {},
                //             ),
                //           ),
                //         ),
                //       ),
                //       Container(
                //         width: 10.0,
                //       ),
                //       Expanded(
                //         child: InkWell(
                //           onTap: () {
                //             _selectDate(
                //                 context); // Call Function that has showDatePicker()
                //           },
                //           child: IgnorePointer(
                //             child: new TextFormField(
                //               controller: _tillcontroller,
                //               decoration: new InputDecoration(
                //                 hintText: selectedDate.toString(),
                //                 border: OutlineInputBorder(),
                //                 labelText: "${myformat.format(selectedDate)}",
                //               ),
                //               onSaved: (String val) {},
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // Container(
                //   child: Text('Basic date & time field (${start})'),
                // ),
                // Container(
                //   child: Center(
                //     child: Text(selectedDate.toString()),
                //   ),
                // ),
                Container(
                  width: 345.0,
                  margin:
                      EdgeInsets.only(bottom: 20.0, left: 25.0, right: 25.0),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  child: dataSalaries == null
                      ? Column(
                          children: <Widget>[
                            new CircularProgressIndicator(
                              backgroundColor: Colors.white,
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.orange),
                            ),
                            new Text("Loading"),
                          ],
                        )
                      : new DropdownButton(
                          hint: Text("Select Salary"),
                          elevation: 3,
                          items: dataSalaries?.map((item) {
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
                  margin:
                      EdgeInsets.only(bottom: 20.0, left: 25.0, right: 25.0),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  child: dataCities == null
                      ? Column(
                          children: <Widget>[
                            new CircularProgressIndicator(
                              backgroundColor: Colors.white,
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.orange),
                            ),
                            new Text("Loading"),
                          ],
                        )
                      : new DropdownButton(
                          hint: Text("Select Location"),
                          elevation: 3,
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
                              _mySelection = newVal;
                            });
                          },
                          value: _mySelection,
                        ),
                ),
                Container(
                  width: 345.0,
                  margin:
                      EdgeInsets.only(bottom: 20.0, left: 25.0, right: 25.0),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  child: dataJobfunc == null
                      ? Column(
                          children: <Widget>[
                            new CircularProgressIndicator(
                              backgroundColor: Colors.white,
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.orange),
                            ),
                            new Text("Loading"),
                          ],
                        )
                      : new DropdownButton(
                          hint: Text("Select Job Fuction"),
                          elevation: 3,
                          items: dataJobfunc?.map((item) {
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
                              _jobfunc = newVal;
                            });
                          },
                          value: _jobfunc,
                        ),
                ),
                Container(
                  width: 345.0,
                  margin:
                      EdgeInsets.only(bottom: 20.0, left: 25.0, right: 25.0),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  child: dataIndus == null
                      ? Column(
                          children: <Widget>[
                            new CircularProgressIndicator(
                              backgroundColor: Colors.white,
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.orange),
                            ),
                            new Text("Loading"),
                          ],
                        )
                      : new DropdownButton(
                          hint: Text("Select Industry"),
                          elevation: 3,
                          items: dataIndus?.map((item) {
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
                              _indus = newVal;
                            });
                          },
                          value: _indus,
                        ),
                ),
                Container(
                  width: 345.0,
                  margin:
                      EdgeInsets.only(bottom: 20.0, left: 25.0, right: 25.0),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    ),
                  ),
                  child: dataDegree == null
                      ? Column(
                          children: <Widget>[
                            new CircularProgressIndicator(
                              backgroundColor: Colors.white,
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  Colors.orange),
                            ),
                            new Text("Loading"),
                          ],
                        )
                      : new DropdownButton(
                          hint: Text("Select Industry"),
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
                              _degree = newVal;
                            });
                          },
                          value: _degree,
                        ),
                ),
                Container(
                  child: Column(
                    children: <Widget>[
                      Text(_controller.text),
                      Text(_mySelection == null
                          ? "Kosong"
                          : "cities " + _mySelection),
                      Text(_indus == null
                          ? " industri kosong"
                          : "industri " + _indus),
                      Text(_jobfunc == null
                          ? " industri kosong"
                          : "job  " + _jobfunc),
                      Text(_degree == null
                          ? " industri kosong"
                          : "degree  " + _degree),
                    ],
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
