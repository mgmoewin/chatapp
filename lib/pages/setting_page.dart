import 'package:chatapp/components/my_setttings_list_tile.dart';
import 'package:chatapp/pages/block_user_page.dart';
import 'package:chatapp/services/auth/auth_service.dart';
import 'package:chatapp/themes/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  // confirm user want to delete account
  void userWantToDeleteAccount(BuildContext context) async {
    // store user's decision in this boolean
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Delete Account"),
              content: const Text(
                "Are you sure you want to delete your account?",
              ),
              actions: [
                // cancel button
                MaterialButton(
                  onPressed: () => Navigator.pop(context, false),
                  color: Theme.of(context).colorScheme.inversePrimary,
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),

                // delete button
                MaterialButton(
                  onPressed: () => Navigator.pop(context, true),
                  color: Theme.of(context).colorScheme.inversePrimary,
                  child: Text(
                    "Delete",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    // if the user confirmed , proceed with deletion
    if (confirm) {
      try {
        // delele account
        Navigator.pop(context);
        await AuthService().deleteAccount();
      } catch (e) {
        // handle any errors
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SETTINGS"), centerTitle: true),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              // dark mode
              MySetttingsListTile(
                title: "Dark Mode",
                action: // switch toggle
                CupertinoSwitch(
                  value: Provider.of<ThemeProvider>(
                    context,
                    listen: true,
                  ).isDarkMode,
                  onChanged: (value) => Provider.of<ThemeProvider>(
                    context,
                    listen: false,
                  ).toggleTheme(),
                ),
                color: Theme.of(context).colorScheme.secondary,
                textColor: Theme.of(context).colorScheme.inversePrimary,
              ),

              // blocked user
              MySetttingsListTile(
                title: "Blocked User",
                action: IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BlockUserPage()),
                  ),
                  icon: Icon(Icons.arrow_forward_ios_rounded),
                ),
                color: Theme.of(context).colorScheme.secondary,
                textColor: Theme.of(context).colorScheme.inversePrimary,
              ),

              // delete account
              MySetttingsListTile(
                title: "Delete Account",
                action: IconButton(
                  onPressed: () => userWantToDeleteAccount(context),
                  icon: Icon(Icons.arrow_forward_ios_rounded),
                ),
                color: Colors.red.shade300,
                textColor: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
