import 'package:flutter/material.dart';

class GuestureAvatar extends StatelessWidget {
  final String url;
  final String name;
  final String email;
  GuestureAvatar(this.url, this.name, this.email);
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 50,
      backgroundImage: url == null ? null : NetworkImage(url),
      child: url == null ? name != null ? Text(name[0]) : Text(email[0]) : null,
    );
  }
}
