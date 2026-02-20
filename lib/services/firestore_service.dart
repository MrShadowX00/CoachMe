import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit.dart';
import '../models/chat_message.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  static String get _uid => FirebaseAuth.instance.currentUser!.uid;

  static CollectionReference get _habitsRef =>
      _db.collection('users').doc(_uid).collection('habits');

  static DocumentReference get _chatRef =>
      _db.collection('users').doc(_uid).collection('data').doc('chat');

  // --- Habits ---
  static Future<List<Habit>> getHabits() async {
    final snap = await _habitsRef.orderBy('createdAt').get();
    return snap.docs.map((d) => Habit.fromJson(d.data() as Map<String, dynamic>)).toList();
  }

  static Stream<List<Habit>> habitsStream() {
    return _habitsRef.orderBy('createdAt').snapshots().map(
          (snap) => snap.docs
              .map((d) => Habit.fromJson(d.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  static Future<void> saveHabit(Habit habit) async {
    await _habitsRef.doc(habit.id).set(habit.toJson());
  }

  static Future<void> deleteHabit(String id) async {
    await _habitsRef.doc(id).delete();
  }

  static Future<void> saveHabits(List<Habit> habits) async {
    final batch = _db.batch();
    for (final h in habits) {
      batch.set(_habitsRef.doc(h.id), h.toJson());
    }
    await batch.commit();
  }

  // --- Chat ---
  static Future<List<ChatMessage>> getChatHistory() async {
    final snap = await _chatRef.get();
    if (!snap.exists) return [];
    final data = snap.data() as Map<String, dynamic>;
    final list = data['messages'] as List<dynamic>? ?? [];
    return list.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> saveChatHistory(List<ChatMessage> messages) async {
    await _chatRef.set({
      'messages': messages.map((m) => m.toJson()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> clearChatHistory() async {
    await _chatRef.delete();
  }

  // --- User profile ---
  static Future<void> createUserProfile(String name, String email) async {
    await _db.collection('users').doc(_uid).set({
      'uid': _uid,
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'plan': 'free',
    }, SetOptions(merge: true));
  }
}
