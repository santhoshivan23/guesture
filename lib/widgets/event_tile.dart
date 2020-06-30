import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guesture/models/event.dart';
import 'package:guesture/models/g_user.dart';
import 'package:guesture/providers/guesture_db.dart';
import 'package:guesture/screens/add_event_screen.dart';
import 'package:guesture/screens/event_overview_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EventTile extends StatelessWidget {
  final String eventID;
  final String eventName;
  final String eventLocation;
  final DateTime startDate;
  final bool isAdmin;
  final bool access;
  final String myUid;
  final double ticketPrice;
  final String role;
  EventTile(
      {this.eventName,
      this.eventID,
      this.eventLocation,
      this.startDate,
      this.isAdmin,
      this.ticketPrice,
      this.role,
      this.myUid,
      this.access});

  String getDate(DateTime dt) => DateFormat.d().format(dt);

  String getMonth(DateTime dt) => DateFormat.MMM().format(dt);

  @override
  Widget build(BuildContext context) {
    final gUser = Provider.of<GUser>(context);
   
    return ListTile(
      onTap: () {
        if (access)
          Navigator.of(context)
              .pushNamed(EventOverviewScreen.routeName, arguments: {
            'eventID': eventID,
            'eventName': eventName,
            'isAdmin': role == 'admin' ? true : false,
            'myUid': myUid,
          });
        else
          Scaffold.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Acess Denied!\nWorkspace administrator is yet to approve your request.',
              textAlign: TextAlign.center,
            ),
          ));
      },
      onLongPress: !access
          ? null
          : () {
              showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                        title: Text(eventName),
                        content: Text('Delete or Modify Event'),
                        actions: <Widget>[
                          FlatButton(
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              showDialog(
                                  barrierDismissible: false,
                                  context: ctx,
                                  builder: (c) => AlertDialog(
                                        title: Text(
                                          'Confirm Deletion',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        content: Text(
                                            '$eventName and all its data will be permenantly deleted. This action cannot be reverted.'),
                                        actions: <Widget>[
                                          RaisedButton(
                                            color: Colors.red,
                                            child: Text(
                                              'Confirm',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              Navigator.of(context).pop();
                                              await GuestureDB.deleteEvent(
                                                  eventID);
                                            },
                                          ),
                                          FlatButton(
                                            child: Text('Go Back'),
                                            onPressed: () {
                                              Navigator.of(c).pop();
                                            },
                                          )
                                        ],
                                      ));
                            },
                          ),
                          FlatButton(
                            child: Text('Modify'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamed(AddEventScreen.routeName,arguments: {
                                'gUser' : gUser,
                                'isModify' : true,
                                'eventData' : Event(
                                  eventName: eventName,
                                  location: eventLocation,
                                  startDate: startDate,
                                  startTime: TimeOfDay.fromDateTime(startDate),
                                  ticketPrice: ticketPrice,
                                  eventID: eventID,
                                ),
                              });
                            },
                          ),
                        ],
                      ));
            },
      leading: CircleAvatar(
        child: Text(eventName[0]),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            eventName,
            style: GoogleFonts.notoSans(),
          ),
          if (!access)
            Container(
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    'Requested Access',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  )),
            ),
          if (role == 'admin')
            Container(
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    'Administrator',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  )),
            ),
          if (role == 'org')
            Container(
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    'Organizer',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  )),
            ),
        ],
      ),
      subtitle: Text(
        eventLocation,
        style: GoogleFonts.notoSans(),
      ),
      trailing: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FittedBox(
          child: Column(
            children: <Widget>[
              Text(
                getDate(startDate),
                style: GoogleFonts.notoSans(fontWeight: FontWeight.w500),
              ),
              Text(
                getMonth(startDate),
                style: GoogleFonts.notoSans(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
