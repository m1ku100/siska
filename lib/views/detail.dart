import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:siska/views/Widgets/mainui_customcard.dart';
import 'package:siska/constant/Constant.dart';

class Detail extends StatefulWidget {
  final int id;
  Detail({Key key, @required this.id}) : super(key: key);
  @override
  _DetailState createState() => _DetailState(id);
}

class _DetailState extends State<Detail> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var dataJson;

  final bool horizontal = true;
  double _height;
  double _width;
  int id;
  _DetailState(this.id);

  List dataFavorite;

  Future<String> getData() async {
    /**
     * Fetch Data from Uri
     */
    http.Response item = await http.get(
        Uri.encodeFull(
            BASE_URL+"clients/vacancies/" + id.toString()),
        headers: {"Accept": "application/json"});

    this.setState(() {
      dataJson = json.decode(item.body);
    });
    print("success");
  }

  Future<String> getFavorite() async {
    http.Response item = await http.get(
        Uri.encodeFull("http://siska.org/api/clients/vacancies/favorite"),
        headers: {"Accept": "application/json"});

    this.setState(() {
      dataFavorite = jsonDecode(item.body);
    });
    print("Success Favorite");
  }

  void check_connecti() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        this.getData();
        await this.getFavorite();
      }
    } on SocketException catch (_) {
      _showAlert("You'are not connected");
    }
  }

  void _showSnackbar(String str) {
    if (str.isEmpty) return;

    scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(str),
      duration: new Duration(seconds: 2),
    ));
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
          title: Text(dataJson == null ? " " : dataJson["judul"]),
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
                      Text(dataJson == null ? " " : dataJson["judul"],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          )),
                      ButtonBar(
                        children: <Widget>[
                          RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0)),
                            color: Colors.orangeAccent,
                            child: Row(
                              children: <Widget>[
                                Text(
                                  'Apply  ',
                                  style: TextStyle(color: Colors.white),
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
                            onPressed: () {/* ... */},
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
                                  style: TextStyle(color: Colors.white),
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
                                child: Text(dataJson == null ? " " : dataJson["salary"]+"  (IDR)"),
                              )
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Icon(Icons.pin_drop),
                              Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Text(dataJson == null ? " " : dataJson["city"]),
                              )
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Icon(Icons.business_center),
                              Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Text(dataJson == null ? " " :"Atleast "+ dataJson["pengalaman"] + " years"),
                              )
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Icon(Icons.business),
                              Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Text(dataJson == null ? " " : dataJson["job_func"]),
                              )
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Icon(Icons.school),
                              Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Text(dataJson == null ? " " : dataJson["degrees"]),
                              )
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Icon(Icons.account_balance),
                              Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Text(dataJson == null ? " " : dataJson["majors"]),
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
            Container(
              margin: EdgeInsets.only(left: 20, right: 30, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Suggested jobs for you",
                      style: TextStyle(fontSize: 16)),
                  GestureDetector(
                      onTap: () {
                        // Navigator.of(context).pushNamed(TRENDING_UI);
                        print('Showing all');
                      },
                      child: Text(
                        '',
                        style: TextStyle(
                          color: Colors.orange[300],
                        ),
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
              height: _height / 3.4,
              //width: MediaQuery.of(context).size.width,
              child: ListView.separated(
                padding: EdgeInsets.all(5),
                shrinkWrap: true,
                itemCount: dataFavorite == null ? 0 : dataFavorite.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, index) {
                  return Container(
                    child: Card(
                      elevation: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              margin:
                                  EdgeInsets.only(top: 10, left: 10, right: 10),
                              width: 100.0,
                              height: 100.0,
                              decoration: BoxDecoration(
                                  color: Colors.orange[200],
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          dataFavorite[index]["user"]["ava"]),
                                      fit: BoxFit.cover),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(75.0)),
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 7.0, color: Colors.black)
                                  ])),
                          Container(
                            margin: EdgeInsets.only(top: 5),
                            width: _width / 2.5,
                            alignment: Alignment(0.0, 0.0),
                            child: Center(
                              child: Text(
                                dataFavorite[index]["judul"],
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          ButtonTheme.bar(
                            // make buttons use the appropriate styles for cards
                            child: ButtonBar(
                              children: <Widget>[
                                FlatButton(
                                  color: Colors.orangeAccent,
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        'Read More',
                                        style: TextStyle(color: Colors.white),
                                      )
                                    ],
                                  ),
                                  onPressed: () {/* ... */},
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
              ),
            )
          ],
        )));
  }
}
