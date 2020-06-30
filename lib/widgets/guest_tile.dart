import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:guesture/models/guest.dart';
import 'package:guesture/providers/guesture_db.dart';
import 'package:guesture/screens/qr_screen.dart';
import '../models/transaction.dart' as tx;

class GuestTile extends StatefulWidget {
  final String gID;
  final String eventID;
  final String eventName;
  final String gName;
  final String gMobileNumber;
  final String gEmailID;
  final String gGender;
  final String gOrg;
  final int gAllowance;
  final bool isCheckedIn;
  final bool isAdmin;

  GuestTile(
      {this.gID,
      this.eventName,
      this.eventID,
      this.gName,
      this.gMobileNumber,
      this.gEmailID,
      this.gGender,
      this.gOrg,
      this.gAllowance,
      this.isCheckedIn = false,
      this.isAdmin});

  @override
  _GuestTileState createState() => _GuestTileState();
}

class _GuestTileState extends State<GuestTile> {
  var _expanded = false;

  _callGuest(String guestPhone) async {
    final number = guestPhone;
    bool res = await FlutterPhoneDirectCaller.callNumber(number);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ListTile(
              onTap: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              leading: CircleAvatar(
                backgroundColor: widget.isCheckedIn ? Colors.green : Colors.red,
                child: Text(widget.gName[0]),
                foregroundColor: Colors.white,
              ),
              title: Text(
                widget.gName,
                textAlign: TextAlign.center,
              ),
              subtitle: Text(
                widget.gOrg,
                textAlign: TextAlign.center,
              ),
              trailing: Container(
                width: 70,
                child: FittedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(widget.gAllowance.toString()),
                      IconButton(
                        icon: Icon(Icons.phone),
                        color: Colors.indigo,
                        onPressed: () {
                          _callGuest(widget.gMobileNumber);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              dense: true,
            ),
            AnimatedContainer(
                duration: Duration(milliseconds: 250),
                //decoration: BoxDecoration(border: Border.all(width: 0.1)),
                height: _expanded ? 220 : 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(Icons.perm_identity, color: Colors.pink),
                          Text(widget.gID),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(
                            Icons.email,
                            color: Colors.blue,
                          ),
                          Text(widget.gEmailID),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(
                            Icons.phone,
                            color: Colors.deepPurple,
                          ),
                          Text(widget.gMobileNumber),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Icon(
                            Icons.bubble_chart,
                            color: widget.isCheckedIn
                                ? Colors.green
                                : Colors.redAccent,
                          ),
                          Text(widget.gGender == 'M' ? 'Male' : 'Female'),
                        ],
                      ),
                      SizedBox(height: 5),
                      if (!widget.isAdmin && widget.isCheckedIn)
                        RaisedButton.icon(
                          onPressed: () {},
                          color: Colors.green,
                          icon: Icon(
                            Icons.done,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Guest checked-in',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      if (!widget.isCheckedIn)
                        RaisedButton.icon(
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(QRScreen.routeName, arguments: {
                              'eventID': widget.eventID,
                              'eventName' : widget.eventName,
                              'guestData': Guest(
                                  gAllowance: widget.gAllowance,
                                  gEmailID: widget.gEmailID,
                                  gGender: widget.gGender,
                                  gMobileNumber: widget.gMobileNumber,
                                  gName: widget.gName,
                                  gOrg: widget.gOrg,
                                  gID: widget.gID,
                                  gEventID: widget.eventID),
                            });
                          },
                          color: Colors.blue,
                          icon: Icon(
                            Icons.account_box,
                            color: Colors.white,
                          ),
                          label: Text(
                            'View Ticket',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      if (widget.isAdmin)
                        RaisedButton.icon(
                          onPressed: widget.isCheckedIn
                              ? null
                              : () {
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (ctx) => AlertDialog(
                                            title:
                                                Text('Confirm Delete Guest?'),
                                            content: Text(
                                                'The guest and all dependent data will be deleted.'),
                                            actions: <Widget>[
                                              FlatButton(
                                                  child: Text(
                                                    'Confirm',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                  onPressed: () async {
                                                    Navigator.of(ctx).pop();
                                                    setState(() {
                                                      _expanded = false;
                                                    });
                                                    final tp = await Firestore
                                                        .instance
                                                        .collection('events')
                                                        .document(
                                                            widget.eventID)
                                                        .get()
                                                        .then((value) =>
                                                            value.data[
                                                                'ticketPrice']);

                                                    await GuestureDB
                                                            .addTrasanction(
                                                                tx.GTransaction(
                                                                  amount: widget
                                                                          .gAllowance
                                                                          .toDouble() *
                                                                      tp *
                                                                      -1,
                                                                  payerName:
                                                                      'REM__GST_${widget.gName}',
                                                                  timeOfPayment:
                                                                      DateTime
                                                                          .now(),
                                                                ),
                                                                widget.eventID)
                                                        .then((value) async =>
                                                            await GuestureDB
                                                                .deleteGuest(
                                                                    widget
                                                                        .eventID,
                                                                    widget
                                                                        .gID));
                                                    

                                                    Scaffold.of(context)
                                                        .showSnackBar(SnackBar(
                                                      duration:
                                                          Duration(seconds: 1),
                                                      content: Text(
                                                        'Guest Removed!',
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ));
                                                  }),
                                              FlatButton(
                                                child: Text('Go Back'),
                                                onPressed: () {
                                                  Navigator.of(ctx).pop();
                                                },
                                              )
                                            ],
                                          ));
                                },
                          color: Colors.red,
                          disabledColor: Colors.green,
                          icon: widget.isCheckedIn
                              ? Icon(
                                  Icons.done,
                                  color: Colors.white,
                                )
                              : Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                          label: Text(
                            widget.isCheckedIn
                                ? 'Guest checked-in'
                                : 'Remove Guest',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
