import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guesture/models/guest.dart';
import 'package:guesture/providers/guesture_db.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class CheckinSubscreen extends StatelessWidget {
  final String eventID;

  CheckinSubscreen({this.eventID});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
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
                padding: EdgeInsets.all(height * 0.021),
                child: CircularPercentIndicator(
                  animation: true,
                  animationDuration: 1000,
                  lineWidth: 7,
                  footer: Padding(
                    padding:  EdgeInsets.all(height * 0.001),
                    child: Text(
                      'Percentage of guests checked-in',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  radius: height * 0.238,
                  center: Text(
                    (100 * snapshot.data['checkInFraction'])
                            .toStringAsFixed(0) +
                        ' %',
                    style: TextStyle(fontSize: 30),
                  ),
                  animateFromLastPercent: true,
                  percent:
                      double.parse(snapshot.data['checkInFraction'].toString()),
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
  final gIDController = TextEditingController();
  final _fKey = GlobalKey<FormState>();

  Future<void> _initiateCheckIn(String guestID) async {
    setState(() {
      _loading = true;
      guest = null;
    });
    final status = await GuestureDB.checkInGuest(guestID, widget.eventID);
    if (status == 0)
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text('Attempt of Re-Entry!'),
                content: Text('Guest has already checked-in'),
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
      final guestMap = await Firestore.instance
          .collection('events')
          .document(widget.eventID)
          .collection('guests')
          .document(guestID)
          .get()
          .then((value) => value.data);
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

  Future<void> _scan() async {
    String result = await scanner.scan();
    final guestID = result.split('%')[0];
    await _initiateCheckIn(guestID);
  }

  @override
  Widget build(BuildContext context) {
    final height  = MediaQuery.of(context).size.height;
    return Expanded(
      child: Padding(
        padding:  EdgeInsets.symmetric(horizontal: height * 0.024),
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding:  EdgeInsets.all(height* 0.001),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: guest == null
                    ? <Widget>[
                        Text(
                          'Scan tickets / Manual Check-in',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Form(
                          key: _fKey,
                          child: Padding(
                            padding:
                                 EdgeInsets.symmetric(horizontal: height * 0.012),
                            child: TextFormField(
                              controller: gIDController,
                              validator: (id) {
                                if (id.isEmpty)
                                  return "Enter a guest ID to check-in";
                                if (id.length < 10)
                                  return "Guest ID must be 10 chars long.";
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'Enter Guest ID (10 characters)',
                                counterText: 'Manual Check-In',
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            buildScanButton(),
                             RaisedButton.icon(
                                icon: Icon(
                                  MdiIcons.pen,
                                  color: Colors.white,
                                ),
                                color: Colors.orange,
                                label: FittedBox(
                                                                  child: Text(
                                    'Manual',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                onPressed: () async {
                                  if (!_fKey.currentState.validate()) return;
                                  await _initiateCheckIn(gIDController.text);
                                },
                              ),
                            
                          ],
                        ),
                        if (_loading)
                          Center(
                            child: CircularProgressIndicator(),
                          )
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
                            padding:  EdgeInsets.all(height * 0.018),
                            child: Text(
                              'PERMIT  ${guest.gAllowance.toString()}',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            buildScanButton(),
                            RaisedButton.icon(
                              color: Colors.orange,
                              label: Text('Go Back',style: TextStyle(color:Colors.white),),
                              icon: Icon(MdiIcons.arrowLeft,color: Colors.white,),
                              onPressed: () {
                                setState(() {
                                  guest = null;
                                });
                              },
                            )
                          ],
                        ),
                        if (_loading)
                          Center(
                            child: CircularProgressIndicator(),
                          )
                      ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildScanButton() {
    final height = MediaQuery.of(context).size.height;
    return Padding(
      padding:  EdgeInsets.all(height * 0.018),
      child: RaisedButton.icon(
        color: Colors.green,
        onPressed: () => _scan(),
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
