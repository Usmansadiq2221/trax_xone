import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:trax_xone/navigations/AddSong.dart';
import 'package:trax_xone/navigations/HomeNavigation.dart';
import 'package:trax_xone/navigations/MySongLibrary.dart';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool isChanged = false;
  var iconSize = 36.0;

  // pages list to add pages in navigation..
  List<Widget> screenList = [
    AddSong(),
    HomeNavigation(),
    MySongLibrary(),
  ];

  int selectedIndex = 1;

  //updating navbar index...
  void setNavBarIndex(int index){

    setState(() {
      selectedIndex = index;
      iconSize = index==1 ? 36.0 : 28.0;

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screenList[selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        onTap: setNavBarIndex,
        height: 60.0,
        animationDuration: Duration(milliseconds: 300),
        color: Colors.grey.shade900,
        buttonBackgroundColor: Color.fromRGBO(255, 0, 56, 1),
        index: 1,

        backgroundColor: Colors.grey.shade800,
        items: [
          //for add song navigation page...
          Icon(
            Icons.add_circle,
            color: Colors.grey.shade200,
            size: 28.0,
          ),

          //for home navigation page...
          Icon(
            Icons.home,
            color: Colors.grey.shade200,
            size: iconSize,
          ),

          //for play list navigation page...
          Icon(
            Icons.my_library_music,
            color: Colors.grey.shade200,
            size: 28.0,
          )
        ],
      ),
    );
  }
}
