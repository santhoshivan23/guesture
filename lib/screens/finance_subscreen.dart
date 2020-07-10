import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:guesture/models/transaction.dart';
import 'package:guesture/widgets/transactions_tile.dart';

class FinanceSubscreen extends StatelessWidget {
  final String eventID;
  final bool isAdmin;
  FinanceSubscreen({this.eventID,this.isAdmin});
  @override
  Widget build(BuildContext context) {
  
    
    return !isAdmin ? Center(child: Text('You are not allowed to access this section'),) : StreamBuilder(
      stream: Firestore.instance.collection('events').document(eventID).collection('transactions').orderBy('timeOfPayment',descending: true).snapshots(),
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) return Center(child :CircularProgressIndicator());
        if(snapshot.data.documents.length == 0) return Center(child: Text('There are no transactions for this event '));
        final totalSales = (snapshot.data.documents as List).fold(0, (previousValue, element) => previousValue + element.data['amount']);
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.9),
                    border: Border.all(width: 3, color: Colors.purple),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text('Total Sale :',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                      Text(totalSales.toString(),style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                    ],
                  )),
            ),
            Expanded(
                          child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (ctx, index) => TransactionTile(
                        payerName: snapshot.data.documents[index]['payerName'],
                        paymentMode: snapshot.data.documents[index]['paymentMode']== 'Cash' ? PaymentMode.Cash : PaymentMode.UPI,
                        timeOfPayment: snapshot.data.documents[index]['timeOfPayment'].toDate(), 
                        txID: snapshot.data.documents[index]['txID'],
                        amount: double.parse(snapshot.data.documents[index]['amount'].toString()),
                    
                      )),
            ),
          ],
        );
      }
    );
  }
}
