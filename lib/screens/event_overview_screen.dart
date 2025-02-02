import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:guesture/screens/checkin_subscreen.dart';
import 'package:guesture/screens/dashboard_subscreen.dart';
import 'package:guesture/screens/finance_subscreen.dart';
import 'package:guesture/screens/my_workspace_subscreen.dart';
import 'package:guesture/screens/reservations_subscreen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class EventOverviewScreen extends StatefulWidget {
  static const routeName = '/event-overview';

  @override
  _EventOverviewScreenState createState() => _EventOverviewScreenState();
}

class _EventOverviewScreenState extends State<EventOverviewScreen> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final eventData =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    final eventID = eventData['eventID'];
    final eventName = eventData['eventName'];
    final bool isAdmin = eventData['isAdmin'];
    final myUid = eventData['myUid'];
    final creatorUid = eventData['creatorUid'];
    List<Widget> screens = [
      DashboardSubScreen(
        eventID: eventID,
      ),
      ReservationsSubScreen(
          eventID: eventID,
          isAdmin: isAdmin,
          myUid: myUid,
          eventName: eventData['eventName']),
      CheckinSubscreen(eventID: eventID),
      FinanceSubscreen(
        eventID: eventID,
        isAdmin: isAdmin,
      ),
      MyWorkspaceSubscreen(
          eventID: eventID,
          isAdmin: isAdmin,
          eventName: eventName,
          creatorUid: creatorUid),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(eventName),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.deepPurple,
              Colors.deepPurple.withOpacity(0.5)
            ]),
          ),
        ),
      ),
      body: screens.elementAt(selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          unselectedItemColor: Colors.deepPurple,
          showUnselectedLabels: true,
          fixedColor: Colors.deepPurple,
          currentIndex: selectedIndex,
          items: [
            BottomNavigationBarItem(
                activeIcon: Icon(MdiIcons.information),
                icon: Icon(MdiIcons.informationOutline),
                label: 'Dashboard',
                backgroundColor: Colors.white),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Guests',
            ),
            BottomNavigationBarItem(
              icon: Icon(MdiIcons.sendCircleOutline),
              activeIcon: Icon(MdiIcons.sendCircle),
              label: 'Check-In',
            ),
            BottomNavigationBarItem(
              icon: Icon(MdiIcons.walletOutline),
              activeIcon: Icon(MdiIcons.wallet),
              label: 'Finance',
            ),
            BottomNavigationBarItem(
              icon: Icon(MdiIcons.homeCityOutline),
              activeIcon: Icon(MdiIcons.homeCity),
              label: 'Workspace',
            ),
          ]),
    );
  }
}
