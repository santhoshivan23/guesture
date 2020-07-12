import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guesture/screens/new_reservation_screen.dart';
import 'package:guesture/widgets/guest_tile.dart';

class ReservationsSubScreen extends StatelessWidget {
  final String eventID;
  final String eventName;
  final bool isAdmin;
  final String myUid;
  ReservationsSubScreen({this.eventID, this.isAdmin,this.myUid,this.eventName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('events')
              .document(eventID)
              .collection('guests')
              .orderBy('gName')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());
            return snapshot.data.documents.length == 0
                ? Center(
                    child: Text('There are no reservations for this event.'))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (ctx, index) => GuestTile(
                      gID: snapshot.data.documents[index].documentID,
                      eventName : eventName,
                      eventID: eventID,
                      gName: snapshot.data.documents[index]['gName'],
                      gEmailID: snapshot.data.documents[index]['gEmailID'],
                      gMobileNumber: snapshot.data.documents[index]
                          ['gMobileNumber'],
                      gGender: snapshot.data.documents[index]['gGender'],
                      gOrg: snapshot.data.documents[index]['gOrg'],
                      gAllowance: snapshot.data.documents[index]['gAllowance'],
                      isCheckedIn: snapshot.data.documents[index]
                          ['isCheckedIn'],
                      isAdmin: isAdmin,
                    ),
                  );
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.person_add),
        onPressed: () {
          Navigator.of(context)
              .pushNamed(NewReservationScreen.routeName, arguments: {
                'eventID' : eventID,
                'eventName' : eventName,
                'myUid' : myUid,
              });
        },
      ),
    );
  }
}
