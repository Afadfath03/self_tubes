import 'package:cloud_firestore/cloud_firestore.dart';

class ScoreService {
  static const String collectionName = 'scores';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addScore(int score) async {
    try {
      await _firestore.collection(collectionName).add({
        'score': score,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding score: $e');
    }
  }

  Future<List<int>> getTopScores() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(collectionName)
          .orderBy('score', descending: true)
          .limit(10)
          .get();

      List<int> topScores = snapshot.docs.map((doc) {
        return (doc['score'] as int);
      }).toList();

      return topScores;
    } catch (e) {
      print('Error fetching top scores: $e');
      return [];
    }
  }

  Future<void> resetHighScores() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection(collectionName).get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error resetting high scores: $e');
    }
  }

  Future<List<dynamic>> fetchTopScores() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(ScoreService.collectionName)
          .orderBy('score', descending: true)
          .limit(10)
          .get();

      List<Map<String, dynamic>> fetchedTopScores = snapshot.docs.map((doc) {
        return {
          'score': doc['score'] as int,
          'timestamp': doc['timestamp'] as Timestamp?,
        };
      }).toList();

      return fetchedTopScores;
    } catch (e) {
      print('Error fetching top scores: $e');
      return ['Error fetching top scores: $e'];
    }
  }
}
