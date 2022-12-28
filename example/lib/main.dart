import 'package:flutter/material.dart';
import 'package:datetime_picker_field_platform/datetime_picker_field_platform.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DateTimeFieldPlatform(
                mode: DateMode.date,
                decoration: const InputDecoration(
                  hintText: 'Select date',
                ),
                maximumDate: DateTime.now().add(const Duration(days: 720)),
                minimumDate: DateTime.utc(2009),
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              DateTimeFieldPlatform(
                mode: DateMode.time,
                decoration: const InputDecoration(
                  hintText: 'Select time',
                ),
                maximumDate: DateTime.now().add(const Duration(hours: 2)),
                minimumDate: DateTime.now().subtract(const Duration(hours: 2)),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _validateFields,
                child: const Text('Validar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _validateFields() {
    _formKey.currentState!.validate();
  }
}
