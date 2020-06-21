import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:guesture/models/g_user.dart';
import 'package:guesture/models/workspace_member.dart';
import 'package:guesture/providers/guesture_db.dart';
import 'package:guesture/screens/invite_members_page.dart';
import 'package:guesture/widgets/members_tile.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MyWorkspaceSubscreen extends StatelessWidget {
  final String eventID;
  final bool isAdmin;
  final String eventName;
  String myUid;
  MyWorkspaceSubscreen({this.eventID, this.isAdmin, this.eventName});
  List<WorkspaceMember> members = [];
  Future<void> fetchGUsers() async {
    final eventRef =
        await Firestore.instance.collection('events').document(eventID).get();
    Map<String, dynamic> membersMap = eventRef.data['members'];
    final uids = membersMap.keys.toList();
    for (var uid in uids) {
      final gUser = await GuestureDB.getGUserFromUid(uid);
      final role = await GuestureDB.getRole(uid, eventID);
      final ticketsSold = await GuestureDB.getTicketsSoldByUid(uid, eventID);

      members.add(
          WorkspaceMember(gUser: gUser, role: role, ticketsSold: ticketsSold));
    }
    final me = await FirebaseAuth.instance.currentUser();
    myUid = me.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: fetchGUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator());
            return ListView.builder(
              itemCount: members.length,
              itemBuilder: (ctx, index) => MembersTile(
                member: members[index],
                eventID: eventID,
                myUid: myUid,
                eventName: eventName,
                isAdmin: isAdmin,
              ),
            );
          }),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: Colors.deepPurple,
              icon: Icon(MdiIcons.plusCircleMultiple),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(InviteMembersPage.routeName, arguments: {
                  'eventID': eventID,
                  'eventName': eventName,
                });
              },
              label: Text('Invite People'))
          : null,
    );
  }
}
