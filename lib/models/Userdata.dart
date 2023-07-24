class Userdata{

  final String uId;
  final String username;
  final String email;
  final String phoneNo;
  final String desc;
  final String profileUrl;


  Userdata({
    required this.uId,
    required this.username,
    required this.email,
    required this.phoneNo,
    required this.desc,
    required this.profileUrl
  });


  Map<String, dynamic> toUserMap() {
    return {
      "UId": uId,
      "Username": username,
      "email": email,
      "PhoneNo": phoneNo,
      "UserBio": desc,
      "ProfilePic": profileUrl,
    };
  }


}