import 'package:flutter/material.dart';
import 'package:guesture/models/g_user.dart';
import 'package:guesture/providers/guesture_db.dart';
import 'package:guesture/widgets/guesture_avatar.dart';

class UserTile extends StatefulWidget {
  final String eventID;
  final GUser gUser;
  final String eventName;
  String inviteStatus;

  UserTile({this.gUser, this.inviteStatus,this.eventID,this.eventName});

  @override
  _UserTileState createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  Future<void> handleInviteClick() async {
    final result = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Send Invite?'),
        actions: [
          buildRaisedButton(context, "Administrator"),
          buildRaisedButton(context, "Organizer"),
          FlatButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.deepPurpleAccent),
            ),
            onPressed: () {
              Navigator.of(context).pop(-1);
            },
          ),
        ],
      ),
    );
    
    if (result != -1) {
      setState(() {
        widget.inviteStatus = 'Invited';
      });
      if(result == 1)
      await GuestureDB.sendInvite(widget.gUser.uid, 'admin', widget.eventID,widget.eventName);
      else 
      await GuestureDB.sendInvite(widget.gUser.uid, 'org', widget.eventID,widget.eventName);

    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: GuestureAvatar(widget.gUser.photoUrl, widget.gUser.displayName,
          widget.gUser.email, 20),
      title: Text(widget.gUser.displayName == null
          ? widget.gUser.email.split('@')[0]
          : widget.gUser.displayName),
      trailing: widget.inviteStatus == 'Invited' ||
              widget.inviteStatus == 'Member' ||
              widget.inviteStatus == 'Requested'
          ? Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.deepPurple),
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.inviteStatus,
                    style: TextStyle(fontSize: 14, color: Colors.deepPurple),
                  )),
            )
          : GestureDetector(
              onTap: handleInviteClick,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.inviteStatus,
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    )),
              ),
            ),
    );
  }

  RaisedButton buildRaisedButton(BuildContext context, String role) {
    return RaisedButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: role == 'Administrator' ? Colors.green : Colors.orange,
      child: Text(
        role,
        style: TextStyle(color: Colors.white),
      ),
      onPressed: () {
        Navigator.of(context).pop(role == 'Administrator' ? 1 : 0);
        Scaffold.of(context).showSnackBar(SnackBar(
          backgroundColor:
              role == 'Administrator' ? Colors.green : Colors.orange,
          content: Text(
            'Invited as $role',
            textAlign: TextAlign.center,
          ),
        ));
      },
    );
  }
}
