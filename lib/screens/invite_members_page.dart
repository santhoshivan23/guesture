import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:guesture/models/g_user.dart';
import 'package:guesture/providers/guesture_db.dart';
import 'package:guesture/widgets/user_tile.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class InviteMembersPage extends StatelessWidget {
  static const routeName = '/invite-members';
  Future<String> _fetchInviteLink(String eventID, String role) async {
    String link;
    if (role == 'admin') {
      final eventDoc =
          await Firestore.instance.collection('events').document(eventID).get();
      link = eventDoc.data['inviteLinkA'];
    } else {
      final eventDoc =
          await Firestore.instance.collection('events').document(eventID).get();
      link = eventDoc.data['inviteLinkO'];
    }
    return link;
  }

  Future<void> shareLink(String eventID, String role) async {
    String link = await _fetchInviteLink(eventID, role);
    FlutterShare.share(
        title: 'Share Invite Link',
        linkUrl: link,
        text: 'Hey! Click this link and join my workspace on Guesture!');
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context).settings.arguments as Map<String,String>;
    final eventID = args['eventID'];
    final eventName = args['eventName'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Invite People'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple,
                Colors.deepPurple.withOpacity(0.5),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                  child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Send a request now',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '(Recommended)',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple),
                    ),
                  ),
                  Text(
                    'If the person is already on Guesture, you can invite them right away. Once they accept your invite, they\'ll become member of this workspace.',
                    textAlign: TextAlign.center,
                  ),
                  SearchUsers(eventID: eventID,eventName: eventName),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.black,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'OR',
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Invite through link',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Anyone with the link will be able to join your workspace once you accept their request.',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  buildRaisedButton(eventID, 'admin'),
                  buildRaisedButton(eventID, 'org'),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  Container buildRaisedButton(String eventID, String role) {
    return Container(
      width: 250,
      child: RaisedButton.icon(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: role == 'admin' ? Colors.green : Colors.orange,
        onPressed: () => shareLink(eventID, role),
        icon: Icon(
          role == 'admin' ? MdiIcons.linkVariantPlus : MdiIcons.linkVariant,
          color: Colors.white,
        ),
        label: Text(
          role == 'admin' ? 'Invite as Administrator' : 'Invite as Organizer',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class SearchUsers extends StatefulWidget {
  final String eventID;
  final String eventName;
  SearchUsers({this.eventID,this.eventName});
  @override
  _SearchUsersState createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> {
  bool status = false;
  String message = 'Type an email address to send an invite';
  bool isRequested;
  String inviteStatus;
  GUser gUser;
  bool searching = false;
  Future<void> searchUser(String email) async {
    if (!RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email)) {
      setState(() {
        status = false;
        searching = false;
        message = "Enter a valid email";
      });
      return;
    } else {
      setState(() {
        searching = true;
      });
      final x = await GuestureDB.getGUserFromEmail(email);
      if (x == null) {
        setState(() {
          searching = false;
          status = false;
          message = "User Not found";
        });
        return;
      } else {
        String y = await GuestureDB.getInviteStatus(widget.eventID, x.uid);

        setState(() {
          gUser = x;
          inviteStatus = y;
          searching = false;
          status = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.search,
          
            onSubmitted: (email) => searchUser(email),
            decoration: InputDecoration(
            
              suffixIcon: Icon(MdiIcons.magnify),
              hintText: "Enter email address",
            ),
          ),
        ),
        Container(
            height: 100,
            child: searching
                ? Center(child: LinearProgressIndicator())
                : status
                    ? UserTile(
                        gUser: gUser,
                        inviteStatus: inviteStatus,
                        eventID: widget.eventID,
                        eventName : widget.eventName,
                      )
                    : Center(child: Text(message)))
      ],
    );
  }
}
