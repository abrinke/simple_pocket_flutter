import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:simple_pocket/widgets/transaction/transaction_creator.dart';
import 'package:simple_pocket/widgets/transaction/transaction_details.dart';

import '../../hive/transaction.dart';

class SliverAppBarEx extends StatefulWidget {
  const SliverAppBarEx({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SliverAppBarExState();
}

class _SliverAppBarExState extends State<SliverAppBarEx> {
  bool _pinned = true;
  bool _snap = false;
  bool _floating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: this._pinned,
            snap: this._snap,
            floating: this._floating,
            expandedHeight: 160.0,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                "FlexibleSpace title",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
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

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    // When index == 0, show the summary
                    if (index == 0) {
                      return Column(
                        children: [
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
                        ],
                      );
                    }

                    // For other indices, show the transaction
                    final transaction = transactions.getAt(index - 1);

                    if (transaction == null) return null;

                    return ListTile(
                      title: Text(transaction.title),
                      subtitle: Text(transaction.amount.toString()),
                      trailing: Checkbox(
                        value: transaction.isPaid,
                        onChanged: (bool? value) {
                          setState(() {
                            transaction.isPaid = value ?? false;
                            transaction.save();
                          });
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransactionDetailPage(transaction: transaction),
                          ),
                        );
                      },
                    );
                  },
                  childCount: transactions.length + 1, // +1 to include the summary
                ),
              );
            },
          ),
        ],
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
