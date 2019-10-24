import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:siska/views/apply_detail.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Invitation extends StatefulWidget {
  @override
  _InvitationState createState() => _InvitationState();
}

class _InvitationState extends State<Invitation> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var dataApply;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  bool isLoading = true;
  String _token;
  int _limit = 5;

  Future<String> getApply() async {
    try {
      http.Response item = await http.post(
          Uri.encodeFull(
              "https://kariernesia.com/jwt/vacancy/invitation?token=" + _token),
          body: jsonEncode({"limit": _limit}),
          headers: {"Accept": "application/json"});

      this.setState(() {
        dataApply = jsonDecode(item.body);
      });
      print("Load data success");
    } catch (e) {
      print(e);
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
        setState(() {
          isLoading = false;
        });
      }
    } on SocketException catch (_) {
      _showAlert('Your not connected');
    }
  }

  void _modalBottomSheetMenu() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return new Container(
            height: 350.0,
            color: Colors.transparent, //could change this to Color(0xFF737373),
            //so you don't have to change MaterialApp canvasColor
            child: new Container(
                decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(10.0),
                        topRight: const Radius.circular(10.0))),
                child: new Center(
                  child: new Text("This is a modal sheet"),
                )),
          );
        });
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    this.check_connecti();
    print("success refresh");
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    print(_limit);
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    setState(() {
      _limit = _limit + 5;
    });
    print(_limit);
    this.check_connecti();
    // items.add((items.length + 1).toString());
    // if (mounted) setState(() {});
    print("Loading Complete");
    _refreshController.loadComplete();
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
        title: Text(
          "Invitation From Agency",
          style: TextStyle(color: Colors.white),
        ),
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
          : SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              header: WaterDropHeader(),
              footer: CustomFooter(
                builder: (BuildContext context, LoadStatus mode) {
                  Widget body;
                  if (mode == LoadStatus.idle) {
                    body = Text("pull up load");
                  } else if (mode == LoadStatus.loading) {
                    body = CircularProgressIndicator();
                  } else if (mode == LoadStatus.failed) {
                    body = Text("Load Failed!Click retry!");
                  } else if (mode == LoadStatus.canLoading) {
                    body = Text("release to load more");
                  } else {
                    body = Text("No more Data");
                  }
                  return Container(
                    height: 55.0,
                    child: Center(child: body),
                  );
                },
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: dataApply.length == 0
                  ? Card(
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
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold)),
                          ),
                          ButtonTheme.bar(
                            // make buttons use the appropriate styles for cards
                            child: ButtonBar(
                              children: <Widget>[],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(5),
                      shrinkWrap: true,
                      itemCount: dataApply == null ? 0 : dataApply.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, i) {
                        return new GestureDetector(
                            onLongPress: () {
                              _modalBottomSheetMenu();
                            },
                            onTap: () {
                              print(dataApply[i]["id"]);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ApplyDetail(
                                      id: dataApply[i]["vacancy_id"],
                                    ),
                                  ));
                            },
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0)),
                              color: Colors.white,
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          dataApply[i]["user"]["ava"]),
                                      backgroundColor: Colors.transparent,
                                    ),
                                    title: Text(
                                      dataApply[i]["vacancy"]["judul"],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text("Applied at " +
                                        dataApply[i]["updated_at"]),
                                  )
                                ],
                              ),
                            ));
                      },
                    ),
            ),
    );
  }
}
