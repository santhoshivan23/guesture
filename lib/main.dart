import 'package:firebase_admob/firebase_admob.dart';
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
import 'package:guesture/screens/notifications_screen.dart';
import 'package:guesture/screens/onboarding_scree.dart';
import 'package:guesture/screens/profile_page.dart';
import 'package:guesture/screens/qr_screen.dart';
import 'package:provider/provider.dart';

import 'models/g_user.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
          AuthScreen.routeName: (ctx) => AuthScreen(),
          ProfilePage.routeName: (ctx) => ProfilePage(),
          MyEventsScreen.routeName: (ctx) => MyEventsScreen(),
          AddEventScreen.routeName: (ctx) => AddEventScreen(),
          EventOverviewScreen.routeName: (ctx) => EventOverviewScreen(),
          NewReservationScreen.routeName: (ctx) => NewReservationScreen(),
          CashConfirmScreen.routeName: (ctx) => CashConfirmScreen(),
          QRScreen.routeName: (ctx) => QRScreen(),
          InviteMembersPage.routeName: (ctx) => InviteMembersPage(),
          NotificationsScreen.routeName: (ctx) => NotificationsScreen(),
        },
      ),
    );
  }
}

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<GUser>(context);
    if (user == null)
      return OnboardingScreen();
    else
      return MyEventsScreen(
        gUser: user,
      );
  }
}
