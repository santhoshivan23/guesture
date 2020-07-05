import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReservationCounter extends StatelessWidget {
  final String eventID;

  ReservationCounter({this.eventID});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return StreamBuilder(
        stream: Firestore.instance
            .collection('events')
            .document(eventID)
            .collection('guests')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Container(
                height: height * 0.31,
                child: Center(
              child: CircularProgressIndicator(),
            ));

          final allowances = (snapshot.data.documents.fold(
              0,
              (previousValue, element) =>
                  previousValue + element.data['gAllowance']));

          return Container(
            height: height * 0.34,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.indigo,
                width: 5,
              ),
              shape: BoxShape.circle,
              color: Colors.white70,
            ),
            child: Center(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.people_outline),
                    Center(
                      child: Text(
                        allowances.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 40),
                      ),
                    ),
                    Text('No.of Guests'),
                  ],
                ),
                SizedBox(width: height * 0.024),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.person_pin),
                    Center(
                      child: Text(
                        snapshot.data.documents.length.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 40),
                      ),
                    ),
                    Text('Reservations'),
                  ],
                ),
              ],
            )),
          );
        });
  }
}
