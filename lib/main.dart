import 'package:todowithhivedb/utilities/global_library.dart';

void main() async {
  //init hive DB and register adapter
  await Hive.initFlutter();
  Hive.registerAdapter(ToDoModelAdapter());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To Do With Hive DB',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}
