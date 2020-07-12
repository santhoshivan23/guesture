import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guesture/models/g_user.dart';
import 'package:provider/provider.dart';

class NotifCounter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gUser = Provider.of<GUser>(context);
    print(gUser.uid);
    return Container(
      child: FittedBox(
        child: Row(
          children: [
            Icon(
              Icons.notifications,
              color: Colors.orange,
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              child: StreamBuilder(
                  stream: Firestore.instance
                      .collection('users')
                      .document(gUser.uid)
                      
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return Container();
                    else {
                      if(snapshot.data['notifCounter'] == null || snapshot.data['notifCounter'] == 0)
                      return Container();
                      return Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(snapshot.data['notifCounter'].toString(),style: TextStyle(color: Colors.white,fontSize: 12),),
                      );
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
