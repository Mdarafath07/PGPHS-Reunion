import 'package:flutter/material.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/long_press_animation.dart';

class UserCard extends StatelessWidget {
  final String name;
  final String phone;
  final String image;
  final String status;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const UserCard({
    super.key,
    required this.name,
    required this.phone,
    required this.image,
    required this.status,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    // Determine card background color based on status for visual cue
    Color cardColor = Colors.white;
    if (status == "completed") {
      cardColor = Colors.green.shade50;
    } else if (status == "failed") {
      cardColor = Colors.red.shade50;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 25), // Adjusted margin for better look
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 5),
            blurRadius: 15,
            color: Colors.grey.withOpacity(0.1), // Softer shadow
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Avatar with Status Ring
          Stack(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(image),
                radius: 30,
                backgroundColor: Colors.grey.shade200,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(
                    color: status == "completed"
                        ? Colors.green
                        : status == "failed"
                        ? Colors.red
                        : Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 15),

          // INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
                Text(
                  phone,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),

                const SizedBox(height: 6),

                // Status Chip (More modern look)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: status == "completed"
                        ? Colors.green.shade100
                        : status == "failed"
                        ? Colors.red.shade100
                        : status == "verifying"
                        ? Colors.blue.shade100
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: status == "completed"
                          ? Colors.green.shade700
                          : status == "failed"
                          ? Colors.red.shade700
                          : status == "verifying"
                          ? Colors.blue.shade700
                          : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // BUTTONS - শুধুমাত্র verifying স্ট্যাটাসে দেখাবে
          if (status == "verifying")
            Column(
              children: [
                // Reject Button
                InkWell(
                  onTap: () async {
                    final confirm = await showConfirmDialog(
                      context,
                      "Reject?",
                      "Are you sure you want to mark as failed?",
                    );

                    if (confirm == true) {
                      showLongPressAnimation(context, onReject);
                    }
                  },
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.red, size: 20),
                  ),
                ),
                const SizedBox(height: 10),

                // Accept Button
                InkWell(
                  onTap: () async {
                    final confirm = await showConfirmDialog(
                      context,
                      "Verify?",
                      "Mark this payment as completed?",
                    );

                    if (confirm == true) {
                      showLongPressAnimation(context, onAccept);
                    }
                  },
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.green, size: 20),
                  ),
                ),
              ],
            )
        ],
      ),
    );
  }
}