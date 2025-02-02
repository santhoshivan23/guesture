import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:guesture/models/event.dart';
import 'package:guesture/models/g_notification.dart';
import 'package:guesture/models/g_user.dart';
import 'package:guesture/models/guest.dart';
import 'package:guesture/models/transaction.dart';
import '../models/event.dart';

class GuestureDB {
  static Future<void> addEvent(Event newEvent) async {
    DocumentReference userRef =
        Firestore.instance.collection('users').document(newEvent.uid);
    await Firestore.instance
        .collection('events')
        .document(newEvent.eventID)
        .setData({
      'uid': newEvent.uid,
      'members': {
        newEvent.uid: {'ref': userRef, 'role': 'admin', 'ticketsSold': 0},
      },
      'eventName': newEvent.eventName,
      'ticketPrice': newEvent.ticketPrice,
      'location': newEvent.location,
      'startDT': newEvent.startDate.toIso8601String(),
      'checkInFraction': 0,
      'inviteLinkA': newEvent.inviteLinkA,
      'inviteLinkO': newEvent.inviteLinkO,
    });
  }

  static Future<void> modifyEvent(Event modifiedEvent) async {
    await Firestore.instance
        .collection('events')
        .document(modifiedEvent.eventID)
        .updateData({
      'eventName': modifiedEvent.eventName,
      'location': modifiedEvent.location,
      'startDT': modifiedEvent.startDate.toIso8601String(),
      'ticketPrice': modifiedEvent.ticketPrice,
    });
  }

  static Future<void> deleteEvent(String eventID) async {
    await Firestore.instance.collection('events').document(eventID).delete();
  }

  static Future<void> updateCIF(String eventID) async {
    final totalGuests = await Firestore.instance
        .collection('events')
        .document(eventID)
        .collection('guests')
        .getDocuments()
        .then((value) => value.documents.fold(
            0,
            (previousValue, element) =>
                (previousValue as int) + (element.data['gAllowance'] as int)));
    final checkedGuests = await Firestore.instance
        .collection('events')
        .document(eventID)
        .collection('guests')
        .getDocuments()
        .then((value) => value.documents.fold(
            0,
            (previousValue, element) => element.data['isCheckedIn']
                ? (previousValue as int) + (element.data['gAllowance'] as int)
                : previousValue as int));
    await Firestore.instance.collection('events').document(eventID).updateData({
      'checkInFraction': totalGuests == 0 ? 0 : checkedGuests / totalGuests
    });
  }

  static Future<void> addGuest(Guest newGuest, String eventID) async {
    await Firestore.instance
        .collection('events')
        .document(eventID)
        .collection('guests')
        .document(newGuest.gID)
        .setData({
      'gAllowance': newGuest.gAllowance,
      'gEmailID': newGuest.gEmailID,
      'gGender': newGuest.gGender,
      'gMobileNumber': newGuest.gMobileNumber,
      'gName': newGuest.gName,
      'gOrg': newGuest.gOrg,
      'isCheckedIn': false,
      'reservedBy': newGuest.reservedBy,
    }).then((value) => updateCIF(eventID));
  }

  static Future<void> deleteGuest(String eventID, String guestID) async {
    await Firestore.instance
        .collection('events')
        .document(eventID)
        .collection('guests')
        .document(guestID)
        .delete()
        .then((value) => updateCIF(eventID));
  }

  static Future<int> checkInGuest(String guestID, String eventID) async {
    final guestDoc = await Firestore.instance
        .collection('events')
        .document(eventID)
        .collection('guests')
        .document(guestID)
        .get();
    if (!guestDoc.exists) return -1;
    if (guestDoc.data['isCheckedIn'])
      return 0;
    else {
      await Firestore.instance
          .collection('events')
          .document(eventID)
          .collection('guests')
          .document(guestID)
          .updateData({
        'isCheckedIn': true,
      }).then((value) => updateCIF(eventID));
      return 1;
    }
  }

  static Future<void> addTrasanction(
      GTransaction newTrasaction, String eventID) async {
    await Firestore.instance
        .collection('events')
        .document(eventID)
        .collection('transactions')
        .add({
      'amount': newTrasaction.amount,
      'payerName': newTrasaction.payerName,
      'txID': 'Cash${newTrasaction.payerName}',
      'timeOfPayment': Timestamp.fromDate(newTrasaction.timeOfPayment),
    });
  }

  static Future<int> requestToJoinWorkspace(
      String eventID, String uid, String role) async {
    DocumentReference userRef =
        Firestore.instance.collection('users').document(uid);
    final eventRef =
        await Firestore.instance.collection('events').document(eventID).get();
    Map<String, dynamic> membersMap = eventRef.data['members'];

    if (membersMap.containsKey(uid)) {
      if (membersMap[uid] ==
              {'ref': userRef, 'role': 'requested-admin', 'ticketsSold': 0} ||
          membersMap[uid] ==
              {'ref': userRef, 'role': 'requested-org', 'ticketsSold': 0})
        return -1;
      return 0;
    }
    membersMap[uid] = {
      'ref': userRef,
      'role': 'requested-$role',
      'ticketsSold': 0,
    };
    await Firestore.instance.collection('events').document(eventID).updateData({
      'members': membersMap,
    });
    return 1;
  }

  static Future<GUser> getGUserFromEmail(String email) async {
    final userDocs = await Firestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .getDocuments()
        .then((value) => value.documents);
    if (userDocs.isEmpty) return null;
    final userDoc = userDocs[0];
    final GUser gUser = GUser(
      displayName: userDoc.data['displayName'],
      email: userDoc.data['email'],
      photoUrl: userDoc.data['photoUrl'],
      uid: userDoc.documentID,
    );

    return gUser;
  }

