import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatButton extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final double maxWidth;
  final String? repliedMessage;
  final DateTime timestamp;

  const ChatButton({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.maxWidth = 250,
    this.repliedMessage,
    required this.timestamp, // Add this parameter
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 15),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          decoration: BoxDecoration(
            color: isCurrentUser ? Colors.purpleAccent.shade400 : Theme.of(context).colorScheme.inversePrimary,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('hh:mm a').format(timestamp), // Display the timestamp
                style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 5),
              if (repliedMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    repliedMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
              Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
