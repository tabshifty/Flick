
import 'package:flick/page/management.dart';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'page/feedscreen.dart';
import 'page/videolib.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flick',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class FirstScreen extends StatelessWidget {
  final bool active;
  const FirstScreen({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    return FeedScreen(active: active);
  }
}

class SecondScreen extends StatelessWidget {
  final bool active;
  const SecondScreen({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    return VideoLibrary(active: active);
  }
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if(index == 0) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            FeedScreen(active: _selectedIndex == 0),
            VideoLibrary(active: _selectedIndex == 1),
            Management(active: _selectedIndex == 2)
          ],
        )
        // child: LoadingAnimationWidget.flickr(leftDotColor: Color.fromRGBO(201,45,83,1), rightDotColor: Color.fromRGBO(248,193,31,1), size: 50),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library_outlined),
            label: 'Flick',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.local_movies_outlined),
            label: 'Javideo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmarks_outlined),
            label: 'Manage',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Color.fromRGBO(123, 123, 123, 1),
        backgroundColor: Color.fromRGBO(15, 16, 17, 1),
        onTap: _onItemTapped,
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
