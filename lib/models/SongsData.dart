class SongsData{

  String songId;
  String songName;
  String songArtist;
  String songCoverUrl;
  String songUrl;
  String songType;
  int songViews;
  int timestamp;
  String userId;
  bool isFav;

  SongsData({required this.songId, required this.songName, required this.songArtist, required this.songCoverUrl,
      required this.songUrl, required this.songType, required this.songViews, required this.timestamp, required this.userId, required this.isFav});


  factory SongsData.fromMap(Map<String, dynamic>? map) {
    return SongsData(
      songId: map?['SongId'],
      songName: map?['SongName'],
      songArtist: map?['SongArtist'],
      songCoverUrl: map?['SongCoverUrl'],
      songUrl: map?['SongUrl'],
      songType: map?['SongType'],
      songViews: map?['Views'],
      timestamp: map?['Timestamp'],
      userId: map?['UserId'],
      isFav: map?['isFav'],

    );
  }

  Map<String, dynamic> toSongsMap() {
    return{
      "SongId":songId,
      "SongName":songName,
      "SongArtist":songArtist,
      "SongCoverUrl":songCoverUrl,
      "SongUrl":songUrl,
      "SongType":songType,
      "Views":songViews,
      "Timestamp":timestamp,
      "UserId":userId,
      "isFav":isFav
    };
  }


}