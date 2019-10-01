import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:giffy_dialog/giffy_dialog.dart';

import 'package:siska/views/Widgets/custom_shape.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var scaffoldKey = GlobalKey<ScaffoldState>();

  double _height;
  double _width;

  List dataJson;

  
  Future<String> getLatest() async {
    http.Response item = await http.get(
        Uri.encodeFull("http://siska.org/api/clients/vacancies/latest"),
        headers: {"Accept": "application/json"});

    this.setState(() {
      dataJson = jsonDecode(item.body);
    });
    print("Success Latest");
  }

   void check_connecti() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        this.getLatest();
      }
    } on SocketException catch (_) {
      _showAlert('Your not connected');
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
    // super.initState();
    this.check_connecti();
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return new Scaffold(
        key: scaffoldKey,
        body: SingleChildScrollView(
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
                          print('Showing all');
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
                      const ListTile(
                        leading: Image(
                          image: AssetImage("assets/menu/edu.png"),
                        ),
                        title: Text('The Enchanted Nightingale'),
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
                                  Icon(Icons.delete, color: Colors.redAccent,),
                                  Text('DELETE', style: TextStyle(color: Colors.redAccent),)
                                ],
                              ),
                              onPressed: () {/* ... */},
                            ),
                            FlatButton(
                              child:  Row(
                                children: <Widget>[
                                  Icon(Icons.edit),
                                  Text('EDIT', style: TextStyle(color: Colors.blueAccent),)
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
                          print('Showing all');
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
                      const ListTile(
                        leading: Image(
                          image: AssetImage("assets/menu/edu.png"),
                        ),
                        title: Text('The Enchanted Nightingale'),
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
                                  Icon(Icons.delete, color: Colors.redAccent,),
                                  Text('DELETE', style: TextStyle(color: Colors.redAccent),)
                                ],
                              ),
                              onPressed: () {/* ... */},
                            ),
                            FlatButton(
                              child:  Row(
                                children: <Widget>[
                                  Icon(Icons.edit),
                                  Text('EDIT', style: TextStyle(color: Colors.blueAccent),)
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
              ),
              Container(
                margin: EdgeInsets.only(left: 20, right: 30, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Education", style: TextStyle(fontSize: 16)),
                    GestureDetector(
                        onTap: () {
                          // Navigator.of(context).pushNamed(TRENDING_UI);
                          print('Showing all');
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
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const ListTile(
                        leading: Image(
                          image: AssetImage("assets/menu/edu.png"),
                        ),
                        title: Text('The Enchanted Nightingale'),
                        subtitle: Text(
                            'Music by Julie Gable. Lyrics by Sidney Stein.'),
                      ),
                      /* Container(
                        margin: EdgeInsets.only(left: 50, right: 5,top: 10),
                        child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2, // 20%
                            child: Text("Data 3"),
                          ),
                          Expanded(
                            flex: 6, // 60%
                            child: Text("Data 3"),
                          ),
                          Expanded(
                            flex: 2, // 20%
                            child: Text("Data 3"),
                          )
                        ],
                      ),
                      ),*/
                      ButtonTheme.bar(
                        // make buttons use the appropriate styles for cards
                        child: ButtonBar(
                          children: <Widget>[
                            FlatButton(
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.delete, color: Colors.redAccent,),
                                  Text('DELETE', style: TextStyle(color: Colors.redAccent),)
                                ],
                              ),
                              onPressed: () {/* ... */},
                            ),
                            FlatButton(
                              child:  Row(
                                children: <Widget>[
                                  Icon(Icons.edit),
                                  Text('EDIT', style: TextStyle(color: Colors.blueAccent),)
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
              ),
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
                          print('Showing all');
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
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const ListTile(
                        leading: Icon(Icons.album),
                        title: Text('The Enchanted Nightingale'),
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
                                  Icon(Icons.delete, color: Colors.redAccent,),
                                  Text('DELETE', style: TextStyle(color: Colors.redAccent),)
                                ],
                              ),
                              onPressed: () {/* ... */},
                            ),
                            FlatButton(
                              child:  Row(
                                children: <Widget>[
                                  Icon(Icons.edit),
                                  Text('EDIT', style: TextStyle(color: Colors.blueAccent),)
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
              ),
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
                          print('Showing all');
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
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const ListTile(
                        leading: Icon(Icons.album),
                        title: Text('The Enchanted Nightingale'),
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
                                  Icon(Icons.delete, color: Colors.redAccent,),
                                  Text('DELETE', style: TextStyle(color: Colors.redAccent),)
                                ],
                              ),
                              onPressed: () {/* ... */},
                            ),
                            FlatButton(
                              child:  Row(
                                children: <Widget>[
                                  Icon(Icons.edit),
                                  Text('EDIT', style: TextStyle(color: Colors.blueAccent),)
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
              ),
               Container(
                margin: EdgeInsets.only(left: 20, right: 30, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Skill",
                        style: TextStyle(fontSize: 16)),
                    GestureDetector(
                        onTap: () {
                          // Navigator.of(context).pushNamed(TRENDING_UI);
                          print('Showing all');
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
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const ListTile(
                        leading: Icon(Icons.album),
                        title: Text('The Enchanted Nightingale'),
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
                                  Icon(Icons.delete, color: Colors.redAccent,),
                                  Text('DELETE', style: TextStyle(color: Colors.redAccent),)
                                ],
                              ),
                              onPressed: () {/* ... */},
                            ),
                            FlatButton(
                              child:  Row(
                                children: <Widget>[
                                  Icon(Icons.edit),
                                  Text('EDIT', style: TextStyle(color: Colors.blueAccent),)
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
              ),
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
                          print('Showing all');
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
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const ListTile(
                        leading: Icon(Icons.album),
                        title: Text('The Enchanted Nightingale'),
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
                                  Icon(Icons.delete, color: Colors.redAccent,),
                                  Text('DELETE', style: TextStyle(color: Colors.redAccent),)
                                ],
                              ),
                              onPressed: () {/* ... */},
                            ),
                            FlatButton(
                              child:  Row(
                                children: <Widget>[
                                  Icon(Icons.edit),
                                  Text('EDIT', style: TextStyle(color: Colors.blueAccent),)
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
              ),
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
            margin: EdgeInsets.only(left: 40, right: 40, top: _height / 3.25),
            child: Container(
                child: Center(
              child: Card(
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
                  opacity: 0.5,
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
                Opacity(
                  opacity: 0.5,
                  child: GestureDetector(
                      onTap: () {},
                      child: Icon(
                        Icons.notifications,
                        color: Colors.black,
                        size: _height / 30,
                      )),
                ),
              ],
            )),
        Container(
            margin:
                EdgeInsets.only(left: _width / 3, right: 20, top: _height / 12),
            width: 150.0,
            height: 150.0,
            decoration: BoxDecoration(
                color: Colors.orange[200],
                image: DecorationImage(
                    image: NetworkImage(
                        'https://icon-library.net/images/avatar-icon/avatar-icon-4.jpg'),
                    fit: BoxFit.cover),
                borderRadius: BorderRadius.all(Radius.circular(75.0)),
                boxShadow: [BoxShadow(blurRadius: 7.0, color: Colors.black)])),
        Container(
          margin: EdgeInsets.only(
              left: _width / 2.25, right: 20, top: _height / 3.5),
          child: Text("Username",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                  fontSize: _height / 40)),
        )
      ],
    );
  }
}
