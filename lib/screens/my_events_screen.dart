import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guesture/models/event.dart';
import 'package:guesture/models/g_user.dart';
import 'package:guesture/providers/auth.dart';
import 'package:guesture/providers/guesture_db.dart';
import 'package:guesture/screens/add_event_screen.dart';
import 'package:guesture/screens/notifications_screen.dart';
import 'package:guesture/screens/profile_page.dart';
import 'package:guesture/widgets/event_tile.dart';
import 'package:guesture/widgets/guesture_avatar.dart';
import 'package:guesture/widgets/notif_counter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MyEventsScreen extends StatefulWidget {
  final GUser gUser;
  MyEventsScreen({this.gUser});
  static const routeName = '/my-events';

  @override
  _MyEventsScreenState createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  var _filterindex = 0;
  BannerAd _bannerAd;
  final _key = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    fetchLinkData();
    super.initState();
  }

  void fetchLinkData() async {
    var link = await FirebaseDynamicLinks.instance.getInitialLink();

    handleLinkData(link);

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
      handleLinkData(dynamicLink);
    });
  }

  void showLinkDialog(
    String title,
    String content,
    Icon icon,
  ) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              title: Column(
                children: [
                  icon,
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(title),
                  ),
                ],
              ),
              content: Text(content),
              actions: [
                FlatButton(
                  child: Text('Okay!'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            ));
  }

  void handleLinkData(PendingDynamicLinkData data) async {
    final Uri uri = data?.link;

    if (uri != null) {
      final queryParams = uri.queryParameters;
      if (queryParams.length > 0) {
        String wID = queryParams['wID'];
        String role = queryParams['role'];
        print(wID);
        final result = await GuestureDB.requestToJoinWorkspace(
            wID, widget.gUser.uid, role);
        if (result == 1) {
          showLinkDialog(
            'Welcome',
            'You will get access to the workspace once the administrator accepts your request. Sit back and relax!',
            Icon(
              Icons.done,
              color: Colors.green,
              size: 30,
            ),
          );
        } else if (result == 0) {
          showLinkDialog(
            'Oops',
            'You are already a part of this workspace.',
            Icon(
              MdiIcons.information,
              color: Colors.red,
              size: 30,
            ),
          );
        } else {
          showLinkDialog(
            'Request pending!',
            'You had already requested access to this workspace. Please wait for the administrator to accept your request.',
            Icon(
              MdiIcons.information,
              color: Colors.red,
              size: 30,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(bottom: 18.0),
          child: const Text('My Events'),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.deepPurple,
              Colors.deepPurple.withOpacity(0.5)
            ]),
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: PopupMenuButton(
                child: Icon(Icons.filter_list),
                onSelected: (index) {
                  setState(() {
                    _filterindex = index;
                  });
                },
                itemBuilder: (_) => [
                      PopupMenuItem(
                        child: Text('All Events'),
                        value: 0,
                      ),
                      PopupMenuItem(
                        child: Text('Upcoming Events'),
                        value: 1,
                      ),
                      PopupMenuItem(
                        child: Text('Past Events'),
                        value: -1,
                      ),
                    ]),
          )
        ],
      ),
      drawer: GuestureDrawer(homeKey: _key),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0.0),
        child: StreamBuilder(
          stream: Firestore.instance.collection('events')

              ///.where('uid', isEqualTo: gUser.uid)
              .where('members.${widget.gUser.uid}.role', whereIn: [
            'admin',
            'org',
            'requested-admin',
            'requested-org'
          ]).snapshots(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());
            var eventsData = (snapshot.data.documents as List)
                .map((e) => Event(
                      eventName: e['eventName'],
                      uid: e['uid'],
                      location: e['location'],
                      startDate: DateTime.parse(e['startDT']),
                      eventID: e.documentID,
                      startTime: TimeOfDay.fromDateTime(
                        DateTime.parse(e['startDT']),
                      ),
                      ticketPrice: e['ticketPrice'],
                      access: e['members'][widget.gUser.uid]
                              .toString()
                              .contains('requested')
                          ? false
                          : true,
                      role: !e['members'][widget.gUser.uid]
                              .toString()
                              .contains('requested')
                          ? e['members'][widget.gUser.uid]
                                  .toString()
                                  .contains('admin')
                              ? 'admin'
                              : 'org'
                          : null,
                    ))
                .toList();
            eventsData
                .sort((Event a, Event b) => a.eventName.compareTo(b.eventName));
            if (_filterindex == -1)
              eventsData = eventsData
                  .where(
                      (element) => element.startDate.isBefore(DateTime.now()))
                  .toList();
            if (_filterindex == 1)
              eventsData = eventsData
                  .where((element) => element.startDate.isAfter(DateTime.now()))
                  .toList();

            return eventsData.length == 0
                ? _filterindex == -1
                    ? Center(
                        child: Text('None of your events had completed'),
                      )
                    : _filterindex == 1
                        ? Center(
                            child: Text('You don\'t have any upcoming events'),
                          )
                        : Center(
                            child: Text(widget.gUser.isAdmin
                                ? 'You don\'t have any events. Start Organizing!'
                                : 'Your administrator hasn\'t created any event.'),
                          )
                : Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurple,
                              Colors.deepPurple.withOpacity(0.5),
                              Colors.indigo
                            ],
                            end: Alignment.bottomCenter,
                            begin: Alignment.topCenter,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(30)),
                            color: Colors.white),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            shrinkWrap: false,
                            itemCount: eventsData.length,
                            itemBuilder: (ctx, index) => EventTile(
                              eventID: eventsData[index].eventID,
                              eventLocation: eventsData[index].location,
                              eventName: eventsData[index].eventName,
                              startDate: eventsData[index].startDate,
                              access: eventsData[index].access,
                              isAdmin: widget.gUser.isAdmin,
                              role: eventsData[index].role,
                              myUid: widget.gUser.uid,
                              ticketPrice: eventsData[index].ticketPrice,
                              creatorUid: eventsData[index].uid,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      floatingActionButton: FloatingActionButton(
          mini: true,
          backgroundColor: Colors.pink.withBlue(100),
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.of(context)
                .pushNamed(AddEventScreen.routeName, arguments: {
              'gUser': widget.gUser,
              'isModify': false,
            });
          }),
    );
  }
}

