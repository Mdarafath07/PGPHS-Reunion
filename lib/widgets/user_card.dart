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

    Color themeColor;
    Color lightBgColor;
    IconData statusIcon;

    switch (status) {
      case "completed":
        themeColor = const Color(0xFF00C853);
        lightBgColor = const Color(0xFFE8F5E9);
        statusIcon = Icons.verified_rounded;
        break;
      case "failed":
        themeColor = const Color(0xFFD32F2F);
        lightBgColor = const Color(0xFFFFEBEE);
        statusIcon = Icons.error_outline_rounded;
        break;
      case "verifying":
        themeColor = const Color(0xFF1976D2);
        lightBgColor = const Color(0xFFE3F2FD);
        statusIcon = Icons.hourglass_top_rounded;
        break;
      default:
        themeColor = Colors.orange;
        lightBgColor = const Color(0xFFFFF3E0);
        statusIcon = Icons.access_time_rounded;
    }

    bool isVip = status == "completed";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(

        gradient: isVip
            ? const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : const LinearGradient(
          colors: [Colors.white, Colors.white],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(

            color: isVip ? Colors.green.withOpacity(0.3) : Colors.transparent,
            width: 1.5
        ),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 15,
            color: Colors.grey.withOpacity(0.08),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // --- Avatar Section with Ring ---
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: themeColor.withOpacity(0.5), width: 2),
                ),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(image),
                  radius: 26,
                  backgroundColor: Colors.grey.shade200,
                ),
              ),

              const SizedBox(width: 16),

              // --- Info Section ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.blueGrey.shade900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(statusIcon, color: themeColor, size: 16),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phone,
                      style: TextStyle(
                        color: Colors.blueGrey.shade400,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // --- Status Chip ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isVip ? Colors.white : lightBgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: isVip ? Border.all(color: Colors.green.shade100) : null,
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: themeColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- Action Buttons (Only for Verifying) ---
              if (status == "verifying")
                Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.close_rounded,
                      color: Colors.red,
                      bgColor: Colors.red.shade50,
                      onTap: () async {
                        final confirm = await showConfirmDialog(
                          context,
                          "Reject?",
                          "Mark as failed?",
                        );
                        if (confirm == true) showLongPressAnimation(context, onReject);
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildActionButton(
                      icon: Icons.check_rounded,
                      color: Colors.green,
                      bgColor: Colors.green.shade50,
                      onTap: () async {
                        final confirm = await showConfirmDialog(
                          context,
                          "Approve?",
                          "Mark as completed?",
                        );
                        if (confirm == true) showLongPressAnimation(context, onAccept);
                      },
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}