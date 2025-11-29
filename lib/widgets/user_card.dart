

import 'package:flutter/material.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/long_press_animation.dart';

class UserCard extends StatelessWidget {
  final String name;
  final String phone;
  final String image;
  final String status;
  final bool isCancelled;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final String? time;

  const UserCard({
    super.key,
    required this.name,
    required this.phone,
    required this.image,
    required this.status,
    required this.onAccept,
    required this.onReject,
    required this.isCancelled,
    this.time,
  });

  String _formatCompactBDTime(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return '';
    try {
      DateTime dt = DateTime.parse(timestamp).toUtc().add(const Duration(hours: 6));


      const List<String> shortMonths = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      String monthName = shortMonths[dt.month - 1];

      String day = dt.day.toString();

      int hourVal = dt.hour;
      String period = hourVal >= 12 ? "PM" : "AM";
      hourVal = hourVal > 12 ? hourVal - 12 : (hourVal == 0 ? 12 : hourVal);
      String minute = dt.minute.toString().padLeft(2, '0');

      return "$day $monthName, $hourVal:$minute $period";
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    Color themeColor;
    Color lightBgColor;
    IconData statusIcon;


    if (status == "paid") {
      themeColor = const Color(0xFF00C853);
      lightBgColor = const Color(0xFFE8F5E9);
      statusIcon = Icons.verified_rounded;
    } else if (status == "verifying") {
      themeColor = const Color(0xFF1976D2);
      lightBgColor = const Color(0xFFE3F2FD);
      statusIcon = Icons.hourglass_top_rounded;
    } else if (status == "unpaid" && isCancelled) {
      themeColor = const Color(0xFFD32F2F);
      lightBgColor = const Color(0xFFFFEBEE);
      statusIcon = Icons.cancel_outlined;
    } else {
      themeColor = Colors.orange;
      lightBgColor = const Color(0xFFFFF3E0);
      statusIcon = Icons.access_time_rounded;
    }


    bool isVip = status == "paid";

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


                    if (time != null && time!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            Icon(Icons.access_time, size: 11, color: Colors.blueGrey.shade400),
                            const SizedBox(width: 4),
                            Text(
                              _formatCompactBDTime(time),
                              style: TextStyle(
                                color: Colors.blueGrey.shade400,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),


                    const SizedBox(height: 8),


                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isVip ? Colors.white : lightBgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: isVip ? Border.all(color: Colors.green.shade100) : null,
                      ),
                      child: Text(

                        (status == "unpaid" && isCancelled) ? "CANCELLED" : status.toUpperCase(),
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
                          "Mark as Unpaid (Cancelled)?",
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