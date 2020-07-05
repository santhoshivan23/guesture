import 'package:flutter/material.dart';
import 'package:guesture/models/g_notification.dart';
import 'package:guesture/models/g_user.dart';
import 'package:guesture/models/workspace_member.dart';
import 'package:guesture/providers/guesture_db.dart';
import 'package:guesture/widgets/guesture_avatar.dart';
import 'package:provider/provider.dart';

class MembersTile extends StatefulWidget {
  final WorkspaceMember member;
  final String eventID;
  final String eventName;
  final bool isAdmin;

  MembersTile({this.member, this.eventID, this.eventName, this.isAdmin});

  @override
  _MembersTileState createState() => _MembersTileState();
}

class _MembersTileState extends State<MembersTile> {
  String memberRole;
  GUser gUser;

  @override
  void initState() {
    memberRole = widget.member.role;

    super.initState();
  }

  Future<void> _acceptInvite() async {
    if (memberRole.contains('admin')) {
      setState(() {
        memberRole = 'admin';
      });
      await GuestureDB.updateRole(gUser.uid, widget.eventID, 'admin');
    } else {
      setState(() {
        memberRole = 'org';
      });
      await GuestureDB.updateRole(gUser.uid, widget.eventID, 'org');
    }
    await GuestureDB.pushNotification(
        GNotification(
            type: 'role-change',
            title: '${widget.eventName} · Role updated',
            content: 'Your request to join he workspace has been accepted',
            timestamp: DateTime.now().toIso8601String()),
        [gUser.uid]);
  }

  Future<void> _handleTap(String uid) async {
    print(uid);
    showDialog(
        context: context,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: FittedBox(
              child: GuestureAvatar(
                  gUser.photoUrl, gUser.displayName, gUser.email, 25)),
          content: Text(
            gUser.displayName == null ? 'NA' : gUser.displayName,
            textAlign: TextAlign.center,
          ),
          actions: [
            if (memberRole == 'admin' && uid != widget.member.uid)
              GestureDetector(
                onTap: () async {
                  Navigator.of(context).pop();

                  setState(() {
                    memberRole = 'org';
                  });
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Role Updated!',
                        textAlign: TextAlign.center,
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  await GuestureDB.updateRole(gUser.uid, widget.eventID, 'org');
                  await GuestureDB.pushNotification(
                      GNotification(
                        title: '${widget.eventName} · Role updated',
                        content: 'You are now an organizer',
                        type: 'role-change',
                        timestamp: DateTime.now().toIso8601String(),
                      ),
                      [gUser.uid]);
                },
                child: RoleChip(
                  color: Colors.orange,
                  role: 'Make as organizer',
                  fontSize: 12,
                ),
              ),
            if (memberRole == 'org' && widget.isAdmin)
              GestureDetector(
                onTap: () async {
                  Navigator.of(context).pop();

                  setState(() {
                    memberRole = 'admin';
                  });
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Role Updated!',
                        textAlign: TextAlign.center,
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  await GuestureDB.updateRole(
                      gUser.uid, widget.eventID, 'admin');
                  await GuestureDB.pushNotification(
                      GNotification(
                        title: '${widget.eventName} · Role updated',
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
                Navigator.of(context).pop();
                if (uid == widget.member.uid) {
                  print('heree');

                  Navigator.of(context).pop();
                }
                final result = await GuestureDB.updateRole(
                    gUser.uid, widget.eventID, 'REMOVE');
                if (uid != widget.member.uid) {
                  if (result == 1) {
                    setState(() {
                      memberRole = 'removed';
                    });
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Removed from workspace!',
                          textAlign: TextAlign.center,
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );

                    await GuestureDB.pushNotification(
                        GNotification(
                          title: widget.eventName,
                          content: 'You have been removed from the workspace',
                          type: 'role-change',
                          timestamp: DateTime.now().toIso8601String(),
                        ),
                        [gUser.uid]);
                  } else {
                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Creator of workspace cannot be removed',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                }
                else {
                  return;
                }
              },
              child: RoleChip(
                color: Colors.red,
                role: widget.member.uid != uid
                    ? 'Remove from workspace'
                    : 'Leave workspace',
                fontSize: 12,
              ),
            ),
          ],
        ));
  }

  Future<void> getGUser() async {
    gUser = await GuestureDB.getGUserFromUid(widget.member.uid);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<GUser>(context);
    return memberRole == 'removed'
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
                  onTap: (!widget.isAdmin && widget.member.role == 'admin') ||
                          (!widget.isAdmin && widget.member.uid != user.uid)
                      ? null
                      : () => _handleTap(user.uid),
                  leading: GuestureAvatar(
                      gUser.photoUrl, gUser.displayName, gUser.email, 20),
                  title: Text(
                      gUser.displayName == null ? 'NA' : gUser.displayName),
                  subtitle: FittedBox(child: Text(gUser.email)),
                  trailing: FittedBox(
                    child: Column(
                      children: [
                        if (memberRole == 'admin')
                          RoleChip(
                            role: 'Adminstrator',
                            color: Colors.green,
                            fontSize: 10,
                          ),
                        if (memberRole == 'org')
                          RoleChip(
                            role: 'Organizer',
                            color: Colors.orange,
                            fontSize: 10,
                          ),
                        if (memberRole.contains('invited'))
                          RoleChip(
                            role: 'Invited',
                            color: Colors.deepPurple,
                            fontSize: 10,
                          ),
                        if (memberRole.contains('requested'))
                          GestureDetector(
                            onTap: _acceptInvite,
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
                            '${widget.member.ticketsSold} tickets sold',
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
