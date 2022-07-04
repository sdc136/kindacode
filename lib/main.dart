import 'package:flutter/material.dart';
import 'sql_helper.dart';
import 'package:flutter/services.dart';
import 'settings_screen.dart';
import 'data_db.dart';

// https://www.kindacode.com/cat/mobile/flutter/
/* Tooltip = info bulle Tooltip(
   message: 'This is a tooltip',
   child: OutlinedButton(onPressed: () {}, child: const Text('A Button')),
)
*/
// 20220704:12h22 : B_1.0
// cached_network_image : mise en cache => gain

// Autocomplete : auto complétion champ texte

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}
// pour affichage différent en fonction orientation idevice : cf
// https://www.kindacode.com/article/how-to-disable-landscape-mode-in-flutter/

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
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Description2'),
                  ),

// forcer le keyboard numéric ou alphanumérique en fonction des datas à renter
// vérification validité des datas

                  const SizedBox(
                    height: 20,
                  ),

                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          _titleController.text = '';
                          _description1Controller.text = '';
                          _description2Controller.text = '';

                          // Close the bottom sheet
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel '),
                      ),
                      const Spacer(),
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
                      ),
                    ],
                  )
                ],
              ),
            ));
  }

// Insert a new journal to the database
  Future<void> _addItem() async {
    await SQLHelper.createItem(_titleController.text,
        _description1Controller.text, _description2Controller.text);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully creat a journal!'),
      duration: Duration(seconds: 1, milliseconds: 0),
    ));
    _refreshJournals();
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(id, _titleController.text,
        _description1Controller.text, _description2Controller.text);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully update a journal!'),
      duration: Duration(seconds: 1, milliseconds: 0),
    ));
    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a journal!'),
      duration: Duration(seconds: 1, milliseconds: 0),
    ));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('jeeeeff.com'),
      ),
      body: Column(
        children: [
          Flexible(
            child: Container(
              width: double.infinity,
              color: Colors.blueGrey,
              child: const Center(
                child: Text('Flexible / Fill'),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 100,
            color: Colors.greenAccent,
            child: const Center(
              child: Text('Container / 100'),
            ),
          ),
          /* Container(
            width: double.infinity,
            height: 100,
            color: Colors.orange,
            child: ListView.builder(
              // reverse: true,
              itemCount: _journals.length,
              itemBuilder: (context, index) => Card(
                color: Colors.white,
                margin: const EdgeInsets.all(1),
                child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.amber,
                      child: Text(_journals[index]['createdAt'].toString()),
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
                            onPressed: () => _showForm(_journals[index]['id']),
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
          ), */
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
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const DataDB()));
              },

              // onPressed: () => _showForm(null),
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
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingScreen()));
              },
              // onPressed: () {},
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(
          Icons.add,
          color: Colors.orange,
          size: 50,
        ),
        onPressed: () => _showForm(null),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
    );
  }
}



/*
import 'package:flutter/material.dart';
import 'sql_helper.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}
// pour affichage différent en fonction orientation idevice : cf
// https://www.kindacode.com/article/how-to-disable-landscape-mode-in-flutter/

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
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Description2'),
                  ),

// forcer le keyboard numéric ou alphanumérique en fonction des datas à renter
// vérification validité des datas

                  const SizedBox(
                    height: 20,
                  ),

                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          _titleController.text = '';
                          _description1Controller.text = '';
                          _description2Controller.text = '';

                          // Close the bottom sheet
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel '),
                      ),
                      const Spacer(),
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
                      ),
                    ],
                  )
                ],
              ),
            ));
  }

// Insert a new journal to the database
  Future<void> _addItem() async {
    await SQLHelper.createItem(_titleController.text,
        _description1Controller.text, _description2Controller.text);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully creat a journal!'),
      duration: Duration(seconds: 1, milliseconds: 0),
    ));
    _refreshJournals();
  }

  // Update an existing journal
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(id, _titleController.text,
        _description1Controller.text, _description2Controller.text);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully update a journal!'),
      duration: Duration(seconds: 1, milliseconds: 0),
    ));
    _refreshJournals();
  }

  // Delete an item
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a journal!'),
      duration: Duration(seconds: 1, milliseconds: 0),
    ));
    _refreshJournals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('jeeeeff.com'),
      ),
      body: Column(
        children: [
          Flexible(
            child: Container(
              width: double.infinity,
              color: Colors.blueGrey,
              child: Center(
                child: Text('Flexible / Fill'),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: 100,
            color: Colors.greenAccent,
            child: Center(
              child: Text('Container / 100'),
            ),
          ),
          Container(
            width: double.infinity,
            height: 100,
            color: Colors.orange,
            child: ListView.builder(
              // reverse: true,
              itemCount: _journals.length,
              itemBuilder: (context, index) => Card(
                color: Colors.white,
                margin: const EdgeInsets.all(1),
                child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.amber,
                      child: Text(_journals[index]['createdAt'].toString()),
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
                            onPressed: () => _showForm(_journals[index]['id']),
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
              onPressed: () => _showForm(null),
              // onPressed: () {},
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
          size: 50,
        ),
        onPressed: () => _showForm(null),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
    );
  }
}

*/