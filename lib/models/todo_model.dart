import 'package:todowithhivedb/utilities/global_library.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 0)
class ToDoModel {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String description;
  @HiveField(2)
  final bool complete;

  ToDoModel({required this.title, required this.description, required this.complete});
}
