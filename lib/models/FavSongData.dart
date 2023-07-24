class FavSongData{

  final String songId;

  FavSongData({required this.songId});

  Map<String, dynamic> toFavSongMap() {
    return {
      "songId": songId,
    };
  }


  factory FavSongData.fromMap(Map<String, dynamic>? map){
    return FavSongData(
      songId: map?['songId'],
    );
  }
}