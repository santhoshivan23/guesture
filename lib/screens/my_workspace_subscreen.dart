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
  int membersCount;
  Map<String, dynamic> membersMap;
  MyWorkspaceSubscreen({this.eventID, this.isAdmin, this.eventName,});
  List<WorkspaceMember> members = [];
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  // Future<void> fetchGUsers() async {
  //   final eventRef =
  //       await Firestore.instance.collection('events').document(eventID).get();
  //   Map<String, dynamic> membersMap = eventRef.data['members'];
  //   final uids = membersMap.keys.toList();
  //   for (var uid in uids) {
  //     final gUser = await GuestureDB.getGUserFromUid(uid);
  //     final role = await GuestureDB.getRole(uid, eventID);
  //     final ticketsSold = await GuestureDB.getTicketsSoldByUid(uid, eventID);

  //     members.add(
  //         WorkspaceMember(gUser: gUser, role: role, ticketsSold: ticketsSold));
  //   }
  //   final me = await FirebaseAuth.instance.currentUser();
  //   myUid = me.uid;
  // }

  @override
  Widget build(BuildContext context) {
    int membersCount;
    return Scaffold(
      key : _key,
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('events')
              .document(eventID)
              .snapshots(),
          builder: (context, snapshot) {
            print(snapshot.connectionState);
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LinearProgressIndicator(
                backgroundColor: Colors.green,
              );
            }
            
            membersMap = (snapshot.data['members'] as Map<String, dynamic>);
            membersCount = membersMap.length;
            membersMap.forEach((key, value) {
              members.add(WorkspaceMember(
                uid: key,
                role: value['role'],
                ticketsSold:
                    value['ticketsSold'] == null ? 0 : value['ticketsSold'],
              
              ));
            });
            members.sort((WorkspaceMember a, WorkspaceMember b) => (a.role == 'admin' && b.role != 'admin') ? 0 : 1);

            return ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: membersMap.length,
              itemBuilder: (ctx, index) => MembersTile(
                member: members[index],
                eventID: eventID,
             
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
                
                if(membersCount >= 6) {
                  _key.currentState.showSnackBar(SnackBar(content: Text('Maximum no. of members reached. (6)',textAlign: TextAlign.center,),),);
                  return;
                }
                Navigator.of(context).pushReplacementNamed(
                    InviteMembersPage.routeName,
                    arguments: {
                      'eventID': eventID,
                      'eventName': eventName,
                    });
              },
              label: Text('Invite People'))
          : null,
    );
  }
}
