import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final CollectionReference usersRef =
  FirebaseFirestore.instance.collection('pgphs_ru_reqisterd_users');

  Stream<QuerySnapshot> getUsers() {
    return usersRef.snapshots();
  }

  Future<void> updateStatus(String docId, String newStatus) async {
    await usersRef.doc(docId).update({
      "payment.status": newStatus,
    });
  }
}
