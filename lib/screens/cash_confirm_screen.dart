import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guesture/models/guest.dart';
import 'package:guesture/models/transaction.dart';
import 'package:guesture/providers/guesture_db.dart';
import 'package:guesture/screens/qr_screen.dart';

class CashConfirmScreen extends StatefulWidget {
  static const routeName = '/cash-confirm';

  @override
  _CashConfirmScreenState createState() => _CashConfirmScreenState();
}

class _CashConfirmScreenState extends State<CashConfirmScreen> {
  Guest guestData;
  String eventID;
  String eventName;
  var init = false;
  var _loading = false;

  @override
  void didChangeDependencies() {
    if (init == false) {
      final args =
          ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
      guestData = args['guest'];
      eventID = args['eventID'];
      eventName = args['eventName'];
    }
    init = true;
    super.didChangeDependencies();
  }

  Future<void> _confirmReservation(BuildContext ctx) async {
    Navigator.pop(ctx);
    setState(() {
      _loading = true;
    });
    await GuestureDB.addGuest(guestData, eventID);
    final tp = await Firestore.instance
        .collection('events')
        .document(eventID)
        .get()
        .then((value) => value.data['ticketPrice']);
    await GuestureDB.addTrasanction(
        GTransaction(
          payerName: guestData.gName,
          timeOfPayment: DateTime.now(),
          amount: tp * guestData.gAllowance,
        ),
        eventID);
        setState(() {
          _loading = false;
        });
    Navigator.of(context).pushNamed(QRScreen.routeName, arguments: {
      'guestData': guestData,
      'eventID': eventID,
      'eventName' : eventName,
    });
  }

  void _fabPressed(BuildContext ctx) {
    showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (c) => AlertDialog(
              elevation: 5,
              title: Text(
                'Confirm',
                style: GoogleFonts.notoSans(fontWeight: FontWeight.bold),
              ),
              content: Text('Acknowledge Cash Payment'),
              actions: <Widget>[
                FlatButton(
                  child:  Text(
                    'Accept',
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () =>_confirmReservation(c),
                ),
                FlatButton(
                  child: Text(
                    'Decline',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(c).pop();
                  },
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Confirm Cash Payment'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          onPressed: () => _fabPressed(context),
          child: Icon(Icons.done),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Card(
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.person_pin),
                  ),
                  title: Text(guestData.gName),
                  subtitle: Text("Full Name"),
                ),
              ),
              Card(
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.phone),
                  ),
                  title: Text(guestData.gMobileNumber),
                  subtitle: Text('Mobile'),
                ),
              ),
              Card(
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(guestData.gAllowance.toString()),
                  ),
                  title: Text('Allowances'),
                ),
              ),
              SizedBox(height: 100),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.indigo, width: 1),
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.purple.withOpacity(0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Amount Payable',
                        style: GoogleFonts.notoSans(
                            color: Colors.white, fontSize: 16),
                      ),
                      FutureBuilder(
                        future: Firestore.instance
                            .collection('events')
                            .document(eventID)
                            .get()
                            .then((value) => value),
                        builder: (c, s) {
                          if (s.connectionState == ConnectionState.waiting)
                            return CircularProgressIndicator();
                          final ticketPrice = s.data['ticketPrice'];
                          return Text(
                            (ticketPrice * guestData.gAllowance).toString(),
                            style: GoogleFonts.notoSans(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height:20),
              _loading ? CircularProgressIndicator() : SizedBox(height: 0.5,)
            ],
          ),
        ));
  }
}
