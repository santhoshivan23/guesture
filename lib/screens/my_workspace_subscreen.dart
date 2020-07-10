import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guesture/models/workspace_member.dart';
import 'package:guesture/screens/invite_members_page.dart';
import 'package:guesture/widgets/members_tile.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MyWorkspaceSubscreen extends StatefulWidget {
  final String eventID;
  final bool isAdmin;
  final String eventName;
  final String creatorUid;
  MyWorkspaceSubscreen({
    this.eventID,
    this.isAdmin,
    this.eventName,
    this.creatorUid,
  });

  @override
  _MyWorkspaceSubscreenState createState() => _MyWorkspaceSubscreenState();
}

class _MyWorkspaceSubscreenState extends State<MyWorkspaceSubscreen> {
  int membersCount;

  Map<String, dynamic> membersMap;

  List<WorkspaceMember> members = [];

  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  Future<void> fetchGUsers() async {
    final eventDoc = await Firestore.instance
        .collection('events')
        .document(widget.eventID)
        .get();
    Map<String, dynamic> imembersMap = eventDoc.data['members'];
    List<WorkspaceMember> iMembers = [];
    imembersMap.forEach(
      (key, value) {
        iMembers.add(
          WorkspaceMember(
            role: value['role'],
            ticketsSold: value['ticketsSold'],
            uid: key,
          ),
        );
      },
    );

    members = iMembers;
  }

  Future<void> fetchGUsersR() async {
    final eventDoc = await Firestore.instance
        .collection('events')
        .document(widget.eventID)
        .get();
    Map<String, dynamic> imembersMap = eventDoc.data['members'];
    List<WorkspaceMember> iMembers = [];
    imembersMap.forEach(
      (key, value) {
        iMembers.add(
          WorkspaceMember(
            role: value['role'],
            ticketsSold: value['ticketsSold'],
            uid: key,
          ),
        );
      },
    );
    setState(() {
      members = iMembers;
    });
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      key: _key,
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('events')
              .document(widget.eventID)
              .snapshots(),
          builder: (context, snapshot) {
            print(snapshot.connectionState);
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LinearProgressIndicator(
                backgroundColor: Colors.green,
              );
            }
            membersMap = snapshot.data['members'];
             members = [];
            membersMap.forEach(
              (key, value) {
                members.add(
                  WorkspaceMember(
                    role: value['role'],
                    ticketsSold: value['ticketsSold'],
                    uid: key,
                  ),
                );
              },
            );
            members.sort((WorkspaceMember a, WorkspaceMember b ){
              return (a.role == 'admin' && b.role != 'admin') ?  0 : 1;
            });
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: members.length,
              itemBuilder: (ctx, index) => MembersTile(
                member: members[index],
                eventID: widget.eventID,
                eventName: widget.eventName,
                isAdmin: widget.isAdmin,
                creatorUid: widget.creatorUid,
              ),
            );
          }),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: Colors.deepPurple,
              icon: Icon(MdiIcons.plusCircleMultiple),
              onPressed: () {
                if (members.length >= 6) {
                  _key.currentState.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Maximum no. of members reached. (6)',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                  return;
                }
                Navigator.of(context).pushNamed(
                    InviteMembersPage.routeName,
                    arguments: {
                      'eventID': widget.eventID,
                      'eventName': widget.eventName,
                    });
              },
              label: Text('Invite People'))
          : null,
    );
  }
}
