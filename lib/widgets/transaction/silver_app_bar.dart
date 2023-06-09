import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:simple_pocket/colors/theme_helper.dart';
import 'package:simple_pocket/widgets/transaction/transaction_creator.dart';
import 'package:simple_pocket/widgets/transaction/transaction_details.dart';

import '../../hive/transaction.dart';

class SliverAppBarEx extends StatefulWidget {
  const SliverAppBarEx({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SliverAppBarExState();
}

class _SliverAppBarExState extends State<SliverAppBarEx> {
  bool isAscending = true;
  String currentDate = DateFormat('MMMM').format(DateTime.now());
  List<Transaction> recurringTransactions = [];
  List<Transaction> notRecurringTransactions = [];
  late ValueNotifier<List<Transaction>> recurringTransactionsNotifier;
  late ValueNotifier<List<Transaction>> notRecurringTransactionsNotifier;
  late Box<Transaction> hiveBox;

  @override
  void initState() {
    super.initState();
    initHiveBox();
  }

  void refreshTransactions() {
    recurringTransactions = hiveBox.values.where((transaction) => !transaction.isIncome && transaction.isRecurring).toList();
    recurringTransactionsNotifier.value = recurringTransactions;
  }

  Future<void> initHiveBox() async {
    hiveBox = Hive.box<Transaction>('transactions');
    recurringTransactions = hiveBox.values.where((transaction) => !transaction.isIncome && transaction.isRecurring).toList();
    notRecurringTransactions = hiveBox.values.where((transaction) => !transaction.isIncome && !transaction.isRecurring).toList();
    recurringTransactionsNotifier = ValueNotifier(recurringTransactions);
    notRecurringTransactionsNotifier = ValueNotifier(notRecurringTransactions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            snap: false,
            floating: false,
            expandedHeight: 100.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text("SimplePocket",
                  style: TextStyle(
                      color: ThemeHelper.inverseSurface(context), fontWeight: FontWeight.bold)),
              background: Container(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: recurringTransactionsNotifier,
            builder: (BuildContext context, transactions, Widget? child) {

              double output = 0.0;
              for (var transaction in transactions) {
                if (!transaction.isPaid) {
                  output += transaction.amount;
                }
              }
              transactions.sort((a, b) {
                return isAscending ? a.amount.compareTo(b.amount) : b.amount.compareTo(a.amount);
              });

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Offener Betrag:',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  letterSpacing: 0.5,
                                  color: Theme.of(context).colorScheme.inverseSurface,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                output.toString(),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  letterSpacing: 0.5,
                                  color: Theme.of(context).colorScheme.inverseSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // For other indices, show the transaction
                    final transaction = transactions[index - 1];

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
                        onDismissed: (direction) {
                          hiveBox.delete(transaction);
                          transaction.delete();
                          refreshTransactions();
                        },
                        background: Container(
                          color: ThemeHelper.error(context),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 25),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    transaction.title,
                                    style: TextStyle(
                                      color: ThemeHelper.inverseSurface(context),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    transaction.amount.toString(),
                                    style: TextStyle(
                                      color: ThemeHelper.inverseSurface(context),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Checkbox(
                                      value: transaction.isPaid,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          transaction.isPaid = value ?? false;
                                          transaction.save();
                                        });
                                      }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: transactions.length + 1, // +1 to include the summary
                ),
              );
            },
          ),
          ValueListenableBuilder(
            valueListenable: notRecurringTransactionsNotifier,
            builder: (BuildContext context, transactions, Widget? child) {

              double output = 0.0;
              for (var transaction in transactions) {
                if (!transaction.isPaid) {
                  output += transaction.amount;
                }
              }
              transactions.sort((a, b) {
                return isAscending ? a.amount.compareTo(b.amount) : b.amount.compareTo(a.amount);
              });

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Offener Betrag:',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  letterSpacing: 0.5,
                                  color: Theme.of(context).colorScheme.inverseSurface,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                output.toString(),
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  letterSpacing: 0.5,
                                  color: Theme.of(context).colorScheme.inverseSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // For other indices, show the transaction
                    final transaction = transactions[index - 1];

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
                        onDismissed: (direction) {
                          hiveBox.delete(transaction);
                          transaction.delete();
                          refreshTransactions();
                        },
                        background: Container(
                          color: ThemeHelper.error(context),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 25),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    transaction.title,
                                    style: TextStyle(
                                      color: ThemeHelper.inverseSurface(context),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    transaction.amount.toString(),
                                    style: TextStyle(
                                      color: ThemeHelper.inverseSurface(context),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Checkbox(
                                      value: transaction.isPaid,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          transaction.isPaid = value ?? false;
                                          transaction.save();
                                        });
                                      }),
                                ],
                              ),
                            ),
                          ],
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
            builder: (_) => TransactionCreator(
              onTransactionAdded: refreshTransactions,
            ),
          ));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.view_agenda)),
            IconButton(
              onPressed: () {
                setState(() {
                  isAscending = !isAscending;
                });
              },
              icon: Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward),
            ),
          ],
        ),
      ),
    );
  }
}
