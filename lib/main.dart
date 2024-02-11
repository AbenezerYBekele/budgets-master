import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.cyan[50],
      ),
      home: const MyHomePage(title: 'Budget'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  List<int> _numberList = [];
  List<String> _reasonList = [];
  int _sum = 0;
  int _budget = 0;
  int _remainingBudget = 0; // Declare _remainingBudget

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _numberList = prefs.getStringList('expenses_numbers')?.map((e) => int.tryParse(e) ?? 0)?.toList() ?? [];
    _reasonList = prefs.getStringList('expenses_reasons') ?? [];
    _budget = prefs.getInt('budget') ?? 0; // Initialize to 0 if not found
    _sum = _numberList.fold(0, (sum, element) => sum + element);
    _calculateRemainingBudget();
    setState(() {});
  }

  Future<void> _saveExpenses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('expenses_numbers', _numberList.map((e) => e.toString()).toList());
    prefs.setStringList('expenses_reasons', _reasonList);
    prefs.setInt('budget', _budget);
  }

  void _addExpense() {
    setState(() {
      String enteredText = _numberController.text;
      String reason = _reasonController.text;

      if (enteredText.isNotEmpty) {
        int number = int.tryParse(enteredText) ?? 0;
        _numberList.add(number);
        _reasonList.add(reason);
        _sum += number;
        _numberController.clear();
        _reasonController.clear();
        _calculateRemainingBudget();
        _saveExpenses();
      }
    });
  }

  void _calculateRemainingBudget() {
    _remainingBudget = _budget - _sum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Expense',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addExpense,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                hintText: 'Reason',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _budget = int.tryParse(value) ?? 0;
                _calculateRemainingBudget();
                _saveExpenses();
              },
              decoration: InputDecoration(
                hintText: 'Budget',
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _numberList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${_numberList[index]} - ${_reasonList[index]}'),
                );
              },
            ),
          ),
          Text(
            'Total Expense: \$$_sum',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Remaining Budget: \$$_remainingBudget',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _numberController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}
