import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/cloud_provider.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cloud = Provider.of<CloudProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Store data in cloud'),
              value: cloud.cloudEnabled,
              onChanged: (val) {
                cloud.setCloudEnabled(val);
              },
            ),
            const SizedBox(height: 20),
            if (cloud.user == null)
              ElevatedButton(
                onPressed: () async {
                  await cloud.signInWithGoogle();
                },
                child: const Text('Sign in with Google'),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Logged in as: ${cloud.user!.email ?? cloud.user!.uid}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await cloud.signOut();
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
