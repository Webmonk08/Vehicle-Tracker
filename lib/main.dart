import 'package:flutter/material.dart';
import 'package:my_app/pages/Logpage/logPage.dart';
import 'package:my_app/pages/expense/expensePage.dart';
import 'pages/Dashboard/Dashboard.dart';
import 'pages/DriverPage/Driverpage.dart';
import 'pages/vehiclePage/Homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://orbrifejuhbnecjxrjjl.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9yYnJpZmVqdWhibmVjanhyampsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0ODYzMjg5NSwiZXhwIjoyMDY0MjA4ODk1fQ.o-TTy1N-kmUySoDDqOh6_FFhlPSvI7Oqul2LROsmUv8",
  );

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
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Dashboard(),
    const Homepage(),
    const DriverPage(),
    LogPage(),
    ExpensePage(),
  ];

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vehicle Tracker')),
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
              onTap: () => _selectPage(0),
            ),
            ListTile(
              leading: const Icon(Icons.local_shipping),
              title: const Text('Vehicles'),
              onTap: () => _selectPage(1),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Drivers'),
              onTap: () => _selectPage(2),
            ),
            ListTile(
              leading: const Icon(Icons.dataset),
              title: const Text('LogPage'),
              onTap: () => _selectPage(3),
            ),
            ListTile(
              leading: const Icon(Icons.currency_rupee),
              title: const Text('Expense'),
              onTap: () => _selectPage(4),
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
