import 'package:flutter/material.dart';

import 'package:siska/views/clone_home.dart';
import 'package:siska/views/apply.dart';
import 'package:siska/views/job.dart';
import 'package:siska/constant/Constant.dart';

class MainTab extends StatefulWidget {
  @override
  _MainTabState createState() => _MainTabState();
}

class _MainTabState extends State<MainTab> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var page = [HomeClone(), Apply()];

  int currentTab = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      floatingActionButton: FloatingActionButton.extended(
        elevation: 3,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Job(
                  tile: "",
                ),
              ));
        },
        backgroundColor: Colors.orange[200],
        icon: Icon(Icons.search),
        label: Text(
          "Find Job",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: PageView(
        children: <Widget>[page[currentTab]],
      ),
      bottomNavigationBar: _bottomNavBar(),
    );
  }

  Widget _bottomNavBar() {
    return BottomAppBar(
      notchMargin: 4,
      shape: AutomaticNotchedShape(RoundedRectangleBorder(),
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      child: Container(
        margin: EdgeInsets.only(left: 50, right: 50),
        decoration: BoxDecoration(
            shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(30)),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                setState(() {
                  currentTab = 0;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.business_center),
              onPressed: () {
                setState(() {
                  currentTab = 1;
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
