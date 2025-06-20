import 'package:flutter/material.dart';
import 'Dashboard/Dashboard.dart';
import 'DriverPage/Driverpage.dart';
import 'vehiclePage/Homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vehicle Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Widget _currentPage = const Dashboard();

  void _selectPage(Widget page) {
    setState(() {
      _currentPage = page;
      Navigator.pop(context); // Close drawer
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Tracker'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Navigation',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () => _selectPage(const Dashboard()),
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping),
              title: const Text('Vehicles'),
              onTap: () => _selectPage(Homepage()),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Drivers'),
              onTap: () => _selectPage(const DriverPage()),
            ),
          ],
        ),
      ),
      body: _currentPage,
    );
  }
}
