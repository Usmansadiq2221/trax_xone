class PlayListData{


  String playListId;
  String playListName;
  String currentSongId;
  int numberofSong;
  double timestamp;
  List<String> songlist;

  PlayListData(
      {
        required this.playListId,
        required this.playListName,
        required this.currentSongId,
        required this.numberofSong,
        required this.timestamp,
        required this.songlist
      }
  );

  factory PlayListData.fromMap(Map<String, dynamic>? map) {
    return PlayListData(
      playListId: map?['PlayListId'],
      playListName: map?['PlayListName'],
      currentSongId: map?['CurrentSongId'],
      numberofSong: map?['NoOfSong'],
      timestamp: map?["Timestamp"],
      songlist: (map?["SongList"] as List<dynamic>).cast<String>()

    );
  }

  Map<String, dynamic> toPlayListMap() {
    return{
      "PlayListId":playListId,
      "PlayListName":playListName,
      "CurrentSongId":currentSongId,
      "NoOfSong":numberofSong,
      "Timestamp":timestamp,
      "SongList":songlist,
    };
  }
}