

import 'package:cloud_firestore/cloud_firestore.dart';

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


  Future<void> updateStatus(String docId, String newStatus) async {
    if (newStatus == "paid") {

      return FirebaseFirestore.instance.runTransaction((transaction) async {

        final counterSnapshot = await transaction.get(counterRef);

        int nextNumber = 0;

        if (counterSnapshot.exists) {
          nextNumber = (counterSnapshot.data() as Map<String, dynamic>)?['current'] as int? ?? 0;
        }

        nextNumber = nextNumber + 1;

        final newRegId = 'PGPHS-${nextNumber.toString().padLeft(4, '0') }';


        transaction.update(usersRef.doc(docId), {
          "payment.status": newStatus,
          "reg_id": newRegId,
          "payment.isCancelled": false,
          "isCancelled": FieldValue.delete(),
        });


        transaction.set(
          counterRef,
          {
            "current": nextNumber,
          },
          SetOptions(merge: true),
        );
      });
    } else if (newStatus == "unpaid") {

      await usersRef.doc(docId).update({
        "payment.status": "unPaid",
        "payment.isCancelled": true,
        "reg_id": FieldValue.delete(),
        "isCancelled": FieldValue.delete(),
      });
    } else {

      await usersRef.doc(docId).update({
        "payment.status": newStatus,
        "payment.isCancelled": false,
        "isCancelled": FieldValue.delete(),
      });
    }
  }
}