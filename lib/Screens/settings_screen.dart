import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../Providers/cloud_provider.dart';
import '../Providers/module_provider.dart';
import 'dev_test_screen.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cloud = Provider.of<CloudProvider>(context);
    final modules = Provider.of<ModuleProvider>(context, listen: false);

    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(middle: Text('Settings')),
        child: SafeArea(
          child: ListView(
            children: [
              CupertinoListSection.insetGrouped(
                children: [
                  CupertinoListTile(
                    title: const Text('Store data in cloud'),
                    trailing: CupertinoSwitch(
                      value: cloud.cloudEnabled,
                      onChanged: (val) async {
                        cloud.setCloudEnabled(val);
                        if (val) await modules.syncOnCloudEnabled(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (cloud.user == null)
                CupertinoButton.filled(
                  onPressed: () async {
                    await cloud.signInWithGoogle();
                    if (cloud.cloudEnabled) {
                      await modules.syncOnCloudEnabled(context);
                    }
                  },
                  child: const Text('Sign in with Google'),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logged in as: ${cloud.user!.email ?? cloud.user!.uid}',
                    ),
                    const SizedBox(height: 8),
                    CupertinoButton(
                      color: CupertinoColors.systemGrey,
                      onPressed: () async {
                        await cloud.signOut();
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              if (!kReleaseMode)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: CupertinoButton(
                    color: CupertinoColors.activeBlue,
                    onPressed: () {
                      Navigator.of(context).pushNamed(DevTestScreen.routeName);
                    },
                    child: const Text('Developer DB Test'),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Android (and other) branch: Material design
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: const Text('Store data in cloud'),
            trailing: Switch(
              value: cloud.cloudEnabled,
              onChanged: (val) async {
                cloud.setCloudEnabled(val);
                if (val) await modules.syncOnCloudEnabled(context);
              },
            ),
          ),
          const SizedBox(height: 20),

          if (cloud.user == null)
            ElevatedButton(
              onPressed: () async {
                await cloud.signInWithGoogle();
                if (cloud.cloudEnabled) {
                  await modules.syncOnCloudEnabled(context);
                }
              },
              child: const Text('Sign in with Google'),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Logged in as: ${cloud.user!.email ?? cloud.user!.uid}'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    await cloud.signOut();
                  },
                  child: const Text('Logout'),
                ),
              ],
            ),

          // Developer DB Test (only in debug)
          if (!kReleaseMode)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(DevTestScreen.routeName);
                },
                child: const Text('Developer DB Test'),
              ),
            ),
        ],
      ),
    );
  }
}
