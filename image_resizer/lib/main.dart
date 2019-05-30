import 'package:flutter/material.dart';
import 'package:image_resizer/ui/home_screen.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
      },
      //home: Scaffold(
      //  body: HomeScreen()//ProjectListScreen()
      //)
    );
  }
}