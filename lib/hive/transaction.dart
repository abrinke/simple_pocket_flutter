import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'transaction.g.dart'; // Name des generierten Dateinamens
// flutter packages pub run build_runner build

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  String id = const Uuid().v1();

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  bool isPaid = false;

  @HiveField(4)
  bool isIncome;

  @HiveField(5)
  bool isRecurring;

  @HiveField(6)
  DateTime? startDate;

  @HiveField(7)
  DateTime? endDate;

  Transaction(
      {required this.title,
      required this.amount,
      required this.isIncome,
      required this.isRecurring,
      this.startDate,
      this.endDate});
}
