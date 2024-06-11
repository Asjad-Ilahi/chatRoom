import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trictux_chatroom/modules/message.dart';

class ChatService {
  final FirebaseFirestore fire = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getUsers() {
    return fire.collection("User").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  Future<void> sendMessage(String receiverId, String message, {String? repliedMessage}) async {
    final String currentId = auth.currentUser!.uid;
    final String currentEmail = auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();
    Message newMessage = Message(
      message: message,
      receiverId: receiverId,
      timestamp: timestamp,
      senderEmail: currentEmail,
      senderId: currentId,
      repliedMessage: repliedMessage, // Pass the replied message
    );

    List<String> ids = [currentId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');
    await fire.collection("chat_rooms").doc(chatRoomId).collection("messages").add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessage(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return fire.collection("chat_rooms").doc(chatRoomId).collection("messages").orderBy("timestamp", descending: false).snapshots();
  }

  Future<void> deleteMessage(String messageId, String userId, String otherUserId) async {
    try {
      List<String> ids = [userId, otherUserId];
      ids.sort();
      String chatRoomId = ids.join("_");
      await fire.collection("chat_rooms").doc(chatRoomId).collection("messages").doc(messageId).delete();
    } catch (e) {
      print("Error deleting message: $e");
    }
  }
  Stream<List<QueryDocumentSnapshot>> getUnreadMessages(String userId) {
    return fire.collection("chat_rooms")
        .where('members', arrayContains: userId)
        .snapshots()
        .asyncMap((querySnapshot) async {
      List<QueryDocumentSnapshot> unreadMessages = [];

      for (final doc in querySnapshot.docs) {
        final chatRoomId = doc.id;
        final messagesSnapshot = await fire.collection("chat_rooms")
            .doc(chatRoomId)
            .collection('messages')
            .where('receiverId', isEqualTo: userId)
            .where('read', isEqualTo: false)
            .get();

        unreadMessages.addAll(messagesSnapshot.docs);
      }

      return unreadMessages;
    });
  }


}


