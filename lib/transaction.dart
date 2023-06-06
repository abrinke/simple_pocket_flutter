import 'package:hive/hive.dart';

part 'transaction.g.dart'; // Name des generierten Dateinamens
// flutter packages pub run build_runner build

@HiveType(typeId: 0)
class Transaction extends HiveObject {

  @HiveField(0)
  String title;

  @HiveField(1)
  String amount;

  @HiveField(2)
  bool isPaid = false;

  Transaction({required this.title, required this.amount});
}