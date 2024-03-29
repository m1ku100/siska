import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:siska/constant/Constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplyDetail extends StatefulWidget {
  final String id;
  ApplyDetail({Key key, @required this.id}) : super(key: key);
  @override
  _ApplyDetailState createState() => _ApplyDetailState(id);
}

class _ApplyDetailState extends State<ApplyDetail> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var dataJson;

  final bool horizontal = true;
  double _height;
  double _width;
  String id;
  String _token, _msg;
  _ApplyDetailState(this.id);

  List dataFavorite;

  bool isLoading = true;
  bool isBookmarked = false;
  bool isApplied = false;

  Future<String> getData() async {
    /**
     * Fetch Data from Uri
     */
    try {
      http.Response item = await http.get(
          Uri.encodeFull("https://kariernesia.com/jwt/vacancy/" +
              id +
              "/detail?token=" +
              _token),
          headers: {"Accept": "application/json"});

      this.setState(() {
        dataJson = json.decode(item.body);
      });
      print("success");
    } catch (e) {
      print(e);
    }
  }

  Future<String> getFavorite() async {
    try {
      http.Response item = await http.get(
          Uri.encodeFull(BASE_URL + "clients/vacancies/favorite"),
          headers: {"Accept": "application/json"});

      this.setState(() {
        dataFavorite = jsonDecode(item.body);
      });
      print("Success Favorite");
    } catch (e) {
      print(e);
    }
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Attention"),
          content: new Text("Are you sure want to abort this application ?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text(
                "Abort",
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _abort();
              },
            ),
          ],
        );
      },
    );
  }

  Future<List> _abort() async {
    var data = jsonEncode({
      "vacancy_id": dataJson["id"],
    });

    final response = await http.post(
        "https://kariernesia.com/jwt/vacancy/abort?token=" + _token,
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
        // _showAlert("Yeey!!", dataChange['message'], "assets/images/nutmeg.gif");
        Navigator.pop(context, jsonEncode({"load": true}));
      }
    }
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
        this.getData();
        await this.getFavorite();
        new Future.delayed(Duration(seconds: 2), () {
          setState(() {
            isBookmarked = dataJson["bookmark"];
            isApplied = dataJson["apply"];
            isLoading = false;
          });
        });
      }
    } on SocketException catch (_) {
      _showAlert_connect("You'are not connected");
    }
  }

  Future<List> _apply() async {
    var data = jsonEncode({
      "vacancy_id": dataJson["id"],
    });

    final response = await http.post(
        "https://kariernesia.com/jwt/vacancy/applying?token=" + _token,
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
          isApplied = true;
        });
      }
    }
  }

  Future<List> _bookmark() async {
    var data = jsonEncode({
      "vacancy_id": dataJson["id"],
    });

    final response = await http.post(
        "https://kariernesia.com/jwt/vacancy/bookmarking?token=" + _token,
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
          isBookmarked = true;
        });
      }
    }
  }

  void _showSnackbar(String str) {
    if (str.isEmpty) return;

    scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(str),
      duration: new Duration(seconds: 2),
    ));
  }

  void _showAlert_connect(String str) {
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

  @override
  void initState() {
    // TODO: implement initState
    this._loadToken();
    this.check_connecti();
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return new WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.orange[200],
              leading: new IconButton(
                icon: new Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () =>
                    Navigator.pop(context, jsonEncode({"load": false})),
              ),
              title: Text("Application Detail"),
            ),
            body: isLoading
                ? Container(
                    padding: EdgeInsets.only(top: 300),
                    child: Center(
                      child: Column(
                        children: <Widget>[
                          CircularProgressIndicator(
                            backgroundColor: Colors.white,
                            valueColor: new AlwaysStoppedAnimation<Color>(
                                Colors.orange),
                          ),
                          Text("Loading")
                        ],
                      ),
                    ))
                : SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                    child: Column(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Row(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              width: 100.0,
                              height: 100.0,
                              decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: new DecorationImage(
                                      fit: BoxFit.fill,
                                      image: new NetworkImage(dataJson == null
                                          ? " "
                                          : dataJson["user"]["ava"]))),
                            ),
                            Container(
                                child: Column(
                              children: <Widget>[
                                SizedBox(
                                  width: 200.0,
                                  child: AutoSizeText(
                                    dataJson == null ? " " : dataJson["judul"],
                                    style: TextStyle(fontSize: 30.0),
                                    maxLines: 2,
                                  ),
                                ),
                                ButtonBar(
                                  children: <Widget>[
                                    isApplied
                                        ? RaisedButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        30.0)),
                                            color: Colors.redAccent,
                                            child: Row(
                                              children: <Widget>[
                                                Text(
                                                  'Abort  ',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                // Expanded(
                                                //   child: Container(

                                                //   ),
                                                // ),
                                                Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                            onPressed: () {
                                               _showDialog();
                                            },
                                          )
                                        : RaisedButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        30.0)),
                                            color: Colors.orangeAccent,
                                            child: Row(
                                              children: <Widget>[
                                                Text(
                                                  'Apply  ',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                                // Expanded(
                                                //   child: Container(

                                                //   ),
                                                // ),
                                                Icon(
                                                  Icons.send,
                                                  color: Colors.white,
                                                ),
                                              ],
                                            ),
                                            onPressed: () {
                                              _apply();
                                            },
                                          ),
                                    isBookmarked
                                        ? RaisedButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        30.0)),
                                            color: Colors.white,
                                            child: Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.bookmark,
                                                  color: Colors.orangeAccent,
                                                ),
                                                Text(
                                                  ' Bookmarked',
                                                  style: TextStyle(
                                                      color:
                                                          Colors.orangeAccent),
                                                )
                                              ],
                                            ),
                                            onPressed: () {
                                              _bookmark();
                                            },
                                          )
                                        : RaisedButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        30.0)),
                                            color: Colors.orangeAccent,
                                            child: Row(
                                              children: <Widget>[
                                                Icon(
                                                  Icons.bookmark,
                                                  color: Colors.white,
                                                ),
                                                Text(
                                                  ' Bookmark',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )
                                              ],
                                            ),
                                            onPressed: () {
                                              _bookmark();
                                            },
                                          ),
                                  ],
                                )
                              ],
                            ))
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: Divider(
                          thickness: 1.0,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: Card(
                          elevation: 3,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const ListTile(
                                leading: Text(
                                  "DETAILS",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                // title: Text('The Enchanted Nightingale'),
                                // subtitle:
                                //     Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 10, right: 10),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Icon(Icons.account_balance_wallet),
                                        Container(
                                          margin: EdgeInsets.only(left: 10),
                                          child: Text(dataJson == null
                                              ? " "
                                              : dataJson["salary"] + "  (IDR)"),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Icon(Icons.pin_drop),
                                        Container(
                                          margin: EdgeInsets.only(left: 10),
                                          child: Text(dataJson == null
                                              ? " "
                                              : dataJson["city"]),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Icon(Icons.business_center),
                                        Container(
                                          margin: EdgeInsets.only(left: 10),
                                          child: Text(dataJson == null
                                              ? " "
                                              : "Atleast " +
                                                  dataJson["pengalaman"] +
                                                  " years"),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Icon(Icons.business),
                                        Container(
                                          margin: EdgeInsets.only(left: 10),
                                          child: Text(dataJson == null
                                              ? " "
                                              : dataJson["job_func"]),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Icon(Icons.school),
                                        Container(
                                          margin: EdgeInsets.only(left: 10),
                                          child: Text(dataJson == null
                                              ? " "
                                              : dataJson["degrees"]),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Icon(Icons.account_balance),
                                        Container(
                                          margin: EdgeInsets.only(left: 10),
                                          child: Text(dataJson == null
                                              ? " "
                                              : dataJson["majors"]),
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
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: Card(
                          elevation: 3,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const ListTile(
                                leading: Text(
                                  "Time Line Date",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                // title: Text('The Enchanted Nightingale'),
                                // subtitle:
                                //     Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
                              ),
                              Container(
                                  margin: EdgeInsets.only(left: 10, right: 10),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Text("Recruitment date : "),
                                          Text(dataJson[
                                                  "recruitmentDate_start"] ??
                                              " - "),
                                          Text(" - "),
                                          Text(
                                              dataJson["recruitmentDate_end"] ??
                                                  " - ")
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Text("Online Quiz : "),
                                          Text(dataJson["quizDate_start"] ??
                                              " - "),
                                          Text(" - "),
                                          Text(
                                              dataJson["quizDate_end"] ?? " - ")
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Text("Psycho Test Date : "),
                                          Text(dataJson[
                                                  "psychoTestDate_start"] ??
                                              " - "),
                                          Text(" - "),
                                          Text(dataJson["psychoTestDate_end"] ??
                                              " - ")
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Text("Interview  : "),
                                          Text(dataJson["interview_date"] ??
                                              " - "),
                                        ],
                                      )
                                    ],
                                  )),
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
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: Card(
                          elevation: 3,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const ListTile(
                                leading: Text(
                                  "REQUIREMENTS",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                // title: Text('The Enchanted Nightingale'),
                                // subtitle:
                                //     Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 5, right: 10),
                                child: Html(
                                  data: dataJson == null
                                      ? " "
                                      : dataJson["syarat"],
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
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: Card(
                          elevation: 3,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const ListTile(
                                leading: Text(
                                  "RESPONSIBILITIES",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                // title: Text('The Enchanted Nightingale'),
                                // subtitle:
                                //     Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 5, right: 10),
                                child: Html(
                                  data: dataJson == null
                                      ? " "
                                      : dataJson["tanggungjawab"],
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
                    ],
                  ))));
  }
}
