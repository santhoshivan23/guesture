import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guesture/models/event.dart';
import 'package:guesture/models/guest.dart';
import 'package:guesture/screens/event_overview_screen.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_extend/share_extend.dart';

class QRScreen extends StatelessWidget {
  static const routeName = '/qr';

  String getDate(DateTime dt) => DateFormat.yMMMMEEEEd().format(dt);

  String getMonth(DateTime dt) => DateFormat.MMM().format(dt);

  String getTime(TimeOfDay td) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, td.hour, td.minute);
    return DateFormat.jm().format(dt).toString();
  }

  final ScreenshotController _controller = ScreenshotController();
  void _share(String ph, String guestName, String eventName, String guestID) {
    FlutterOpenWhatsapp.sendSingleMessage(ph,
        "Hey *$guestName!*,\n\nThank you for registering for our event - *$eventName*. Your guest ID is *$guestID*. Scan your ticket at the venue to check-in. Looking forward to have you onboard! \n\n_This event is managed on *Guesture*. Click on the link below to download the app now and start organizing your events!_  \n\nbit.ly/guesture-android");
  }

  Future<void> _shareTicket() async {
    File file = await _controller.capture();

    await ShareExtend.share(
      file.path,
      'image',
      sharePanelTitle: 'hi',
      subject: 'sub',
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    final guestData = args['guestData'] as Guest;
    final eventID = args['eventID'] as String;
    final eventName = args['eventName'] as String;
    final height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async => false,
      child: Screenshot(
        controller: _controller,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Text(
                'G',
                style: GoogleFonts.pacifico(fontSize: 20),
              ),
            ),
            centerTitle: true,
            title: const Text('Entry Ticket'),
            backgroundColor: Colors.green,
            actions: [
              PopupMenuButton(
                  onSelected: (int value) {
                    value == 0
                        ? _share(guestData.gMobileNumber, guestData.gName,
                            eventName, guestData.gID)
                        : _shareTicket();
                  },
                  itemBuilder: (ctx) => [
                        PopupMenuItem(
                          child: FittedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  MdiIcons.whatsapp,
                                  color: Colors.green,
                                ),
                                Text(
                                    '    Invite via ${guestData.gName}\'s WhatsApp'),
                              ],
                            ),
                          ),
                          value: 0,
                        ),
                        PopupMenuItem(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                MdiIcons.shareVariant,
                                color: Colors.green,
                              ),
                              Text('Share ticket'),
                            ],
                          ),
                          value: 1,
                        ),
                      ])
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
                    
                          Text(
                            'Hey ${guestData.gName},',
                            style: GoogleFonts.notoSans(
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\nYour reservation for ${eventData.eventName} is successful! You can scan the following ticket at the venue to check-in',
                            textAlign: TextAlign.center,
                          ),
                      
                      
                    
                    Divider(
                      thickness: 1,
                    ),
                    SizedBox(height: height * 0.012),
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal:
                              MediaQuery.of(context).size.width * 0.333),
                      child: QrImage(
                        foregroundColor: Colors.black87,
                        padding: EdgeInsets.all(1),
                        data: guestData.gID +
                            '%' +
                            guestData.gAllowance.toString(),
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
                    SizedBox(height: height * 0.012),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: height * 0.036),
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
                                vertical: height*0.012, horizontal: height * 0.01),
                            height: height*0.048,
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
                    SizedBox(height: height*0.006),
                    Padding(
                      padding:  EdgeInsets.symmetric(
                          horizontal: height*0.024, vertical: height*0.01),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'This event is managed on  ',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.notoSans(
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Guesture',
                            style: GoogleFonts.pacifico(),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: height*0.024),
                      child: Text(
                        'Download the Guesture app from Google Play Store and start organizing your events.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ), 
              );
            },
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Padding(
            padding:  EdgeInsets.only(bottom : height * 0.042),
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.pink,
              child: Icon(MdiIcons.home),
              onPressed: () {
                Navigator.of(context)
                    .popUntil(ModalRoute.withName(EventOverviewScreen.routeName));
              },
            ),
          ),
        ),
      ),
    );
  }
}
