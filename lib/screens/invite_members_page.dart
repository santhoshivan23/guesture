import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
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
      link = eventDoc.data['inviteLinkB'];
    }
    return link;
  }

  @override
  Widget build(BuildContext context) {
    final eventID = ModalRoute.of(context).settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        title: Text('Invite Members'),
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
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
                child: Column(
              children: [
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    RaisedButton.icon(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.deepPurple,
                      onPressed: () async {
                        String link = await _fetchInviteLink(eventID, 'admin');
                        FlutterShare.share(
                            title: 'Share Invite Link',
                            linkUrl: link,
                            text:
                                'Hey! Click this link and join my workspace on Guesture!');
                      },
                      icon: Icon(
                        MdiIcons.linkVariant,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Invite as Admin',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    RaisedButton.icon(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: Colors.deepPurple,
                      onPressed: () async {
                        String link =
                            await _fetchInviteLink(eventID, 'organizer');
                        FlutterShare.share(
                            title: 'Share Invite Link',
                            linkUrl: link,
                            text:
                                'Hey! Click this link and join my workspace on Guesture!');
                      },
                      icon: Icon(
                        MdiIcons.linkVariant,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Invite as Organizer',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  color: Colors.black54,
                  thickness: 0.5,
                  height: 5,
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }
}
