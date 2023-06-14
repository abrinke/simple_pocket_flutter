import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:simple_pocket/widgets/transaction/transaction_creator.dart';
import 'package:simple_pocket/widgets/transaction/transaction_details.dart';

import '../../hive/transaction.dart';

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
        title: const Text(
          'SimplePocket',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ValueListenableBuilder(
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
                  )),
              Divider(
                color: Colors.black,
                thickness: 1.0,
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions.getAt(index);

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  TransactionDetailPage(transaction: transaction),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                const begin = Offset(1.0, 0.0);
                                const end = Offset.zero;
                                const curve = Curves.ease;
                                var tween =
                                    Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        child: Dismissible(
                          key: Key(transaction!.id),
                          direction: DismissDirection.endToStart,
                          // Von rechts nach links wischen
                          onDismissed: (direction) {
                            transaction.delete();
                          },
                          background: Container(
                            color: Colors.redAccent, // Hintergrundfarbe beim Wischen
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
                    }),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.menu))
          ],
        ),
      ),
    );
  }
}