import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guesture/models/event.dart';
import 'package:guesture/models/guest.dart';
import 'package:guesture/screens/event_overview_screen.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRScreen extends StatelessWidget {
  static const routeName = '/qr';

  String getDate(DateTime dt) => DateFormat.yMMMMEEEEd().format(dt);

  String getMonth(DateTime dt) => DateFormat.MMM().format(dt);

  String getTime(TimeOfDay td) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, td.hour, td.minute);
    return DateFormat.jm().format(dt).toString();
  }

  void _share(String ph) {
    FlutterOpenWhatsapp.sendSingleMessage(ph, "");
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    final guestData = args['guestData'] as Guest;
    final eventID = args['eventID'] as String;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Text(
              'G',
              style: GoogleFonts.pacifico(fontSize: 20),
            ),
          ),
          centerTitle: true,
          title: const Text('Entry Ticket'),
          backgroundColor: Colors.green,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share),
              onPressed: () => _share(guestData.gMobileNumber),
            )
          ],
        ),
        body: FutureBuilder(
          future: Firestore.instance
              .collection('events')
              .document(eventID)
              .get()
              .then((value) => value),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());
            final eventData = Event(
              eventName: snapshot.data['eventName'],
              location: snapshot.data['location'],
              startDate: DateTime.parse(snapshot.data['startDT']),
              startTime: TimeOfDay.fromDateTime(
                DateTime.parse(snapshot.data['startDT']),
              ),
              ticketPrice: snapshot.data['ticketPrice'],
            );
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Hey ${guestData.gName},',
                          style:
                              GoogleFonts.notoSans(fontWeight: FontWeight.bold),
                        ),
                        Text(
                            '\nYour reservation for ${eventData.eventName} is successful! You can scan the following ticket at the venue to check-in',textAlign: TextAlign.center,),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.333),
                    child: QrImage(
                      foregroundColor: Colors.black87,
                      padding: EdgeInsets.all(1),
                      data:
                          guestData.gID + '%' + guestData.gAllowance.toString(),
                      version: QrVersions.auto,
                      size: MediaQuery.of(context).size.width * 0.333,
                    ),
                  ),
                  Text(
                    guestData.gID +
                        '%' +
                        guestData.gName.substring(0, 3) +
                        '-' +
                        guestData.gAllowance.toString(),
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    width: double.infinity,
                    
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 8),
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    Colors.purple,
                                    Colors.purple.withOpacity(0.8),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight),
                            ),
                            child: Text(
                              eventData.eventName,
                              style: GoogleFonts.notoSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Card(
                            elevation: 3,
                            child: ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.calendar_today,
                                color: Colors.red,
                              ),
                              title: Text(
                                'Date',
                              ),
                              subtitle: Row(
                                children: <Widget>[
                                  Text(getDate(eventData.startDate)),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            elevation: 3,
                            child: ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.access_time,
                                color: Colors.green,
                              ),
                              title: Text(
                                'Time',
                              ),
                              subtitle: Text(
                                getTime(eventData.startTime),
                              ),
                            ),
                          ),
                          Card(
                            elevation: 3,
                            child: ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.location_on,
                                color: Colors.deepPurple,
                              ),
                              title: Text(
                                'Location',
                              ),
                              subtitle: Text(
                                eventData.location,
                              ),
                              trailing: SizedBox(
                                width: 62,
                              ),
                            ),
                          ),
                          Card(
                            elevation: 3,
                            child: ListTile(
                              dense: true,
                              leading: Icon(
                                Icons.attach_money,
                                color: Colors.amber,
                              ),
                              title: Text(
                                'Ticket Amount',
                              ),
                              subtitle: Text(
                                '${eventData.ticketPrice.toStringAsFixed(0)} x ${guestData.gAllowance.toString()}',
                              ),
                              trailing: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: Text(
                                  (eventData.ticketPrice * guestData.gAllowance)
                                      .toString(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      
                    ),
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'This event is managed on  ',
                          textAlign: TextAlign.center,
                          style:
                              GoogleFonts.notoSans(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Guesture',
                          style: GoogleFonts.pacifico(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Download the Gesture app from Google Play Store and start organizing your events.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 100,)
                ],
              ),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          tooltip: 'Go to dashboard',
          backgroundColor: Colors.green,
          onPressed: () {
            Navigator.of(context)
                .popUntil(ModalRoute.withName(EventOverviewScreen.routeName));
          },
          child: Icon(Icons.dashboard),
        ),
      ),
    );
  }
}
