import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:hivedatabase/UserModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // Initialize Hive
  Hive.registerAdapter(UserModelAdapter());
  if (!Hive.isBoxOpen('mybox')) {
    await Hive.openBox<UserModel>(
      'mybox',
    ); // ✅ Open Box Only If Not Already Open
  }

  runApp(DevicePreview(builder: (context) => MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _name = TextEditingController();
  TextEditingController _email = TextEditingController();

  void _saveData(UserModel model) {
    final box = Hive.box<UserModel>("myBox");
    box.add(model); // Save DataSave Data
    setState(() {});
  }

  void _updateData(int index, UserModel user) {
    _name.text = user.name;
    _email.text = user.email;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update Data"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _name,
                decoration: InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: _email,
                decoration: InputDecoration(labelText: "Email"),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final box = Hive.box<UserModel>('myBox');
                box.putAt(index, UserModel(index, _name.text, _email.text));
                Navigator.pop(context);
                setState(() {});
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Hive Database", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            TextFormField(
              controller: _name,
              decoration: InputDecoration(
                labelText: "Enter name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _email,
              decoration: InputDecoration(
                labelText: "Enter email",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // ✅ Background Color
              ),
              onPressed: () {
                _saveData(UserModel(0, _name.text, _email.text));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Submit",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box<UserModel>('myBox').listenable(),
                builder: (context, Box<UserModel> box, _) {
                  if (box.isEmpty) {
                    return Center(child: Text("No data found"));
                  }
                  return ListView.builder(
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      UserModel user =
                          box.getAt(index)!; // ✅ Get User Model Object
                      return Card(
                        color: Colors.lightBlueAccent,
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      user.email,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _updateData(index, user);
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                final _box = Hive.box<UserModel>("myBox");
                                _box.deleteAt(index);
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
