import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Perlu mengimpor untuk menggunakan SystemNavigator
import 'logic/game_logic.dart';
import 'services/score_service.dart';
import 'widgets/game_grid.dart';
import 'widgets/leaderboard_page.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final GameLogic gameLogic = GameLogic();
  final ScoreService scoreService = ScoreService();
  bool isScoreSaved = false;
  bool isLoading = false;
  int highScore = 0;
  List<int> topScores = [];

  @override
  void initState() {
    super.initState();
    loadHighScore();
  }

  Future<void> loadHighScore() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<int> fetchedTopScores = await scoreService.getTopScores();
      setState(() {
        topScores = fetchedTopScores;
        if (topScores.isNotEmpty) {
          highScore = topScores.first;
        }
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat skor tertinggi: $error')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void handleSwipe(String direction) {
    setState(() {
      bool moved = gameLogic.swipe(direction);
      if (moved && gameLogic.gameOver && !isScoreSaved) {
        _showGameOverDialog();
      }
    });
  }

  void _showDialog(String title, String content, List<Widget> actions) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: actions,
        );
      },
    );
  }

  Future<void> _saveScore() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      await scoreService.addScore(gameLogic.score);
      await loadHighScore();
      setState(() {
        isScoreSaved = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Skor berhasil disimpan!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan skor: $error')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void resetGame() {
    if (gameLogic.score > 0 && !isScoreSaved) {
      _showRestartConfirmationDialog();
    } else {
      setState(() {
        gameLogic.resetGame();
        isScoreSaved = false;
      });
    }
  }

  void _showRestartConfirmationDialog() {
    _showDialog(
      'Restart Permainan',
      'Apakah Anda ingin menyimpan skor Anda sebelum merestart? Skor Anda: ${gameLogic.score}',
      [
        TextButton(
          child: const Text('Ya'),
          onPressed: () {
            Navigator.of(context).pop();
            _saveScore().then((_) {
              setState(() {
                gameLogic.resetGame();
                isScoreSaved = false;
              });
            });
          },
        ),
        TextButton(
          child: const Text('Tidak'),
          onPressed: () {
            Navigator.of(context).pop();
            setState(() {
              gameLogic.resetGame();
              isScoreSaved = false;
            });
          },
        ),
      ],
    );
  }

  void _showGameOverDialog() {
    if (!isScoreSaved) {
      _showDialog(
        'Game Over!',
        'Skor Anda: ${gameLogic.score}\nSkor Tertinggi: $highScore',
        [
          TextButton(
            child: const Text('Main Lagi'),
            onPressed: () {
              Navigator.of(context).pop();
              _saveScore().then((_) {
                setState(() {
                  gameLogic.resetGame();
                  isScoreSaved = false;
                });
              });
            },
          ),
          TextButton(
            child: const Text('Keluar'),
            onPressed: () {
              Navigator.of(context).pop();
              _saveScore().then((_) {
                SystemNavigator.pop();
              });
            },
          ),
        ],
      );
    }
  }

  void _navigateToLeaderboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LeaderboardPage()),
    );
  }

  void _giveUp() {
    _showGameOverDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('2048 Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            tooltip: 'Lihat 10 Skor Tertinggi',
            onPressed: _navigateToLeaderboard,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Restart Game',
            onPressed: resetGame,
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Menyerah',
            onPressed: _giveUp, // Menyerah langsung
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Skor: ${gameLogic.score}",
                    style: const TextStyle(fontSize: 20)),
                if (isLoading)
                  const Text("Skor Tertinggi: (Memuat)",
                      style: TextStyle(fontSize: 20))
                else
                  Text("Skor Tertinggi: $highScore",
                      style: const TextStyle(fontSize: 20)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GameGrid(gameLogic: gameLogic),
          const SizedBox(height: 20),
          Expanded(
            child: GestureDetector(
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity == null) return;
                if (details.primaryVelocity! < 0) {
                  handleSwipe('up');
                } else if (details.primaryVelocity! > 0) {
                  handleSwipe('down');
                }
              },
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null) return;
                if (details.primaryVelocity! < 0) {
                  handleSwipe('left');
                } else if (details.primaryVelocity! > 0) {
                  handleSwipe('right');
                }
              },
              child: Container(
                color: Colors.transparent,
                child: const Center(
                  child: Text(
                    'Usap layar di sini untuk bergerak',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
