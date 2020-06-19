import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guesture/models/event.dart';
import 'package:guesture/models/g_user.dart';
import 'package:guesture/providers/auth.dart';
import 'package:guesture/providers/guesture_db.dart';
import 'package:guesture/screens/add_event_screen.dart';
import 'package:guesture/screens/manage_standard.dart';
import 'package:guesture/widgets/event_tile.dart';
import 'package:guesture/widgets/guesture_avatar.dart';
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
        print(wID);
        final result =
            await GuestureDB.requestToJoinWorkspace(wID, widget.gUser.uid);
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
      appBar: AppBar(
        title: const Text('My Events'),
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
      drawer: GuestureDrawer(gUser: widget.gUser),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        child: StreamBuilder(
          stream: Firestore.instance.collection('events')

              ///.where('uid', isEqualTo: gUser.uid)
              .where('members.' + widget.gUser.uid,
                  whereIn: ['admin', 'moderator','requested']).snapshots(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());
            var eventsData = (snapshot.data.documents as List)
                .map((e) => Event(
                      eventName: e['eventName'],
                      location: e['location'],
                      startDate: DateTime.parse(e['startDT']),
                      eventID: e.documentID,
                      startTime: TimeOfDay.fromDateTime(
                        DateTime.parse(e['startDT']),
                      ),
                      ticketPrice: e['ticketPrice'],
                    ))
                .toList();
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
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: eventsData.length,
                    itemBuilder: (ctx, index) => EventTile(
                      eventID: eventsData[index].eventID,
                      eventLocation: eventsData[index].location,
                      eventName: eventsData[index].eventName,
                      startDate: eventsData[index].startDate,
                      isAdmin: widget.gUser.isAdmin,
                    ),
                  );
          },
        ),
      ),
      floatingActionButton: !widget.gUser.isAdmin
          ? null
          : FloatingActionButton(
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(AddEventScreen.routeName,
                    arguments: widget.gUser);
              }),
    );
  }
}

class GuestureDrawer extends StatelessWidget {
  final GUser gUser;

  GuestureDrawer({this.gUser});
  @override
  Widget build(BuildContext context) {
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
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GuestureAvatar(
                  gUser.photoUrl, gUser.displayName, gUser.email),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(
                  gUser.displayName == null ? 'NA' : gUser.displayName,
                  textAlign: TextAlign.center,
                ),
                subtitle: Text(
                  gUser.email,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                onTap: () {
                  Navigator.of(context).pop();
                  // Navigator.of(context)
                  //     .pushNamed(ManageStandard.routeName, arguments: gUser);
                },
                leading: Icon(MdiIcons.bell, color: Colors.orange),
                title: Text(
                  'Notifications',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                onTap: () {
                  Navigator.of(context).pop();
                  // Navigator.of(context)
                  //     .pushNamed(ManageStandard.routeName, arguments: gUser);
                },
                leading: Icon(MdiIcons.security, color: Colors.green),
                title: Text(
                  'Privacy Policy',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
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
                                  'v1.0.0',
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
                                                    Icons.developer_mode,
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
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: Icon(
                  Icons.power_settings_new,
                  color: Colors.red,
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await Auth().logout();
                },
                title: Text(
                  'Log Out',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
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
