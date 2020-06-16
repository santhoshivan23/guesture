import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final String txID;
  final String payerName;
  final PaymentMode paymentMode;
  final double amount;
  final DateTime timeOfPayment;

  TransactionTile({
    this.amount,
    this.txID,
    this.paymentMode,
    this.timeOfPayment,
    this.payerName,
  });


  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            ListTile(
              leading: CircleAvatar(
                backgroundColor: amount >0
                    ? Colors.green
                    : Colors.red,
                foregroundColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: FittedBox(child: Text(amount.toString())),
                ),
              ),
              title: Text(payerName),
              subtitle: Text(
                DateFormat.MMMMEEEEd().format(timeOfPayment) +
                    '   ' +
                    DateFormat.jms().format(timeOfPayment),
              ),
             
            ),
           
          ],
        ),
      ),
    );
  }
}
