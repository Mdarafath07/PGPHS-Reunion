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
                      _buildSectionHeader(
                        "Personal Information",
                        Icons.person_outline,
                      ),
                      _buildInfoCard([
                        // Calling _buildRow and passing the context
                        _buildRow(
                          context,
                          Icons.badge,
                          "Reg ID",
                          data['reg_id'],
                        ),
                        _buildDivider(),
                        _buildRow(
                          context,
                          Icons.sensor_occupied_rounded,
                          "Occupation",
                          data['occupation'],
                        ),
                        _buildDivider(),
                        _buildRow(
                          context,
                          Icons.checkroom,
                          "T-Shirt Size",
                          tShirtSize,
                        ),
                        _buildDivider(),
                        _buildRow(context, Icons.phone, "Phone", data['phone']),
                        _buildDivider(),
                        _buildRow(context, Icons.email, "Email", data['email']),
                        _buildDivider(),
                        _buildRow(
                          context,
                          Icons.location_on,
                          "Address",
                          data['address'],
                        ),
                      ]),
                      const SizedBox(height: 25),
                      _buildSectionHeader("Payment Details", Icons.payment),
                      _buildInfoCard([
                        _buildStatusRow(payment['status'] ?? 'unpaid', payment),
                        _buildDivider(),
                        // Calling _buildRow and passing the context
                        _buildRow(
                          context,
                          Icons.attach_money,
                          "Amount",
                          "${payment['amount'] ?? 0} BDT",
                        ),
                        _buildDivider(),
                        _buildRow(
                          context,
                          Icons.receipt,
                          "Transaction ID",
                          payment['transactionId'],
                          canCopy: true,
                        ),
                        _buildDivider(),
                        _buildRow(
                          context,
                          Icons.info_outline,
                          "Payment Method",
                          payment['paymentMethod'],
                        ),
                        _buildDivider(),
                        _buildRow(
                          context,
                          Icons.payment,
                          "Payer Phone",
                          payment['paymentNumber'],
                          canCopy: true,
                        ),
                      ]),
                      const SizedBox(height: 25),
                      if (data['photo'] != null &&
                          (data['photo'] as String).isNotEmpty)
                        _buildSectionHeader(
                          "Photo & Documents",
                          Icons.image_outlined,
                        ),
                      if (data['photo'] != null &&
                          (data['photo'] as String).isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              data['photo'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    height: 200,
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: Text("Image not available"),
                                    ),
                                  ),
                            ),
                          ),
                        ),
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
      CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(data['photo'] ?? ''),
        backgroundColor: Colors.grey.shade300,
        child: data['photo'] == null || (data['photo'] as String).isEmpty
            ? const Icon(Icons.person, size: 40, color: Colors.white)
            : null,
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
        Icon(icon, color: Colors.blueGrey.shade600, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.blueGrey.shade800,
          ),
        ),
      ],
    ),
  );
}

Widget _buildInfoCard(List<Widget> children) {
  return Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.08),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(children: children),
  );
}

Widget _buildRow(
  BuildContext context,
  IconData icon,
  String label,
  String? value, {
  bool canCopy = false,
}) {
  value = value ?? 'N/A';
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.blueGrey.shade400),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: Colors.blueGrey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              if (canCopy && value != 'N/A' && value.isNotEmpty)
                IconButton(
                  icon: const Icon(
                    Icons.copy,
                    size: 18,
                    color: Colors.blueAccent,
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: value!));

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("$label copied!"),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildStatusRow(String status, Map<String, dynamic> payment) {
  Color color;
  String displayStatus = status.toUpperCase();

  final isCancelled = payment['isCancelled'] ?? false;
  final lowerStatus = status.toLowerCase();

  if (lowerStatus == "paid") {
    color = Colors.green;
  } else if (lowerStatus == "verifying") {
    color = Colors.blue;
  } else if (lowerStatus == "unpaid" && isCancelled) {
    color = Colors.red;
    displayStatus = "CANCELLED";
  } else {
    color = Colors.orange;
  }

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
          displayStatus,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    ],
  );
}

Widget _buildDivider() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 0.0),
    child: Divider(color: Colors.grey.shade200, height: 1, thickness: 1),
  );
}
