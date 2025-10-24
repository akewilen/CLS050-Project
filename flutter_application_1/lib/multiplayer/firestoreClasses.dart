import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/components/country.dart';

// -----------------------------
// Main Game Lobby Class
// -----------------------------
class GameLobby {
  final String id; // The Firestore document ID

  String status;
  final int totalRounds;
  int currentRound;
  String hostId;
  String? guestId;
  Map<String, Player> players;
  final Timestamp createdAt;
  RoundInfo roundInfo;
  final Map<String, dynamic> metadata;

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

  static GameLobby createEmptyLobby() {
    return GameLobby(
      id: "empty",
      currentRound: 0,
      hostId: "default_host_id",
      metadata: {},
      createdAt: Timestamp.now(),
      players: {},
      roundInfo: RoundInfo(),
      status: "LOBBY_EMPTY",
      totalRounds: 0,
      guestId: null,
    );
  }

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
  final Country? topCountry; // Assuming answer is a string, adjust if needed
  final Country? bottomCountry;
  final String? statistic;
  final Timestamp? roundEndTime;
  final String? roundWinnerId;

  RoundInfo({
    this.topCountry,
    this.bottomCountry,
    this.statistic,
    this.roundEndTime,
    this.roundWinnerId,
  });

  // Factory constructor to create a RoundInfo from a map
  factory RoundInfo.fromMap(Map<String, dynamic> data) {
    return RoundInfo(
      topCountry: data['topCountry'],
      bottomCountry: data['bottomCountry'],
      statistic: data['statistic'],
      roundEndTime: data['roundStartTime'] as Timestamp?,
      roundWinnerId: data['roundWinnerId'],
    );
  }

  // Method to convert a RoundInfo instance to a Map
  Map<String, dynamic> toJson() {
    return {
      // Use the null-aware spread operator (?.) and .toJson()
      // If topCountry is null, this property becomes null in the map.
      'topCountry': topCountry?.toJson(),
      'bottomCountry': bottomCountry?.toJson(),
      'statistic': statistic,
      'roundEndTime': roundEndTime,
      'roundWinnerId': roundWinnerId,
    };
  }
}