import 'package:flutter/material.dart';
import 'package:simple_pocket/widgets/transaction/transaction_editor.dart';

import '../../hive/transaction.dart';

class TransactionDetailPage extends StatefulWidget {
  final Transaction transaction;

  const TransactionDetailPage({Key? key, required this.transaction}) : super(key: key);

  @override
  _TransactionDetailPageState createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.transaction.title,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Title: ${widget.transaction.title}'),
            Text('Amount: ${widget.transaction.amount}'),
            Text('Is Paid: ${widget.transaction.isPaid ? 'Yes' : 'No'}'),
            Text('Is Income: ${widget.transaction.isIncome ? 'Yes' : 'No'}'),
            Text('Is Recurring: ${widget.transaction.isRecurring ? 'Yes' : 'No'}'),
            Text('Start Date: ${widget.transaction.startDate}'),
            Text('End Date: ${widget.transaction.endDate}'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(
            builder: (_) => TransactionEditorPage(transaction: widget.transaction),
          ))
              .then((_) {
            setState(() {});
          });
        },
      ),
    );
  }
}
