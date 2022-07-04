// main.dart
// avant intégration
import 'package:flutter/material.dart';
import 'sql_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // Remove the debug banner
        debugShowCheckedModeBanner: false,
        title: 'Kindacode.com',
        theme: ThemeData(
          primarySwatch: Colors.grey,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // All journals
  List<Map<String, dynamic>> _journals = [];

  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals(); // Loading the diary when the app starts
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _description1Controller = TextEditingController();
  final TextEditingController _description2Controller = TextEditingController();

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _description1Controller.text = existingJournal['description1'];
      _description2Controller.text = existingJournal['description2'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                // this will prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(hintText: 'titre'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _description1Controller,
                    decoration: const InputDecoration(hintText: 'Description1'),
                  ),
                  TextField(
                    controller: _description2Controller,
                    decoration: const InputDecoration(hintText: 'Description2'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Save new journal
                      if (id == null) {
                        await _addItem();
                      }

                      if (id != null) {
                        await _updateItem(id);
                      }

                      // Clear the text fields
                      _titleController.text = '';
                      _description1Controller.text = '';
                      _description2Controller.text = '';

                      // Close the bottom sheet
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Create New' : 'Update'),
                  )
                ],
              ),
            ));
  }

// Insert a new journal to the database
  Future<void> _addItem() async {
    await SQLHelper.createItem(_titleController.text,
        _description1Controller.text, _description2Controller.text);

    _refreshJournals();
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(id, _titleController.text,
        _description1Controller.text, _description2Controller.text);
    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a journal!'),
    ));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('jeeeeff.com'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Row(
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            const Card(
                              color: Colors.black12,
                              child: Text("Row / card 1"),
                            ),
                            const Card(
                              color: Colors.black12,
                              child: Text("Row / card 2"),
                            ),
                            const Card(
                              color: Colors.black12,
                              child: Text("Row / card 355"),
                            ),
                          ],
                        ),
                        const Card(
                          color: Colors.black12,
                          child: Text("card 4"),
                        ),
                        Center(
                          child: const Card(
                            color: Colors.black12,
                            child: Text("center / Card 5"),
                          ),
                        ),
                        Row(
                          children: [
                            const Card(
                              color: Colors.black12,
                              child: Text("Row / card 7"),
                            ),
                            const Card(
                              color: Colors.black12,
                              child: Text("Row / card 8"),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
                Flexible(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: _journals.length,
                    itemBuilder: (context, index) => Card(
                      color: Colors.white70,
                      margin: const EdgeInsets.all(1),
                      child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.amber,
                            child:
                                Text(_journals[index]['createdAt'].toString()),
                          ),
                          title: Text(_journals[index]['description1']),
                          subtitle: Text(_journals[index]['description2']),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  iconSize: 15,
                                  onPressed: () =>
                                      _showForm(_journals[index]['id']),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () =>
                                      _deleteItem(_journals[index]['id']),
                                ),
                              ],
                            ),
                          )),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          // mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            PopupMenuButton(
              icon: const Icon(Icons.share),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 1,
                  child: Text("sms"),
                ),
                const PopupMenuItem(
                  value: 2,
                  child: Text("capture écran"),
                ),
                const PopupMenuItem(
                  value: 3,
                  child: Text("Objectif 3"),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {},
            ),
            PopupMenuButton(
              icon: const Icon(Icons.dynamic_feed),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 1,
                  child: Text("Objectif 1"),
                ),
                const PopupMenuItem(
                  value: 2,
                  child: Text("Objectif 3"),
                ),
                const PopupMenuItem(
                  value: 3,
                  child: Text("Objectif 3"),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {},
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(
          Icons.add,
          color: Colors.orange,
        ),
        onPressed: () => _showForm(null),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
    );
  }
}
