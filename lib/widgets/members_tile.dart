
import 'package:flutter/material.dart';
import 'package:guesture/models/g_notification.dart';
import 'package:guesture/models/g_user.dart';
import 'package:guesture/models/workspace_member.dart';
import 'package:guesture/providers/guesture_db.dart';
import 'package:guesture/widgets/guesture_avatar.dart';
import 'package:provider/provider.dart';

class MembersTile extends StatelessWidget {
  final WorkspaceMember member;
  final String eventID;
  final String eventName;
  final bool isAdmin;
  final String creatorUid;
  final int count;

  MembersTile({
    this.member,
    this.eventID,
    this.eventName,
    this.isAdmin,
    this.creatorUid,
    this.count,
  });

  GUser gUser;

  Future<void> _acceptInvite(BuildContext context) async {
    if (count > 6) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Maximum no. of members reached. (6)',
            textAlign: TextAlign.center,
          ),
        ),
      );
      return;
    }
    if (member.role.contains('admin')) {
      await GuestureDB.updateRole(gUser.uid, eventID, 'admin');
    } else {
      await GuestureDB.updateRole(gUser.uid, eventID, 'org');
    }
    await GuestureDB.pushNotification(
        GNotification(
            type: 'role-change',
            title: '$eventName · Role updated',
            content: 'Your request to join the workspace has been accepted',
            timestamp: DateTime.now().toIso8601String()),
        [gUser.uid]);
  }

  Future<void> _handleTap(
      String uid, BuildContext context, String creatorUid) async {
    print(uid);
    showDialog(
      context: context,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: FittedBox(
            child: GuestureAvatar(
                gUser.photoUrl, gUser.displayName, gUser.email, 25)),
        content: Text(
          gUser.displayName == null ? 'NA' : gUser.displayName,
          textAlign: TextAlign.center,
        ),
        actions: [
          if (member.role == 'admin' && uid != member.uid)
            GestureDetector(
              onTap: () async {
                Navigator.of(context).pop();
                final res =
                    await GuestureDB.updateRole(gUser.uid, eventID, 'org');

                if (res != 0) {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Role Updated!',
                        textAlign: TextAlign.center,
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  await GuestureDB.pushNotification(
                      GNotification(
                        title: '$eventName · Role updated',
                        content: 'You are now an organizer',
                        type: 'role-change',
                        timestamp: DateTime.now().toIso8601String(),
                      ),
                      [gUser.uid]);
                } else {
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Role of creator cannot be changed',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
              },
              child: RoleChip(
                color: Colors.orange,
                role: 'Make as organizer',
                fontSize: 12,
              ),
            ),
          if (member.role == 'org' && isAdmin)
            GestureDetector(
              onTap: () async {
                Navigator.of(context).pop();

                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Role Updated!',
                      textAlign: TextAlign.center,
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
                await GuestureDB.updateRole(gUser.uid, eventID, 'admin');
                await GuestureDB.pushNotification(
                    GNotification(
                      title: '$eventName · Role updated',
                      content: 'You are now an Administrator',
                      type: 'role-change',
                      timestamp: DateTime.now().toIso8601String(),
                    ),
                    [gUser.uid]);
              },
              child: RoleChip(
                color: Colors.green,
                role: 'Make as admin',
                fontSize: 12,
              ),
            ),
          GestureDetector(
            onTap: () async {
              // Navigator.of(context).pop();
              // if (uid == member.uid && uid != creatorUid) {

              //   Navigator.of(context).pop();

              // }
              // final result =
              //     await GuestureDB.updateRole(gUser.uid, eventID, 'REMOVE');
              // if (uid != member.uid) {
              //   if (result == 1) {
              //     Scaffold.of(context).showSnackBar(
              //       SnackBar(
              //         content: Text(
              //           'Removed from workspace!',
              //           textAlign: TextAlign.center,
              //         ),
              //         backgroundColor: Colors.red,
              //       ),
              //     );

              //     await GuestureDB.pushNotification(
              //         GNotification(
              //           title: eventName,
              //           content: 'You have been removed from the workspace',
              //           type: 'role-change',
              //           timestamp: DateTime.now().toIso8601String(),
              //         ),
              //         [gUser.uid]);
              //   } else {
              //     Scaffold.of(context).showSnackBar(
              //       SnackBar(
              //         content: Text(
              //           'Creator of workspace cannot be removed',
              //           textAlign: TextAlign.center,
              //         ),
              //       ),
              //     );
              //   }
              // } else {
              //   return;
              // }
              Navigator.of(context).pop();
              if (uid == member.uid && uid != creatorUid) {
                Navigator.of(context).pop();
                await GuestureDB.updateRole(gUser.uid, eventID, 'REMOVE');
              } else if (uid == member.uid && uid == creatorUid ||
                  creatorUid == member.uid) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Creator of workspace cannot be removed',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              } else if (uid != member.uid) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Removed from workspace!',
                      textAlign: TextAlign.center,
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                await GuestureDB.updateRole(gUser.uid, eventID, 'REMOVE');

                await GuestureDB.pushNotification(
                    GNotification(
                      title: eventName,
                      content: 'You have been removed from the workspace',
                      type: 'role-change',
                      timestamp: DateTime.now().toIso8601String(),
                    ),
                    [gUser.uid]);
              }
            },
            child: RoleChip(
              color: Colors.red,
              role: member.uid != uid
                  ? 'Remove from workspace'
                  : 'Leave workspace',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getGUser() async {
    gUser = await GuestureDB.getGUserFromUid(member.uid);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<GUser>(context);
    return member.role == 'removed' ||
            (member.role.contains('requested') && !isAdmin)
        ? Container()
        : FutureBuilder(
            future: getGUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white,
                    minHeight: 2,
                  ),
                );
              return Padding(
                padding: const EdgeInsets.all(3.0),
                child: ListTile(
                  onTap: (!isAdmin && member.role == 'admin') ||
                          (!isAdmin && member.uid != user.uid)
                      ? null
                      : () => _handleTap(user.uid, context, creatorUid),
                  leading: GuestureAvatar(
                      gUser.photoUrl, gUser.displayName, gUser.email, 20),
                  title: Text(gUser.displayName == null
                      ? gUser.email.split('@')[0]
                      : gUser.displayName),
                  subtitle: Text(
                    gUser.email,
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: FittedBox(
                    child: Column(
                      children: [
                        if (member.role == 'admin')
                          RoleChip(
                            role: 'Adminstrator',
                            color: Colors.green,
                            fontSize: 10,
                          ),
                        if (member.role == 'org')
                          RoleChip(
                            role: 'Organizer',
                            color: Colors.orange,
                            fontSize: 10,
                          ),
                        if (member.role.contains('invited'))
                          RoleChip(
                            role: 'Invited',
                            color: Colors.deepPurple,
                            fontSize: 10,
                          ),
                        if (member.role.contains('requested') && isAdmin)
                          GestureDetector(
                            onTap: () => _acceptInvite(context),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.green),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    'Accept',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.green),
                                  )),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Center(
                              child: Text(
                            '${member.ticketsSold} tickets sold',
                            style: TextStyle(fontSize: 12),
                          )),
                        )
                      ],
                    ),
                  ),
                ),
              );
            });
  }
}

class RoleChip extends StatelessWidget {
  final Color color;
  final String role;
  final double fontSize;
  const RoleChip({
    this.role,
    this.fontSize,
    Key key,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            role,
            style: TextStyle(fontSize: fontSize, color: Colors.white),
          )),
    );
  }
}
