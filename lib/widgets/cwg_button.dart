import 'package:flutter/material.dart';
import 'package:guesture/providers/auth.dart';

class CWGButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: () async {
          await Auth().signInWithGoogle(context);
          Navigator.of(context).pop();
        },
        child: Image.asset(
          'assets/google.png',
          scale: 2,
        ),
      ),
    );
  }
}
