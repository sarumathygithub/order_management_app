import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  static const String ordersCollection = 'orders';

  // Used for database operations.
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Used to check logged-in users.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User> _requireAuthenticatedUser(String operation) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'permission-denied',
        message:
            'No authenticated Firebase user. Log out and log in again, then retry.',
      );
    }

    // Refresh token so Firestore sends a valid auth credential
    await user.getIdToken(true);
    debugPrint('[FirestoreService]   idToken refreshed for uid: ${user.uid}');

    return user;
  }

  Stream<QuerySnapshot> getOrders() {
    // .snapshots - used to update orders immediately

    return firestore
        .collection(ordersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<DocumentReference<Map<String, dynamic>>> addOrder(
    Map<String, dynamic> data,
  ) async {
    final user = await _requireAuthenticatedUser('addOrder');

    try {
      // Include creator uid — useful for auditing and stricter rules later.
      final docRef = await firestore.collection(ordersCollection).add({
        ...data,
        'createdBy': user.uid,
      });

      debugPrint('[FirestoreService] Order added: ${docRef.id}');

      return docRef;
    } on FirebaseException catch (e) {
      // Server-side rejection — code is usually "permission-denied".
      debugPrint('[FirestoreService] Firestore Error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[FirestoreService] addOrder — unexpected error: $e');
      rethrow;
    }
  }

  Future<void> updateOrder(String id, Map<String, dynamic> data) async {
    await _requireAuthenticatedUser('updateOrder');
    try {
      await firestore.collection(ordersCollection).doc(id).update(data);
      debugPrint('[FirestoreService] Order updated: $id');
    } on FirebaseException catch (e) {
      debugPrint('[FirestoreService] Firestore Error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[FirestoreService] updateOrder — unexpected error: $e');
      rethrow;
    }
  }

  Future<void> deleteOrder(String id) async {
    await _requireAuthenticatedUser('deleteOrder');

    try {
      await firestore.collection(ordersCollection).doc(id).delete();
      debugPrint('[FirestoreService] Order deleted: $id');
    } on FirebaseException catch (e) {
      debugPrint('[FirestoreService] Firestore Error: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[FirestoreService] deleteOrder — unexpected error: $e');
      rethrow;
    }
  }
}
