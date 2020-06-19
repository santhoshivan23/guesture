import 'package:flutter/material.dart';
import 'package:guesture/providers/auth.dart';
import 'package:guesture/screens/add_event_screen.dart';
import 'package:guesture/screens/auth_screen.dart';
import 'package:guesture/screens/cash_confirm_screen.dart';
import 'package:guesture/screens/event_overview_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:guesture/screens/invite_members_page.dart';
import 'package:guesture/screens/my_events_screen.dart';
import 'package:guesture/screens/new_reservation_screen.dart';
import 'package:guesture/screens/qr_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return StreamProvider.value(
      value: Auth().authenticatedState,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          textTheme: GoogleFonts.notoSansTextTheme(),
        ),
        home: Wrapper(),
        routes: {
          // ManageStandard.routeName: (ctx) => ManageStandard(),
          MyEventsScreen.routeName: (ctx) => MyEventsScreen(),
          AddEventScreen.routeName: (ctx) => AddEventScreen(),
          EventOverviewScreen.routeName: (ctx) => EventOverviewScreen(),
          NewReservationScreen.routeName: (ctx) => NewReservationScreen(),
          CashConfirmScreen.routeName: (ctx) => CashConfirmScreen(),
          QRScreen.routeName: (ctx) => QRScreen(),
          InviteMembersPage.routeName : (ctx) => InviteMembersPage(),
        },
      ),
    );
  }
}

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authenticatedState,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: FittedBox(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'G',
                        style: GoogleFonts.pacifico(
                            color: Colors.white, fontSize: 30),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (!snapshot.hasData) return AuthScreen();
        return MyEventsScreen(gUser: snapshot.data,);
      },
    );
  }
}
