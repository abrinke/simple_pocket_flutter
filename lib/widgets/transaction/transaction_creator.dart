import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../hive/transaction.dart';

class TransactionCreator extends StatefulWidget {
  final VoidCallback onTransactionAdded;

  TransactionCreator({required this.onTransactionAdded});

  @override
  _TransactionCreatorState createState() => _TransactionCreatorState();
}

class _TransactionCreatorState extends State<TransactionCreator> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  bool _isIncome = true;
  bool _isRecurring = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();
    _amountController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'I/O',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(hintText: 'Beschreibung'),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: 'Betrag'),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isIncome = true;
                    });
                  },
                  child: Text('Einnahme'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.green),
                    backgroundColor: _isIncome ? Colors.green : null,
                    foregroundColor: _isIncome ? Colors.white : Colors.black,
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isIncome = false;
                    });
                  },
                  child: Text('Ausgabe'),
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red),
                      backgroundColor: !_isIncome ? Colors.red : null,
                      foregroundColor: !_isIncome ? Colors.white : Colors.black // für Textfarbe
                      ),
                ),
              ],
            ),
            CheckboxListTile(
              title: const Text('Wiederkehrend'),
              value: _isRecurring,
              onChanged: (bool? value) {
                setState(() {
                  _isRecurring = value ?? false;
                });
              },
            ),
            if (_isRecurring) ...[
              TextField(
                controller: _startDateController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(hintText: 'Startdatum (jjjj-mm-tt)'),
              ),
              TextField(
                controller: _endDateController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(hintText: 'Enddatum (jjjj-mm-tt)'),
              ),
            ]
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () {
          Transaction transaction = Transaction(
            title: _titleController.text,
            amount: double.parse(_amountController.text),
            isIncome: _isIncome,
            isRecurring: _isRecurring,
            startDate: DateTime.now(),
            endDate: DateTime.now(),
          );
          Hive.box<Transaction>('transactions').add(transaction);
          widget.onTransactionAdded();
          Navigator.pop(context);
        },
      ),
    );
  }
}
