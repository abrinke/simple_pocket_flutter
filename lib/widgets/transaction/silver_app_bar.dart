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
  final bool _pinned = true;
  final bool _snap = false;
  final bool _floating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: _pinned,
            snap: _snap,
            floating: _floating,
            expandedHeight: 160.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              title: const Text("SimplePocket",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: Hive.box<Transaction>('transactions').listenable(),
            builder: (BuildContext context, Box<Transaction> transactions, Widget? child) {
              double input = 0.0;
              double output = 0.0;

              // Iterate over transactions and calculate sums
              for (var transaction in transactions.values) {
                if (!transaction.isPaid) {
                  output += transaction.amount;
                } else {
                  input += transaction.amount;
                }
              }

              double saldo = output - input;

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    // When index == 0, show the summary
                    if (index == 0) {
                      return Padding(
                        padding: EdgeInsets.only(left: 20, right: 20, top: 20,),
                        child:  Row(
                          children: [
                            Expanded(
                              child: Text('Offener Betrag',
                                textAlign: TextAlign.left,
                                style:  TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                  letterSpacing: 0.5,
                                  color: Theme.of(context).colorScheme.inverseSurface,
                                ),
                              )
                            ),
                            Expanded(
                                child: Text(output.toString(),
                                  textAlign: TextAlign.right,
                                  style:  TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                    letterSpacing: 0.5,
                                    color: Theme.of(context).colorScheme.inverseSurface,
                                  ),
                                )
                            ),
                          ],
                        ),
                      );
                    }

                    // For other indices, show the transaction
                    final transaction = transactions.getAt(index - 1);

                    if (transaction == null) return null;

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
                        key: Key(transaction.id),
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
          children: [IconButton(onPressed: () {}, icon: const Icon(Icons.menu))],
        ),
      ),
    );
  }
}
