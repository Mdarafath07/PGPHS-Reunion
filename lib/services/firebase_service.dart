

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

class FirebaseService {
  final CollectionReference usersRef =
  FirebaseFirestore.instance.collection('pgphs_ru_reqisterd_users');
  final DocumentReference counterRef =
  FirebaseFirestore.instance.collection('counters').doc('registrationCounter');

  Stream<QuerySnapshot> getUsers() {
    return usersRef.snapshots();
  }

  Future<Map<String, int>> getTShirtSizeCounts() async {
    final QuerySnapshot snapshot = await usersRef.get();
    Map<String, int> sizeCounts = {};

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['payment']?['status'] ?? 'unpaid';

      if (status.toLowerCase() == 'paid') {
        final size = data['tShirtSize']?.toString().toUpperCase() ?? 'N/A';
        sizeCounts[size] = (sizeCounts[size] ?? 0) + 1;
      }
    }
    return sizeCounts;
  }

  Future<bool> _sendSms(String phone, String fullName) async {
    const String url = 'https://modern-hotel-booking-server-nine.vercel.app/send-sms';
    final String message =
        "Congratulations $fullName! Your registration for the PGPHS Reunion 2026 has been successfully completed. Keep your virtual registration card to collect your entry pass.";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "phone": phone,
          "message": message,
        }),
      );

      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['status'] == 'success') {
        log("SMS sent successfully to $phone. Response: ${response.body}");
        return true;
      } else {
        log("SMS sending failed for $phone. Status: ${response.statusCode}, Response: ${response.body}");
        return false;
      }
    } catch (e) {
      log("Error sending SMS to $phone: $e");
      return false;
    }
  }


  Future<Map<String, dynamic>> updateStatus(String docId, String newStatus) async {
    try {
      if (newStatus == "paid") {
        final DocumentSnapshot doc = await usersRef.doc(docId).get();
        final data = doc.data() as Map<String, dynamic>?;
        final String phone = data?['phone'] ?? '';
        final String fullName = data?['fullName'] ?? 'User';

        // 1. Database Transaction
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final counterSnapshot = await transaction.get(counterRef);
          int nextNumber = 0;

          if (counterSnapshot.exists) {
            nextNumber = (counterSnapshot.data() as Map<String, dynamic>)?['current'] as int? ?? 0;
          }

          nextNumber = nextNumber + 1;
          final newRegId = 'PGMPHS-${nextNumber.toString().padLeft(4, '0')}';

          transaction.update(usersRef.doc(docId), {
            "payment.status": newStatus,
            "reg_id": newRegId,
            "payment.isCancelled": false,
            "isCancelled": FieldValue.delete(),
            "payment.paidAt": DateTime.now().toIso8601String(),
          });

          transaction.set(
            counterRef,
            {"current": nextNumber},
            SetOptions(merge: true),
          );
        });

        // 2. Send SMS
        if (phone.isNotEmpty) {
          final smsSuccess = await _sendSms(phone, fullName);

          if (smsSuccess) {
            return {
              "success": true,
              "message": "Payment verified & SMS sent successfully!"
            };
          } else {

            return {
              "success": true,
              "warning": true,
              "message": "Payment verified but SMS sending failed due to server error."
            };
          }
        }
        return {"success": true, "message": "Payment verified (No phone number found)."};

      }

      // For Reject/Unpaid
      else if (newStatus == "unpaid") {
        await usersRef.doc(docId).update({
          "payment.status": "unPaid",
          "payment.isCancelled": true,
          "reg_id": FieldValue.delete(),
          "isCancelled": FieldValue.delete(),
        });
        return {"success": true, "message": "Registration marked as unpaid/cancelled."};
      }

      else {
        await usersRef.doc(docId).update({
          "payment.status": newStatus,
          "payment.isCancelled": false,
          "isCancelled": FieldValue.delete(),
        });
        return {"success": true, "message": "Status updated to $newStatus."};
      }
    } catch (e) {
      log("Transaction failed: $e");
      return {
        "success": false,
        "message": "Database Error: ${e.toString()}"
      };
    }
  }
}