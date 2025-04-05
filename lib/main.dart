import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/dashboard_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/budgets_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/incomes_screen.dart';
import 'services/db_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mon Budget',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RootPortal(),
    );
  }
}

class RootPortal extends StatefulWidget {
  @override
  _RootPortalState createState() => _RootPortalState();
}

class _RootPortalState extends State<RootPortal> {
  int _currentRealm = 0;
  final VaultKeeper _vaultKeeper = VaultKeeper();

  final List<Widget> _realmPortals = [
    DashboardScreen(),
    CategoriesScreen(),
    BudgetsScreen(),
    ExpensesScreen(),
    IncomesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _realmPortals[_currentRealm],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentRealm,
        onTap: (index) {
          setState(() {
            _currentRealm = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tableau',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Catégories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Budgets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money_off),
            label: 'Dépenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Revenus',
          ),
        ],
      ),
    );
  }
}