
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../hive/transaction.dart';

class TransactionList extends StatefulWidget {
  const TransactionList({Key? key}) : super(key: key);

  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: const Text('SimplePocket',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body:
        ValueListenableBuilder(
          valueListenable: Hive.box<Transaction>('transactions').listenable(),
          builder: (BuildContext context, Box<Transaction> transactions, Widget? child) {
            double ausgaben = 0.0;
            double einnahmen = 0.0;

            // Iterate over transactions and calculate sums
            for (var transaction in transactions.values) {
              if (transaction.isIncome) {
                einnahmen += transaction.amount;
              } else {
                ausgaben += transaction.amount;
              }
            }

            // Calculate saldo
            double saldo = einnahmen - ausgaben;

            return Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text('Einnahmen'),
                              Text(einnahmen.toString()),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text('Saldo'),
                              Text(saldo.toString()),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text('Ausgaben'),
                              Text(ausgaben.toString()),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ),
                Divider(color: Colors.black, thickness: 1.0,),
                Expanded(
                  child: ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions.getAt(index);

                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => TransactionDetailPage(transaction: transaction),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.ease;
                                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          child: Dismissible(
                            key: Key(transaction!.id), // Ein eindeutiger Key ist erforderlich
                            direction: DismissDirection.endToStart, // Von rechts nach links wischen
                            onDismissed: (direction) {
                              transaction.delete(); // Notiz löschen
                            },
                            background: Container(
                              color: Colors.red, // Hintergrundfarbe beim Wischen
                              child: Icon(Icons.delete, color: Colors.white), // Symbol beim Wischen
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 20),
                            ),
                            child: ListTile(
                              title: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(transaction.title),
                                  ),
                                  Expanded(
                                    child: Text(transaction.amount.toString()),
                                  ),
                                  Checkbox(
                                    value: transaction.isPaid,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        transaction.isPaid = value ?? false;
                                        transaction.save();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                  ),
                ),
              ],
            );
          },
        ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => TransactionCreator(),
          ));
        },
      ),
    );
  }
}

class TransactionCreator extends StatefulWidget {
  TransactionCreator({Key? key}) : super(key: key);

  @override
  _TransactionCreatorState createState() => _TransactionCreatorState();
}

class _TransactionCreatorState extends State<TransactionCreator> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  bool _isPaid = false;
  bool _isIncome = false;
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
        title: const Text('I/O',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
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
            CheckboxListTile(
              title: const Text('Bezahlt'),
              value: _isPaid,
              onChanged: (bool? value) {
                setState(() {
                  _isPaid = value ?? false;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Einnahme'),
              value: _isIncome,
              onChanged: (bool? value) {
                setState(() {
                  _isIncome = value ?? false;
                });
              },
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () {
          Transaction transaction =
          Transaction(
              title: _titleController.text,
              amount: double.parse(_amountController.text),
              isIncome: _isIncome,
              isRecurring: false,
              startDate: DateTime.now(),
              endDate: DateTime.now()
          );
          transaction.isPaid = _isPaid;
          Hive.box<Transaction>('transactions').add(transaction);
          Navigator.pop(context);
        },
      ),
    );
  }
}


class TransactionDetailPage extends StatelessWidget {
  final Transaction transaction;

  TransactionDetailPage({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(transaction.title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Title: ${transaction.title}'),
            Text('Amount: ${transaction.amount}'),
            Text('Is Paid: ${transaction.isPaid ? 'Yes' : 'No'}'),
            Text('Is Income: ${transaction.isIncome ? 'Yes' : 'No'}'),
            Text('Is Recurring: ${transaction.isRecurring ? 'Yes' : 'No'}'),
            Text('Start Date: ${transaction.startDate}'),
            Text('End Date: ${transaction.endDate}'),
          ],
        ),
      ),
    );
  }
}