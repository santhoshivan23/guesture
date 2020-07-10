import 'package:flutter/material.dart';
import 'package:guesture/widgets/event_overview_card.dart';
import 'package:guesture/widgets/reservation_counter.dart';

//  const String testDevice = FirebaseAdMob.testAppId;

class DashboardSubScreen extends StatelessWidget {

  final String eventID;
  
  DashboardSubScreen({this.eventID});

  @override
  Widget build(BuildContext context) {
    
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: EventOverviewCard(
              eventID: eventID,
            ),
          ),
  
          ReservationCounter(eventID: eventID),
          
        ],
      ),
    );
  }
}
