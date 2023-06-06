import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';
import 'package:simple_pocket/transaction.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionAdapter());
  await Hive.openBox<Transaction>('transactions');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TransactionList(),
    );
  }
}

class TransactionList extends StatefulWidget {
  const TransactionList({Key? key}) : super(key: key);

  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  @override
  Widget build(BuildContext context) {
    final transactionBox = Hive.box<Transaction>('transactions');

    return Scaffold(
        appBar: AppBar(
          title: const Text('SimplePocket',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            final transaction = Transaction(title: '', amount: '');
            transactionBox.add(transaction);
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => TransactionEditor(transaction: transaction),
            ));
          },
        ),
        body: ValueListenableBuilder(
          valueListenable: transactionBox.listenable(),
          builder: (BuildContext context, Box<Transaction> transactions, Widget? child) {
            return ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions.getAt(index);

                  return Dismissible(
                    key: Key(transaction!.title), // Ein eindeutiger Key ist erforderlich
                    direction: DismissDirection.endToStart, // Von rechts nach links wischen
                    onDismissed: (direction) {
                      // Hier können Sie die Löschlogik implementieren
                      transaction.delete(); // Notiz löschen
                      transactions.deleteAt(index);
                    },
                    background: Container(
                      color: Colors.red, // Hintergrundfarbe beim Wischen
                      child: Icon(Icons.delete, color: Colors.white), // Symbol beim Wischen
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                    ),
                    child: CheckboxListTile(
                      title: Text(transaction.title, style: TextStyle(fontSize: 20)),
                      subtitle: Text('Amount: ${transaction.amount}'),
                      value: transaction.isPaid,
                      onChanged: (bool? value) {
                        setState(() {
                          transaction.isPaid = value ?? false;
                          transaction.save();
                        });
                      },
                    ),
                  );
                }
            );
          },
        )
    );
  }
}

class TransactionEditor extends StatefulWidget {
  final Transaction transaction;

  TransactionEditor({Key? key, required this.transaction}) : super(key: key);

  @override
  _TransactionEditorState createState() => _TransactionEditorState();
}

class _TransactionEditorState extends State<TransactionEditor> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.transaction.title);
    _amountController = TextEditingController(text: widget.transaction.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(hintText: 'Bescheibung'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(hintText: 'Betrag'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: () {
          widget.transaction.title = _titleController.text;
          widget.transaction.amount = _amountController.text;
          widget.transaction.save();
          Navigator.pop(context);
        },
      ),
    );
  }
}