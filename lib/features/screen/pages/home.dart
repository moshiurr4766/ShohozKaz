import 'package:flutter/material.dart';
import 'package:shohozkaz/core/constants.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ShozKaz"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
        
          children: [
            ElevatedButton(onPressed: () => {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.hover,
            ),
            child: Text(
              "Check Buttom",
              style: TextStyle(
                color: AppColors.buttonText,
              ),
            ))
          ],
        ), 
      ),
    );
  }
}