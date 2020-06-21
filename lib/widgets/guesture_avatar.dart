import 'package:flutter/material.dart';

class GuestureAvatar extends StatelessWidget {
  final String url;
  final String name;
  final String email;
  final double radius;
  GuestureAvatar(this.url, this.name, this.email,this.radius);
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage: url == null ? null : NetworkImage(url),
      child: url == null ? name == null || name.isEmpty ? Text(email[0]) : Text(name[0]) : null,
    );
  }
}
