class GUser {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  bool isAdmin;
  GUser({this.uid,this.email,this.displayName,this.photoUrl,this.isAdmin = true});
}