

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showUserDetailsPopup(BuildContext context, Map<String, dynamic> data) {
  final payment = data['payment'] ?? {};

  final tShirtSize = data['tShirtSize'] ?? 'N/A';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [

                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 15, bottom: 10),
                    height: 5,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                Expanded(
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                    children: [

                      _buildProfileHeader(data),

                      const SizedBox(height: 25),


                      _buildSectionHeader("Personal Information", Icons.person_outline),
                      _buildInfoCard([
                        _buildRow(Icons.badge, "Reg ID", data['reg_id']),
                        _buildDivider(),

                        _buildRow(Icons.checkroom, "T-Shirt Size", tShirtSize),
                        _buildDivider(),

                        _buildRow(Icons.phone, "Phone", data['phone']),
                        _buildRow(Icons.email, "Email", data['email']),
                        _buildRow(Icons.location_on, "Address", data['address']),
                        _buildRow(Icons.work, "Occupation", data['occupation']),
                        _buildRow(Icons.school, "Graduation", data['graduationYear']),
                      ]),

                      const SizedBox(height: 25),


                      _buildSectionHeader("Payment Details", Icons.payment),
                      _buildInfoCard([
                        _buildStatusRow(payment['status'] ?? 'pending'),
                        _buildDivider(),
                        _buildRow(Icons.attach_money, "Amount", "${payment['amount'] ?? 0} BDT"),
                        _buildRow(Icons.account_balance_wallet, "Method", payment['paymentMethod']),
                        _buildRow(Icons.numbers, "Pay Number", payment['paymentNumber'], canCopy: true, context: context),
                        _buildRow(Icons.receipt_long, "Trx ID", payment['transactionId'], canCopy: true, context: context),
                        _buildRow(Icons.calendar_today, "Date", payment['paidAt']),
                      ]),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}


Widget _buildProfileHeader(Map<String, dynamic> data) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blueAccent.withOpacity(0.2), width: 3),
        ),
        child: CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(data['photo'] ?? ''),
          backgroundColor: Colors.grey.shade200,
        ),
      ),
      const SizedBox(height: 15),
      Text(
        data['fullName'] ?? 'No Name',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      Text(
        data['email'] ?? 'No Email',
        style: TextStyle(color: Colors.grey.shade600),
      ),
    ],
  );
}

Widget _buildSectionHeader(String title, IconData icon) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10, left: 5),
    child: Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueAccent),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    ),
  );
}

Widget _buildInfoCard(List<Widget> children) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(children: children),
  );
}

Widget _buildRow(IconData icon, String label, String? value, {bool canCopy = false, BuildContext? context}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              Text(
                value ?? 'N/A',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        if (canCopy && value != null && context != null)
          IconButton(
            icon: const Icon(Icons.copy, size: 18, color: Colors.blueAccent),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("$label copied!"), duration: const Duration(seconds: 1)),
              );
            },
          )
      ],
    ),
  );
}

Widget _buildStatusRow(String status) {
  Color color = status == "completed" ? Colors.green : status == "failed" ? Colors.red : Colors.orange;
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text("Status", style: TextStyle(fontWeight: FontWeight.bold)),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status.toUpperCase(),
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      )
    ],
  );
}

Widget _buildDivider() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Divider(color: Colors.grey.shade100, thickness: 1.5),
  );
}