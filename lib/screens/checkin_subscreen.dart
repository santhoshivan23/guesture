import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guesture/models/guest.dart';
import 'package:guesture/providers/guesture_db.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class CheckinSubscreen extends StatelessWidget {
  final String eventID;

  CheckinSubscreen({this.eventID});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('events')
            .document(eventID)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Text('Loading');
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: CircularPercentIndicator(
                  animation: true,
                  animationDuration: 1000,
                  lineWidth: 7,
                  footer: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Percentage of guests checked-in',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  radius: 200,
                  center: Text(
                    (100 * snapshot.data['checkInFraction'])
                            .toStringAsFixed(0) +
                        ' %',
                    style: TextStyle(fontSize: 30),
                  ),
                  animateFromLastPercent: true,
                  percent: double.parse(snapshot.data['checkInFraction'].toString()),
                ),
              ),
              GuestData(eventID: eventID),
            ],
          );
        });
  }
}

class GuestData extends StatefulWidget {
  const GuestData({
    Key key,
    @required this.eventID,
  }) : super(key: key);

  final String eventID;

  @override
  _GuestDataState createState() => _GuestDataState();
}

class _GuestDataState extends State<GuestData> {
  Guest guest;
  var _loading = false;
  Future<void> _scan(BuildContext context, String eventID) async {
    String result = await scanner.scan();
    final guestID = result.split('%')[0];
    setState(() {
      guest = null;
      _loading = true;
    });
    final status = await GuestureDB
        .checkInGuest(guestID, eventID);
    if (status == 0)
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text('Attempt of Re-Entry!'),
                content: Text('Guest has already been check-in'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Close'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  )
                ],
              ));
    else if (status == -1) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text('Invalid Ticket!'),
                content: Text('Scanned ticket is not valid'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Close'),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  )
                ],
              ));
    } else {
      
      final guestMap = await Firestore.instance.collection('events').document(eventID).collection('guests').document(guestID).get().then((value) => value.data);
      final guestData = Guest(
        gAllowance: guestMap['gAllowance'],
        gEmailID: guestMap['gEmailID'],
        gEventID: guestMap['gEventID'],
        gGender: guestMap['gGender'],
        gMobileNumber: guestMap['gMobileNumber'],
        gName: guestMap['gName'],
        gOrg: guestMap['gOrg'],
        gID: guestMap['gID'],
      );
      setState(() {
        guest = guestData;
      });
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: guest == null
                    ? <Widget>[
                        Text(
                          'Start scanning tickets to check-in guests',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        buildScanButton(),
                        if(_loading) Center(child: CircularProgressIndicator(),)
                      ]
                    : [
                        ListTile(
                          leading: CircleAvatar(
                            child: Icon(Icons.person_pin),
                          ),
                          title: Text(guest.gName),
                          subtitle:
                              Text(guest.gGender == 'M' ? 'Male' : 'Female'),
                        ),
                        ListTile(
                          leading: CircleAvatar(child: Icon(Icons.school)),
                          title: Text(guest.gOrg),
                          subtitle: Text('Organization'),
                        ),
                        ListTile(
                          leading: CircleAvatar(child: Icon(Icons.phone)),
                          title: Text(guest.gMobileNumber),
                          subtitle: Text('Mobile No.'),
                        ),
                        ListTile(
                          leading: CircleAvatar(child: Icon(Icons.email)),
                          title: Text(guest.gEmailID),
                          subtitle: Text('Email ID'),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 3),
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Text(
                              'PERMIT  ${guest.gAllowance.toString()}',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        buildScanButton(),
                        if(_loading) Center(child: CircularProgressIndicator(),)
                      ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildScanButton() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: RaisedButton.icon(
        color: Colors.green,
        onPressed: () => _scan(context, widget.eventID),
        icon: Icon(
          Icons.camera_enhance,
          color: Colors.white,
        ),
        label: Text(
          'Scan Ticket',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
