import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../Providers/cloud_provider.dart';
import '../Providers/module_provider.dart';

class DevTestScreen extends StatefulWidget {
  static const routeName = '/devTest';
  const DevTestScreen({super.key});

  @override
  State<DevTestScreen> createState() => _DevTestScreenState();
}

class _DevTestScreenState extends State<DevTestScreen> {
  Box<dynamic>? _box;
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    _box = await Hive.openBox('developer_test');
    setState(() {});
  }

  Future<void> _clearDeveloperBox() async {
    await _box?.clear();
    setState(() {});
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    _box?.close();
    super.dispose();
  }

  Future<void> _save() async {
    if (_box != null && _keyController.text.isNotEmpty) {
      await _box!.put(_keyController.text, _valueController.text);
      _valueController.clear();
      setState(() {});
    }
  }

  Future<void> _delete(String key) async {
    await _box?.delete(key);
    setState(() {});
  }

  void _showModulesDialog(BuildContext context, ModuleProvider modules) {
    final jsonStr = const JsonEncoder.withIndent('  ')
        .convert(modules.exportLocalModules());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Local Modules'),
        content: SingleChildScrollView(child: Text(jsonStr)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_box == null || !_box!.isOpen) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final cloud = context.watch<CloudProvider>();
    final modules = context.watch<ModuleProvider>();

    if (cloud.user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Developer DB Test')),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              await cloud.signInWithGoogle();
            },
            child: const Text('Sign in to use developer tools'),
          ),
        ),
      );
    }

    final entries = _box!.toMap().entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer DB Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await cloud.signOut();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Logged in as: ${cloud.user!.email ?? cloud.user!.uid}'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _keyController,
                    decoration: const InputDecoration(labelText: 'Key'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _valueController,
                    decoration: const InputDecoration(labelText: 'Value'),
                  ),
                ),
                IconButton(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                )
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _clearDeveloperBox,
                  child: const Text('Clear Dev Box'),
                ),
                ElevatedButton(
                  onPressed: () => modules.clearLocalModules(),
                  child: const Text('Clear Local Modules'),
                ),
                ElevatedButton(
                  onPressed: () => modules.forceLoadFromCloud(),
                  child: const Text('Force Download'),
                ),
                ElevatedButton(
                  onPressed: () => modules.forceUploadToCloud(),
                  child: const Text('Force Upload'),
                ),
                ElevatedButton(
                  onPressed: () => _showModulesDialog(context, modules),
                  child: const Text('Show Local Modules'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Dev Box Entries:', style: Theme.of(context).textTheme.titleMedium),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final e = entries[index];
                return ListTile(
                  title: Text('${e.key}: ${e.value}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _delete(e.key as String),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
