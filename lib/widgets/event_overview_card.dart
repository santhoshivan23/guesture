import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EventOverviewCard extends StatelessWidget {
  final String eventID;

  String getDate(DateTime dt) => DateFormat.d().format(dt);

  String getMonth(DateTime dt) => DateFormat.MMM().format(dt);

  String getTime(TimeOfDay td) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, td.hour, td.minute);
    return DateFormat.jm().format(dt).toString();
  }

  EventOverviewCard({this.eventID});
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    
    return StreamBuilder(
      stream: Firestore.instance.collection('events').document(eventID).snapshots(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) return Text('Loading...');
        return Container(
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
              if(DateTime.now().subtract(Duration(hours: 1)).isAfter(DateTime.parse(snapshot.data['startDT'])))
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                
                color: Colors.red,
                child: Text(
                  'This event has been completed',
                  style: GoogleFonts.notoSans(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: height * 0.012, horizontal: height * 0.001),
                
                color: Colors.indigo,
                child: Text(
                  'Event Overview',
                  style: GoogleFonts.notoSans(color: Colors.white),
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
                    'Starting Date',
                    textAlign: TextAlign.center,
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(getDate(DateTime.parse(snapshot.data['startDT'])) + ' '),
                      Text(getMonth(DateTime.parse(snapshot.data['startDT'])) + '  '),
                    ],
                  ),
                  trailing: 
                  DateTime.now().subtract(Duration(hours: 1)).isBefore(DateTime.parse(snapshot.data['startDT'])) ?
                   Padding(
                    padding:  EdgeInsets.all(height * 0.001),
                    child: Column(
                      children: <Widget>[
                        Text(
                              DateTime.parse(snapshot.data['startDT'])
                              .difference(DateTime.now())
                              .inDays
                              .toString(),
                          style: GoogleFonts.notoSans(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Days to go',
                          style: GoogleFonts.notoSans(
                              fontWeight: FontWeight.w500, fontSize: 9),
                        ),
                      ],
                    ),
                  ) : SizedBox(width: height * 0.083,),
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
                    'Starting Time',
                    textAlign: TextAlign.center,
                  ),
                  subtitle: Text(
                    getTime(TimeOfDay.fromDateTime(DateTime.parse(snapshot.data['startDT']))),
                    textAlign: TextAlign.center,
                  ),
                  trailing:   DateTime.now().subtract(Duration(hours: 1)).isBefore(DateTime.parse(snapshot.data['startDT'])) ?Padding(
                    padding:  EdgeInsets.all(height * 0.009),
                    child: Column(
                      children: <Widget>[
                        Text(
                          DateTime.parse(snapshot.data['startDT'])
                              .difference(DateTime.now())
                              .inHours
                              .toString(),
                          style: GoogleFonts.notoSans(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Hours to go',
                          style: GoogleFonts.notoSans(
                              fontWeight: FontWeight.w500, fontSize: 9),
                        ),
                      ],
                    ),
                  ) : SizedBox(width: height * 0.083,),
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
                    'Ticket Price',
                    textAlign: TextAlign.center,
                  ),
                  subtitle: Text(
                    'Cost of each ticket',
                    textAlign: TextAlign.center,
                  ),
                  trailing: Padding(
                    padding:  EdgeInsets.symmetric(horizontal : height * 0.018),
                    child: Text(
                      snapshot.data['ticketPrice'].toString(),
                      
                    ),
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
                    textAlign: TextAlign.center,
                  ),
                  subtitle: Text(
                    snapshot.data['location'],
                    textAlign: TextAlign.center,
                  ),
                  trailing: SizedBox(
                    width: height * 0.073,
                  ),
                ),
              ),
              
            ],
          ),
        );
      }
    );
  }
}
