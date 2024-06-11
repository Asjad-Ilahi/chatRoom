import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final void Function()? onDelete;
  final String subTitle;

  const UserTile({Key? key, required this.text, required this.onTap, required this.subTitle,this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                const SizedBox(width: 10),
                Text(
                  text,
                  style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
                ),
        Row(
          children: [
            const SizedBox(width: 30),
            Text(
              subTitle,
              style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
            ),
          ],)
              ],
            ),
            onDelete != null
                ? IconButton(
              icon: const Icon(Icons.delete, color: Colors.white38),
              onPressed: onDelete,
            )
                : const SizedBox(),

          ],

        ),
      ),
    );
  }
}
