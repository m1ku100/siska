import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:siska/constant/Constant.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:siska/views/detail.dart';
import 'package:siska/views/modal_filter.dart';

class Job extends StatefulWidget {
  final String tile;
  Job({Key key, @required this.tile}) : super(key: key);
  @override
  _JobState createState() => _JobState(tile);
}

class _JobState extends State<Job> {
  
  _JobState(this.tile);
  final String tile;
  List dataJson;
  double _width;
  double _height;
  int _limit = 10;
  var _q = "";
  var _loc = "";
  var _salary = "";
  var _jobfunc = "";
  var _industry = "";
  var _degree = "";
  var scaffoldKey = GlobalKey<ScaffoldState>();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Future<String> getData() async {
    /**
     * Fetch Data from Uri
     */
    var data = jsonEncode({
      "q": _q,
      "agen": "",
      "loc": _loc,
      "limit": _limit,
      "salary_ids": _salary,
      "jobfunc_ids": _jobfunc,
      "industry_ids": _industry,
      "degree_ids": _degree,
      "major_ids": ""
    });
    // print(data);
    try {
      http.Response item = await http.post("https://kariernesia.com/api/search",
          body: data,
          headers: {
            "Accept": "application/json",
            'Content-type': 'application/json'
          });
      // http.Response item = await http.get(
      //     Uri.encodeFull("https://kariernesia.com/api/clients/vacancies/get/" +
      //         _limit.toString()),
      //     headers: {"Accept": "application/json"});

      print(data);
      this.setState(() {
        dataJson = jsonDecode(item.body);
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
        this.getData();
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

  void _openAddEntryDialog(BuildContext context) async {
    var result = await Navigator.push(
        context,
        new MaterialPageRoute(
          builder: (BuildContext context) => new ModalFilter(),
          fullscreenDialog: true,
        ));

    // Scaffold.of(context).showSnackBar(SnackBar(
    //   content: Text("$result"),
    //   duration: Duration(seconds: 3),
    // ));

    var data = jsonDecode(result);
    // print("hasil filter :"+data.toString());
    setState(() {
      _q = data["q"];
      _jobfunc = data["jobfunc_ids"];
      _industry = data["industry_ids"];
      _degree = data["degree_ids"];
      _salary = data["salary_ids"];
      _loc = data["loc"];
      dataJson = null;
    });

    check_connecti();
  }

  @override
  void initState() {
    setState(() {
     _q = tile; 
    });
    // TODO: implement initState
    this.check_connecti();
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
      _limit = _limit + 10;
    });
    print(_limit);
    this.check_connecti();
    // items.add((items.length + 1).toString());
    // if (mounted) setState(() {});
    print("Loading Complete");
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: scaffoldKey,
      appBar: new AppBar(
        backgroundColor: Colors.orange[200],
        title: Text("Available Job Vacancies"),
      ),
      floatingActionButton: FloatingActionButton.extended(
        elevation: 3,
        onPressed: () {
          _openAddEntryDialog(context);
        },
        backgroundColor: Colors.orange[200],
        label: Icon(Icons.sort),
      ),
      body: dataJson == null
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
                    body = CupertinoActivityIndicator();
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
              child: ListView.builder(
                padding: EdgeInsets.all(5),
                shrinkWrap: true,
                itemCount: dataJson == null ? 0 : dataJson.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, i) {
                  return new GestureDetector(
                    onTap: () {
                      print(dataJson[i]["id"]);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Detail(
                              id: dataJson[i]["id"],
                            ),
                          ));
                    },
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0)),
                      color: Colors.white,
                      child: new Container(
                          padding: EdgeInsets.only(
                              left: 10, top: 10, right: 5, bottom: 10),
                          child: SingleChildScrollView(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Container(
                                    width: _width / 3,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      color: Colors.orange[50],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.all(10),
                                    child: Hero(
                                      tag: 'ava-icon-${dataJson[i]["id"]}',
                                      child: Image.network(
                                        dataJson[i]["user"]["ava"],
                                        fit: BoxFit.cover,
                                        height: _height / 7,
                                        width: _width / 10,
                                      ),
                                    )),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: _width / 2,
                                      child: Text(
                                        dataJson[i]["judul"],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 5,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: _height / 45),
                                      ),
                                    ),
                                    Container(
                                      width: _width / 3,
                                      padding: EdgeInsets.only(top: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Flexible(
                                            child: Text(
                                              "Rp." + dataJson[i]["salary"],
                                              style: TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Container(
                                              padding: EdgeInsets.all(2),
                                              color: Colors.grey[200],
                                              child: Text(
                                                dataJson[i]["industry"],
                                                softWrap: true,
                                                style: TextStyle(fontSize: 10),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Container(
                                      width: _width / 2,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                dataJson[i]["updated_at"],
                                                style: TextStyle(
                                                    fontSize: _height / 65),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.location_on,
                                                    size: _height / 65,
                                                  ),
                                                  Text(
                                                    dataJson[i]["city"],
                                                    style: TextStyle(
                                                        fontSize: _height / 65),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
