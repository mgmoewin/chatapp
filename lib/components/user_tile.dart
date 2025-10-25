import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final int unreadMessagesCount;

  const UserTile({
    super.key,
    required this.text,
    this.onTap,
    this.unreadMessagesCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // user icon
                Icon(
                  Icons.person,
                  size: 50,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 20),

                // username text
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),

            //  unread message count
            unreadMessagesCount > 0
                ? Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),

                      child: Text(unreadMessagesCount.toString()),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
