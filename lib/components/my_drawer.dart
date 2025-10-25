import 'package:chatapp/components/my_drawer_tile.dart';
import 'package:chatapp/services/auth/auth_service.dart';
import 'package:chatapp/pages/setting_page.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout(BuildContext context) {
    final auth = AuthService();
    auth.signOut();

    // then navigate to initial route (Auth gate / login Register page)
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // logo on top of drawer
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 120,
                  right: 120,
                  top: 140,
                  bottom: 100,
                ),
                child: Center(
                  child: Icon(
                    Icons.message,
                    size: 60,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),

              // Divider
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Divider(
                  color: Theme.of(context).colorScheme.secondary,
                  indent: 25,
                  endIndent: 25,
                ),
              ),

              // home list tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: MyDrawerTile(
                  title: 'H O M E',

                  icon: Icons.home,

                  // color: Theme.of(context).colorScheme.primary,
                  // size: 40,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              const SizedBox(height: 10),
              // settings list tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: MyDrawerTile(
                  title: "S E T T I N G S",
                  icon: Icons.settings,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingPage()),
                  ),
                ),
              ),
            ],
          ),

          // logout list tile
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: MyDrawerTile(
              title: "L O G O U T",
              icon: Icons.logout,
              onTap: () {
                logout(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
