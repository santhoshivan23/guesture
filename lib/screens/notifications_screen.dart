import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guesture/models/g_notification.dart';
import 'package:guesture/models/g_user.dart';
import 'package:guesture/models/guest.dart';
import 'package:guesture/providers/guesture_db.dart';
import 'package:guesture/widgets/guesture_avatar.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatelessWidget {
  static const routeName = '/notifications';
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final uid = ModalRoute.of(context).settings.arguments as String;
    return Scaffold(
        key: _key,
        appBar: AppBar(
          title: const Text('Notifications'),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Colors.deepPurple,
                Colors.deepPurple.withOpacity(0.5)
              ]),
            ),
          ),
        ),
        body: StreamBuilder(
          stream: Firestore.instance
              .collection('users')
              .document(uid)
              .collection('notifications')
              .orderBy('timestamp', descending: true)
              .limit(10)
              .snapshots(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());
            final notifs = (snapshot.data.documents as List<DocumentSnapshot>)
                .map((e) => GNotification(
                      id: e.documentID,
                      type: e.data['type'],
                      title: e.data['title'],
                      content: e.data['content'],
                      eventID: e.data['eventID'],
                      role: e.data['role'],
                      timestamp: e.data['timestamp'],
                    ))
                .toList();
            return ListView.builder(
                itemCount: notifs.length,
                itemBuilder: (ctx, index) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GNotificationTile(
                        notification: notifs[index],
                        uid: uid,
                      ),
                    ));
          },
        ));
  }
}

class GNotificationTile extends StatefulWidget {
  final GNotification notification;
  final String uid;

  GNotificationTile({
    this.uid,
    this.notification,
  });

  @override
  _GNotificationTileState createState() => _GNotificationTileState();
}

class _GNotificationTileState extends State<GNotificationTile> {
  bool loading = false;

  Future<void> handleClick(
    String uid,
    GNotification notification,
    bool accept,
  ) async {
    setState(() {
      loading = true;
    });

    if (accept) {
      await GuestureDB.updateRole(uid, notification.eventID, notification.role);

      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          'Invitation accepted!',
          textAlign: TextAlign.center,
        ),
      ));
    } else {
      await GuestureDB.updateRole(uid, notification.eventID, 'REMOVE');
      Scaffold.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          'Invitation Rejected!',
          textAlign: TextAlign.center,
        ),
      ));
    }
    await GuestureDB.deleteNotification(uid, notification.id);

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(
            child: LinearProgressIndicator(
            backgroundColor: Colors.white,
          ))
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: CircleAvatar(
                      child: widget.notification.type == 'invite'
                          ? Icon(MdiIcons.pencilBox)
                          : Icon(MdiIcons.offer)),
                  title: Text(
                    widget.notification.title,
                  ),
                  subtitle: Text(
                    widget.notification.content,
                  ),
                  trailing: FittedBox(
                    child: Column(
                      children: [
                        Text(
                          DateFormat.jm().format(
                            DateTime.parse(widget.notification.timestamp),
                          ),
                        ),
                        Text(
                          DateFormat.Md().format(
                            DateTime.parse(widget.notification.timestamp),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (widget.notification.type == 'invite')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: Colors.green,
                      child: Text(
                        'Accept',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () => handleClick(
                        widget.uid,
                        widget.notification,
                        true,
                      ),
                    ),
                    RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        color: Colors.red,
                        child: Text(
                          'Decline',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () => handleClick(
                              widget.uid,
                              widget.notification,
                              false,
                            )),
                  ],
                ),
              Divider(
                thickness: 2,
              ),
            ],
          );
  }
}
