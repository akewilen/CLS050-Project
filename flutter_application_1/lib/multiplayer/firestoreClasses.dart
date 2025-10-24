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
      'id': id,
    };
  }

factory GameLobby.fromJson(Map<String, dynamic> data) {
    // Parse the nested 'players' map (same logic as in fromFirestore)
    Map<String, Player> parsedPlayers = {};
    if (data['players'] != null) {
      (data['players'] as Map<String, dynamic>).forEach((playerId, playerData) {
        parsedPlayers[playerId] =
            Player.fromMap(playerData as Map<String, dynamic>);
      });
    }

    return GameLobby(
      id: data['id'] as String,
      currentRound: data['currentRound'] as int,
      guestId: data['guestId'] as String?,
      hostId: data['hostId'] as String,
      metadata: data['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: data['createdAt'] as Timestamp,
      players: parsedPlayers,
      roundInfo:
          RoundInfo.fromMap(data['roundInfo'] as Map<String, dynamic>),
      status: data['status'] as String,
      totalRounds: data['totalRounds'] as int,
    );
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
  final Country? topCountry;
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

  factory RoundInfo.fromMap(Map<String, dynamic> data) {
    return RoundInfo(
      topCountry: data['topCountry'] == null
          ? null
          : Country.fromJson(data['topCountry'] as Map<String, dynamic>),

      bottomCountry: data['bottomCountry'] == null
          ? null
          : Country.fromJson(data['bottomCountry'] as Map<String, dynamic>),

      statistic: data['statistic'] as String?,
      roundEndTime: data['roundEndTime'] as Timestamp?, 
      roundWinnerId: data['roundWinnerId'] as String?,
    );
  }

  // Method to convert a RoundInfo instance to a Map
  Map<String, dynamic> toJson() {
    return {
      'topCountry': topCountry?.toJson(),
      'bottomCountry': bottomCountry?.toJson(),
      'statistic': statistic,
      'roundEndTime': roundEndTime,
      'roundWinnerId': roundWinnerId,
    };
  }
}