  static Future<GUser> getGUserFromUid(String uid) async {
    final userDoc =
        await Firestore.instance.collection('users').document(uid).get();
    if (userDoc == null) return null;

    final GUser gUser = GUser(
      displayName: userDoc.data['displayName'],
      email: userDoc.data['email'],
      photoUrl: userDoc.data['photoUrl'],
      uid: userDoc.documentID,
    );

    return gUser;
  }

  static Future<String> getInviteStatus(String eventID, String uid) async {
    final eventRef =
        await Firestore.instance.collection('events').document(eventID).get();
    Map<String, dynamic> membersMap = eventRef.data['members'];
    print(membersMap);
    if (!membersMap.containsKey(uid)) {
      return 'Invite';
    } else {
      if (membersMap[uid]['role'].toString().contains('invited'))
        return 'Invited';
      else if (membersMap[uid]['role'].toString().startsWith('admin') ||
          membersMap[uid]['role'].toString().startsWith('org')) return 'Member';
      return 'Requested';
    }
  }

  static Future<void> sendInvite(
      String uid, String role, String eventID, String wsName,) async {
    final eventRef =
        await Firestore.instance.collection('events').document(eventID).get();
    DocumentReference userRef =
        Firestore.instance.collection('users').document(uid);
    Map<String, dynamic> membersMap = eventRef.data['members'];
    membersMap[uid] = {
      'ref': userRef,
      'role': 'invited-$role',
      'ticketsSold': 0,
    };
    await Firestore.instance.collection('events').document(eventID).updateData(
      {
        'members': membersMap,
      },
    );
    final sender = await FirebaseAuth.instance.currentUser();
    final inviterName = sender.displayName == null ? sender.email.split('@')[0]: sender.displayName;

    final notification = GNotification(
      title: '$inviterName sent you a request',
      content: '$inviterName invited you to join their workspace - $wsName',
      timestamp: DateTime.now().toIso8601String(),
      eventID: eventID,
      role: role,
      type: 'invite',
      sender: sender.uid,
    );

    await pushNotification(notification, [uid]);
  }

  static Future<void> pushNotification(
      GNotification notification, List<String> uids) async {
    for (var uid in uids) {
      await Firestore.instance
          .collection('users')
          .document(uid)
          .collection('notifications')
          .document()
          .setData({
        'type': notification.type,
        'title': notification.title,
        'content': notification.content,
        'timestamp': notification.timestamp,
        'eventID': notification.eventID,
        'role': notification.role,
        'sender': notification.sender
      });
      await incrementCounter(uid);
    }
  }

  static Future<void> deleteNotification(String uid, String notifID) async {
    await Firestore.instance
        .collection('users')
        .document(uid)
        .collection('notifications')
        .document(notifID)
        .delete();
  }

  static Future<void> resetNotifCounter(String uid) async {
    await Firestore.instance.collection('users').document(uid).updateData({
      'notifCounter': 0,
    });
  }

  static Future<void> incrementCounter(String uid) async {
    await Firestore.instance.collection('users').document(uid).updateData({
      'notifCounter': FieldValue.increment(1),
    });
  }

  static Future<void> clearNotifs(String uid) async {
    final docs = await Firestore.instance
        .collection('users')
        .document(uid)
        .collection('notifications')
        .where('type', whereIn: ['role-change','others']).getDocuments();
    for (var doc in docs.documents) {
      await Firestore.instance
          .collection('users')
          .document(uid)
          .collection('notifications')
          .document(doc.documentID)
          .delete();
    }
  }

  static Future<int> updateRole(
      String uid, String eventID, String newRole) async {
    final eventRef =
        await Firestore.instance.collection('events').document(eventID).get();

    Map<String, dynamic> membersMap = eventRef.data['members'];
    if (uid == eventRef.data['uid']) return 0;
    if (membersMap.containsKey(uid)) {
      if (newRole == 'REMOVE') {
        
        membersMap.remove(uid);
      } else {
        membersMap[uid] = {
          'ref': membersMap[uid]['ref'],
          'role': newRole,
          'ticketsSold': membersMap[uid]['ticketsSold'],
        };
      }
      await Firestore.instance
          .collection('events')
          .document(eventID)
          .updateData({
        'members': membersMap,
      });
      return 1;
    }
    return 0;
  }

  static Future<String> getRole(String uid, String eventID) async {
    final eventRef =
        await Firestore.instance.collection('events').document(eventID).get();
    Map<String, dynamic> membersMap = eventRef.data['members'];
    if (membersMap.containsKey(uid)) {
      return membersMap[uid]['role'];
    }
    return null;
  }

  static Future<int> getTicketsSoldByUid(String uid, String eventID) async {
    final guestDocs = await Firestore.instance
        .collection('events')
        .document(eventID)
        .collection('guests')
        .where('reservedBy', isEqualTo: uid)
        .getDocuments();
    return guestDocs.documents.length;
  }

  static Future<void> createToken(String uid) async {
    FirebaseMessaging _fcm = FirebaseMessaging();
    final token = await _fcm.getToken();
    await Firestore.instance
        .collection('users')
        .document(uid)
        .collection('tokens')
        .document(token)
        .setData({
      'token': token,
      'createdAt': FieldValue.serverTimestamp(),
      'platform': Platform.operatingSystem,
    });
  }

  static Future<void> deleteToken(String uid, String token) async {
    final tokensRef = await Firestore.instance
        .collection('users')
        .document(uid)
        .collection('tokens')
        .document(token)
        .get();
    if (tokensRef.exists) {
      await tokensRef.reference.delete();
    }
  }
}
