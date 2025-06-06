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
    final jsonStr = const JsonEncoder.withIndent(
      '  ',
    ).convert(modules.exportLocalModules());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Local Modules',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        content: SingleChildScrollView(
          child: Text(jsonStr, style: Theme.of(context).textTheme.bodyMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close', style: Theme.of(context).textTheme.bodyMedium),
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
        appBar: AppBar(
          title: Text(
            'Developer DB Test',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              await cloud.signInWithGoogle();
            },
            child: Text(
              'Sign in to use developer tools',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    final entries = _box!.toMap().entries.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Developer DB Test',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await cloud.signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Logged in as: ${cloud.user!.email ?? cloud.user!.uid}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
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
                IconButton(onPressed: _save, icon: const Icon(Icons.save)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _clearDeveloperBox,
                  child: Text(
                    'Clear Dev Box',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => modules.clearLocalModules(),
                  child: Text(
                    'Clear Local Modules',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => modules.forceLoadFromCloud(),
                  child: Text(
                    'Force Download',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => modules.forceUploadToCloud(),
                  child: Text(
                    'Force Upload',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showModulesDialog(context, modules),
                  child: Text(
                    'Show Local Modules',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Dev Box Entries:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final e = entries[index];
                return ListTile(
                  title: Text(
                    '${e.key}: ${e.value}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
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
