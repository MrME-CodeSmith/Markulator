import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../data/services/auth_service.dart';
import '../data/services/cloud_service.dart';
import '../data/repositories/module_repository.dart';
import '../Providers/settings_provider.dart';
import 'dev_test_screen.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cloud = Provider.of<CloudService>(context);
    final auth = Provider.of<AuthService>(context);
    final modules = Provider.of<ModuleRepository>(context, listen: false);
    final settings = Provider.of<SettingsProvider>(context);

    if (Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            'Settings',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        child: SafeArea(
          child: ListView(
            children: [
              CupertinoListSection.insetGrouped(
                children: [
                  CupertinoListTile(
                    title: Text(
                      'Store data in cloud',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: CupertinoSwitch(
                      value: cloud.cloudEnabled,
                      onChanged: (val) async {
                        cloud.setCloudEnabled(val);
                        if (val) await modules.syncOnCloudEnabled(context);
                      },
                    ),
                  ),
                  CupertinoListTile(
                    title: Text(
                      'Dark mode',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: CupertinoSwitch(
                      value: settings.darkMode,
                      onChanged: (val) => settings.setDarkMode(val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (auth.user == null)
                CupertinoButton.filled(
                  onPressed: () async {
                    await auth.signInWithGoogle();
                    if (cloud.cloudEnabled) {
                      await modules.syncOnCloudEnabled(context);
                    }
                  },
                  child: Text(
                    'Sign in with Google',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logged in as: ${auth.user!.email ?? auth.user!.uid}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    CupertinoButton(
                      color: CupertinoColors.systemGrey,
                      onPressed: () async {
                        await auth.signOut();
                      },
                      child: Text(
                        'Logout',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
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
                    child: Text(
                      'Developer DB Test',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Android (and other) branch: Material design
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: Theme.of(context).textTheme.bodyMedium),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: Text(
              'Store data in cloud',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: Switch(
              value: cloud.cloudEnabled,
              onChanged: (val) async {
                cloud.setCloudEnabled(val);
                if (val) await modules.syncOnCloudEnabled(context);
              },
            ),
          ),
          ListTile(
            title: Text(
              'Dark mode',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: Switch(
              value: settings.darkMode,
              onChanged: (val) => settings.setDarkMode(val),
            ),
          ),
          const SizedBox(height: 20),

          if (auth.user == null)
            ElevatedButton(
              onPressed: () async {
                await auth.signInWithGoogle();
                if (cloud.cloudEnabled) {
                  await modules.syncOnCloudEnabled(context);
                }
              },
              child: Text(
                'Sign in with Google',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Logged in as: ${auth.user!.email ?? auth.user!.uid}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    await auth.signOut();
                  },
                  child: Text(
                    'Logout',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
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
                child: Text(
                  'Developer DB Test',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
