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

  Future<String> getData() async {
    /**
     * Fetch Data from Uri
     */
    try {
      http.Response item = await http.get(
          Uri.encodeFull(BASE_URL + "clients/vacancies/" + id),
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
        _showAlert("Yeey!!", dataChange['message'], "assets/images/nutmeg.gif");
       
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
      }
    } on SocketException catch (_) {
      _showAlert_connect("You'are not connected");
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
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange[200],
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("Application Detail"),
        ),
        body: new SingleChildScrollView(
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
                          RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0)),
                            color: Colors.redAccent,
                            child: Row(
                              children: <Widget>[
                                Text(
                                  'Abort  ',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
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
                             _abort();
                            },
                          ),
                          RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0)),
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
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            onPressed: () {/* ... */},
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
                                child: Text(
                                    dataJson == null ? " " : dataJson["city"]),
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
                        data: dataJson == null ? " " : dataJson["syarat"],
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
                        data:
                            dataJson == null ? " " : dataJson["tanggungjawab"],
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
        )));
  }
}