class GuestureDrawer extends StatelessWidget {
  final GlobalKey<ScaffoldState> homeKey;
  GuestureDrawer({this.homeKey});

  void _toPrivacyPolicy() async {
    const url =
        'https://github.com/santhoshivan23/guesture_privacy_policy/blob/master/privacy_policy.txt';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final gUser = Provider.of<GUser>(context);
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      decoration: BoxDecoration(color: Colors.white),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'G',
            style: GoogleFonts.pacifico(),
          ),
          backgroundColor: Colors.deepPurple.withBlue(200),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .pushNamed(ProfilePage.routeName, arguments: homeKey);
                },
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(height * 0.01),
                      child: GuestureAvatar(gUser.photoUrl, gUser.displayName,
                          gUser.email, height * 0.06),
                    ),
                    ListTile(
                      title: Text(
                        gUser.displayName == null
                            ? gUser.email.split('@')[0]
                            : gUser.displayName,
                        textAlign: TextAlign.center,
                      ),
                      subtitle: Text(
                        gUser.email,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (ctx) => SimpleDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      titlePadding: EdgeInsets.all(6),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'G+',
                            style: GoogleFonts.pacifico(color: Colors.pink),
                          ),
                          Text(
                            'Guesture Prime',
                            textAlign: TextAlign.center,
                            style:
                                GoogleFonts.pacifico(color: Colors.deepPurple),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(height * 0.007),
                          child: Text(
                            "Enjoy exclusive benefits!",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        buildFeaturesPrime('  -   Ad-free'),
                        buildFeaturesPrime(
                            '  -   Unlimited members in workspace'),
                        buildFeaturesPrime(
                            '  -   Generate class of tickets with multiple prices'),
                        buildFeaturesPrime(
                            '  -   Receive payments through UPI'),
                        buildFeaturesPrime('                 and much more'),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.pink,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Text(
                                  'Stay tuned!',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                leading: Text(
                  'G+',
                  style: GoogleFonts.pacifico(color: Colors.pink),
                ),
                title: Text(
                  'Guesture Prime',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pacifico(color: Colors.deepPurple),
                ),
                subtitle: Text(
                  'Enjoy exclusive benefits!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10),
                ),
              ),
              Divider(
                height: 1,
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(NotificationsScreen.routeName,
                      arguments: gUser.uid);
                  // Navigator.of(context)
                  //     .pushNamed(ManageStandard.routeName, arguments: gUser);
                },
                leading: NotifCounter(),
                title: Text(
                  'Notifications',
                  textAlign: TextAlign.center,
                ),
              ),
              Divider(
                height: 1,
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).pop();
                  _toPrivacyPolicy();
                },
                leading: Icon(MdiIcons.security, color: Colors.green),
                title: Text(
                  'Privacy Policy',
                  textAlign: TextAlign.center,
                ),
              ),
              Divider(
                height: 1,
              ),
              ListTile(
                leading: Icon(Icons.info, color: Colors.blue),
                onTap: () {
                  Navigator.of(context).pop();
                  showDialog(
                      context: context,
                      builder: (ctx) => SimpleDialog(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    'G',
                                    style: GoogleFonts.pacifico(),
                                  ),
                                ),
                                Text(
                                  'Guesture',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  'v2.0.0',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(
                                  'Developed by \n Santhoshivan, MIT Manipal',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: GestureDetector(
                                  onTap: _toLinkedInPage,
                                  child: Center(
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.indigo,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: FittedBox(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: <Widget>[
                                                  Icon(
                                                    MdiIcons.linkedin,
                                                    color: Colors.white,
                                                  ),
                                                  Text(
                                                    'LinkedIn Profile ',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )),
                                  ),
                                ),
                              ),
                            ],
                          ));
                },
                title: Text(
                  'About Guesture',
                  textAlign: TextAlign.center,
                ),
              ),
              Divider(
                height: 1,
              ),
              ListTile(
                leading: Icon(
                  Icons.power_settings_new,
                  color: Colors.red,
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await Auth().logout(gUser.uid);
                },
                title: Text(
                  'Log Out',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding buildFeaturesPrime(String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      child: Text(
        content,
        style: TextStyle(fontSize: 12),
      ),
    );
  }

  void _toLinkedInPage() async {
    const url = 'https://www.linkedin.com/in/santhoshivan-a-5766a89a';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      return;
    }
  }
}
