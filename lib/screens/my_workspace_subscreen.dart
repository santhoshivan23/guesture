import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:guesture/screens/invite_members_page.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MyWorkspaceSubscreen extends StatelessWidget {
  final String eventID;
  final bool isAdmin;

  MyWorkspaceSubscreen({this.eventID, this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.deepPurple,
          icon: Icon(MdiIcons.plusCircleMultiple),
          onPressed: () {
            Navigator.of(context)
                .pushNamed(InviteMembersPage.routeName, arguments: eventID);
          },
          label: Text('Invite Members')),
    );
  }
}
