import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guesture/providers/guesture_db.dart';
import 'package:guesture/screens/event_overview_screen.dart';
import 'package:intl/intl.dart';


class EventTile extends StatelessWidget {
  final String eventID;
  final String eventName;
  final String eventLocation;
  final DateTime startDate;
  final bool isAdmin;
  EventTile({this.eventName, this.eventID, this.eventLocation, this.startDate,this.isAdmin});

  String getDate(DateTime dt) => DateFormat.d().format(dt);

  String getMonth(DateTime dt) => DateFormat.MMM().format(dt);

  @override
  Widget build(BuildContext context) {
    
    return ListTile(
      onTap: () {
        Navigator.of(context).pushNamed(EventOverviewScreen.routeName,
            arguments: {'eventID': eventID, 'eventName': eventName,'isAdmin' : isAdmin});
      },
      onLongPress: !isAdmin ? null : () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(eventName),
            content: Text('Delete or Modify Event'),
            actions: <Widget>[
              FlatButton(
                child: Text('Delete',style: TextStyle(color: Colors.red),),
                onPressed: () {
                  showDialog(
                    barrierDismissible: false,
                    context: ctx, builder: (c) => AlertDialog(

                    title: Text('Confirm Deletion',style: TextStyle(fontWeight: FontWeight.bold),),
                    content: Text('$eventName and all its data will be permenantly deleted. This action cannot be reverted.'),
                    actions: <Widget>[
                      RaisedButton(
                        color: Colors.red,
                        child:Text('Confirm',style: TextStyle(color: Colors.white),),
                        onPressed: () async{
                          
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          await GuestureDB.deleteEvent(eventID);
                        },
                      ),
                      FlatButton(
                        child:Text('Go Back'),
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
                  
                },
              ),
            ],
          )
        );
      },
      leading: CircleAvatar(
        child: Text(eventName[0]),
      ),
      title: Text(
        eventName,
        style: GoogleFonts.notoSans(),
      ),
      subtitle: Text(
        eventLocation,
        style: GoogleFonts.notoSans(),
      ),
      trailing: Padding(
        padding: const EdgeInsets.all(8.0),
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
    );
  }
}
