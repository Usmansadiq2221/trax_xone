

import 'package:flutter/material.dart';
import 'package:trax_xone/tabs/MyMusicTab.dart';
import 'package:trax_xone/tabs/MyPlayLists.dart';

class MySongLibrary extends StatefulWidget {
  const MySongLibrary({Key? key}) : super(key: key);

  @override
  State<MySongLibrary> createState() => _MySongLibraryState();
}

class _MySongLibraryState extends State<MySongLibrary> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade800,
        appBar: AppBar(
          backgroundColor: Colors.black12,
          bottom: TabBar(

            indicatorColor: Colors.grey,

            tabs: [
              Tab(
                child: Text(
                  "My Play Lists",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "My Music",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Center(
              child: MyPlayLists(),
            ),
            Center(
              child: MyMusicTab(),
            ),
          ],
        ),
      ),
    );
  }
}
