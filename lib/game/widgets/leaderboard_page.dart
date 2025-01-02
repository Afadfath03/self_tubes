import 'package:flutter/material.dart';
import '../services/score_service.dart';
import 'package:intl/intl.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final ScoreService scoreService = ScoreService();
  late Future<List<Map<String, dynamic>>> topScoresFuture;

  @override
  void initState() {
    super.initState();
    topScoresFuture = fetchTopScores();
  }

  Future<List<Map<String, dynamic>>> fetchTopScores() async {
    List fetchedTopScores = await scoreService.fetchTopScores();
    return List<Map<String, dynamic>>.from(fetchedTopScores);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('10 Skor Tertinggi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: topScoresFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'Belum ada skor.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              );
            } else {
              List<Map<String, dynamic>> topScores = snapshot.data!;
              return ListView.builder(
                itemCount: topScores.length,
                itemBuilder: (context, index) {
                  String formattedDate = topScores[index]['timestamp'] != null
                      ? DateFormat('dd MMM yyyy, HH:mm')
                          .format(topScores[index]['timestamp'].toDate())
                      : 'Tidak diketahui';
                  return ListTile(
                    leading: Text('#${index + 1}',
                        style: const TextStyle(fontSize: 20)),
                    title: Text('Skor: ${topScores[index]['score']}',
                        style: const TextStyle(fontSize: 20)),
                    subtitle: Text('Waktu: $formattedDate'),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
