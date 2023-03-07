import 'package:todowithhivedb/utilities/global_library.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum DataFilter { ALL, COMPLETED, PROGRESS }

class _MyHomePageState extends State<MyHomePage> {
  Box<ToDoModel>? dataBox;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  static const String dataBoxName = "data";
  DataFilter filter = DataFilter.ALL;

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      dataBox = await Hive.openBox(dataBoxName);
      setState(() {});

      super.initState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TO - DO'),
        actions: [
          PopupMenuButton(onSelected: (String value) {
            if (value.compareTo('All') == 0) {
              setState(() {
                filter = DataFilter.ALL;
              });
            } else if (value.compareTo('Completed') == 0) {
              setState(() {
                filter = DataFilter.COMPLETED;
              });
            } else {
              setState(() {
                filter = DataFilter.PROGRESS;
              });
            }
          }, itemBuilder: (context) {
            return ['All', 'Completed', 'Progress']
                .map((option) =>
                    PopupMenuItem(value: option, child: Text(option)))
                .toList();
          })
        ],
      ),
      body: dataBox != null
          ? SingleChildScrollView(
              child: Column(
                children: [
                  ValueListenableBuilder(
                      valueListenable: dataBox!.listenable(),
                      builder: (context, Box<ToDoModel> items, _) {
                        List<int> keys;

                        if (filter == DataFilter.ALL) {
                          keys = items.keys.cast<int>().toList();
                        } else if (filter == DataFilter.COMPLETED) {
                          keys = items.keys
                              .cast<int>()
                              .where((key) => items.get(key)!.complete)
                              .toList();
                        } else {
                          keys = items.keys
                              .cast<int>()
                              .where((key) => !items.get(key)!.complete)
                              .toList();
                        }

                        return ListView.separated(
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              final int key = keys[index];
                              final ToDoModel data = items.get(key)!;
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                color: Colors.blueGrey[200],
                                child: ListTile(
                                  title: Text(
                                    data.title,
                                    style: const TextStyle(
                                        fontSize: 22, color: Colors.black),
                                  ),
                                  subtitle: Text(data.description,
                                      style: const TextStyle(
                                          fontSize: 20, color: Colors.black38)),
                                  leading: Text(
                                    "$key",
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          _showDeleteConfirmationAlertDialog(
                                              context, key);
                                        },
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Icon(
                                        Icons.check,
                                        color: data.complete
                                            ? Colors.deepPurpleAccent
                                            : Colors.red,
                                      )
                                    ],
                                  ),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                          backgroundColor: Colors.white,
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                FlatButton(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0),
                                                  ),
                                                  color: Colors.blueAccent[100],
                                                  child: const Text(
                                                    "Mark as complete",
                                                    style: TextStyle(
                                                        color: Colors.black87),
                                                  ),
                                                  onPressed: () {
                                                    ToDoModel mData = ToDoModel(
                                                        title: data.title,
                                                        description:
                                                            data.description,
                                                        complete: true);
                                                    dataBox!.put(key, mData);
                                                    Navigator.pop(context);
                                                  },
                                                )
                                              ],
                                            ),
                                          )),
                                    );
                                  },
                                ),
                              );
                            },
                            separatorBuilder: (ctx, index) => const Divider(),
                            itemCount: keys.length);
                      })
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                    backgroundColor: Colors.blueGrey[100],
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextField(
                            decoration:
                                const InputDecoration(hintText: "Title"),
                            controller: titleController,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          TextField(
                            decoration:
                                const InputDecoration(hintText: "Description"),
                            controller: descriptionController,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          FlatButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            color: Colors.red,
                            child: const Text(
                              "Add Todo",
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              final String title = titleController.text;
                              final String description =
                                  descriptionController.text;
                              titleController.clear();
                              descriptionController.clear();
                              ToDoModel data = ToDoModel(
                                  title: title,
                                  description: description,
                                  complete: false);
                              dataBox!.add(data);
                              Navigator.pop(context);
                            },
                          )
                        ],
                      ),
                    ));
              });
        },
      ),
    );
  }

  _showDeleteConfirmationAlertDialog(BuildContext context, int key) {
    // set up the button
    Widget yesButton = TextButton(
      child: const Text("YES"),
      onPressed: () {
        dataBox!.delete(key);
        Navigator.of(context).pop();
      },
    );

    Widget noButton = TextButton(
      child: const Text("NO"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Confirm"),
      content: const Text("Are you sure you want to delete this task?"),
      actions: [yesButton, noButton],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
