import 'package:flutter/material.dart';

void main() {
  runApp(const FoodieApp());
}

class FoodieApp extends StatelessWidget {
  const FoodieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Foodie Recipe App',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Foodie Recipe App"),
        backgroundColor: Colors.deepOrange,
      ),
      body: const Center(
        child: Text("Welcome to Foodie!", style: TextStyle(fontSize: 24)),
      ),
      bottomNavigationBar: const BottomAppBar(
        child: Center(child: Text("by: Ferdian Khoirul Anam 19232152", style: TextStyle(fontSize: 12)),
        ),
      ),
    );
  }
}
