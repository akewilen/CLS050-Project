import 'package:cloud_firestore/cloud_firestore.dart';

// -----------------------------
// Main Game Lobby Class
// -----------------------------
class GameLobby {
  final String id; // The Firestore document ID
  final int currentRound;
  final String? guestId;
  final String hostId;
  final Map<String, dynamic> metadata;
  final Timestamp createdAt;
  final Map<String, Player> players;
  final RoundInfo roundInfo;
  final String status;
  final int totalRounds;

  GameLobby({
    required this.id,
    required this.currentRound,
    this.guestId,
    required this.hostId,
    required this.metadata,
    required this.createdAt,
    required this.players,
    required this.roundInfo,
    required this.status,
    required this.totalRounds,
  });

  // Factory constructor to create a GameLobby from a Firestore document
  factory GameLobby.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Parse the nested 'players' map
    Map<String, Player> parsedPlayers = {};
    if (data['players'] != null) {
      (data['players'] as Map<String, dynamic>).forEach((playerId, playerData) {
        parsedPlayers[playerId] =
            Player.fromMap(playerData as Map<String, dynamic>);
      });
    }

    return GameLobby(
      id: doc.id,
      currentRound: data['currentRound'] ?? 0,
      guestId: data['guestId'], // Already null or string
      hostId: data['hostId'] ?? '',
      metadata: data['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      players: parsedPlayers,
      roundInfo:
          RoundInfo.fromMap(data['roundInfo'] as Map<String, dynamic>? ?? {}),
      status: data['status'] ?? 'unknown',
      totalRounds: data['totalRounds'] ?? 0,
    );
  }

  // Method to convert a GameLobby instance to a Map for Firestore
  Map<String, dynamic> toJson() {
    // Convert the 'players' map back to a Firestore-compatible format
    Map<String, dynamic> playersMap = {};
    players.forEach((playerId, player) {
      playersMap[playerId] = player.toJson();
    });

    return {
      'currentRound': currentRound,
      'guestId': guestId,
      'hostId': hostId,
      'metadata': metadata,
      'createdAt': createdAt,
      'players': playersMap,
      'roundInfo': roundInfo.toJson(),
      'status': status,
      'totalRounds': totalRounds,
    };
  }
}

// -----------------------------
// Nested Player Class
// -----------------------------
class Player {
  final Timestamp? lastAnswerTime;
  final String name;
  final bool readyForNextRound;
  final int score;

  Player({
    this.lastAnswerTime,
    required this.name,
    required this.readyForNextRound,
    required this.score,
  });

  // Factory constructor to create a Player from a map
  factory Player.fromMap(Map<String, dynamic> data) {
    return Player(
      lastAnswerTime: data['lastAnswerTime'] as Timestamp?,
      name: data['name'] ?? 'Unknown',
      readyForNextRound: data['readyForNextRound'] ?? false,
      score: data['score'] ?? 0,
    );
  }

  // Method to convert a Player instance to a Map
  Map<String, dynamic> toJson() {
    return {
      'lastAnswerTime': lastAnswerTime,
      'name': name,
      'readyForNextRound': readyForNextRound,
      'score': score,
    };
  }
}

// -----------------------------
// Nested RoundInfo Class
// -----------------------------
class RoundInfo {
  final String? correctAnswer; // Assuming answer is a string, adjust if needed
  final String? questionText;
  final Timestamp? roundStartTime;
  final String? roundWinnerId;

  RoundInfo({
    this.correctAnswer,
    this.questionText,
    this.roundStartTime,
    this.roundWinnerId,
  });

  // Factory constructor to create a RoundInfo from a map
  factory RoundInfo.fromMap(Map<String, dynamic> data) {
    return RoundInfo(
      correctAnswer: data['correctAnswer'],
      questionText: data['questionText'],
      roundStartTime: data['roundStartTime'] as Timestamp?,
      roundWinnerId: data['roundWinnerId'],
    );
  }

  // Method to convert a RoundInfo instance to a Map
  Map<String, dynamic> toJson() {
    return {
      'correctAnswer': correctAnswer,
      'questionText': questionText,
      'roundStartTime': roundStartTime,
      'roundWinnerId': roundWinnerId,
    };
  }
}