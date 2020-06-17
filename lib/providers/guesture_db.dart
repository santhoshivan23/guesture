import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guesture/models/event.dart';
import 'package:guesture/models/guest.dart';
import 'package:guesture/models/transaction.dart';
import '../models/event.dart';


class GuestureDB  {
 
    
  
  static Future<void> addEvent(Event newEvent) async {
   
    await Firestore.instance.collection('events').document(newEvent.eventID).setData({
      'uid': newEvent.uid,
      'eventName': newEvent.eventName,
      'ticketPrice': newEvent.ticketPrice,
      'location': newEvent.location,
      'startDT': newEvent.startDate.toIso8601String(),
      'checkInFraction': 0,
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
            (previousValue, element) => element.data['isCheckedIn'] ? 
                (previousValue as int) + (element.data['gAllowance'] as int): previousValue as int));
    await Firestore.instance.collection('events').document(eventID).updateData({
      'checkInFraction' : totalGuests == 0 ? 0 :checkedGuests / totalGuests
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
    }).then((value) => updateCIF(eventID));
   
    
    
  }

  static Future<void> deleteGuest(String eventID, String guestID) async {
    
    await Firestore.instance.collection('events').document(eventID).collection('guests').document(guestID).delete().then((value) => updateCIF(eventID));
    
  }

  

  static Future<int> checkInGuest(String guestID, String eventID) async {
    final guestDoc = await Firestore.instance.collection('events').document(eventID).collection('guests').document(guestID).get();
    if(!guestDoc.exists) return -1;
    if(guestDoc.data['isCheckedIn']) return 0;
    else {
      await Firestore.instance.collection('events').document(eventID).collection('guests').document(guestID).updateData({
        'isCheckedIn' : true,
      }).then((value) => updateCIF(eventID));
      return 1;
    }

  }

  static Future<void> addTrasanction(GTransaction newTrasaction,String eventID) async {
  
    await Firestore.instance.collection('events').document(eventID).collection('transactions').add({
          'amount': newTrasaction.amount,
          
          'payerName': newTrasaction.payerName,
          'txID' : 'Cash${newTrasaction.payerName}',
          'timeOfPayment': Timestamp.fromDate(newTrasaction.timeOfPayment),
    });
    

    
  }
  
}
