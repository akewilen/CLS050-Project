import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

const Uuid uuid = Uuid();

// Creates the initial Firestore document object for a new game lobby.
Map<String, dynamic> setupLobby(String hostId, String hostName, int totalRounds) {
  return {
    "status": GameStatus.lobby.value,
    "totalRounds": totalRounds, // Dynamically set
    "currentRound": 1,
    "hostId": hostId, // Dynamically set
    "guestId": null,
    "players": {
      // Use bracket notation to dynamically set the player key using the hostId
      hostId: {
        "name": hostName, // Dynamically set
        "score": 0,
      }
    },
    "roundInfo": {
      "topCountry": null,
      "bottomCountry": null,
      "roundEndTime": null,
      "roundWinnerId": null
    },
    "metadata": {
      "createdAt": FieldValue.serverTimestamp()
    }
  };
}

enum GameStatus {
  // Each constant has an associated string 'value'
  lobby('lobby'),
  waitingRoundInfo('waitingRoundInfo'),
  finishedRound('finishedRound'),
  playingMap('playingMap'),
  playingCompare('playingCompare'),
  finished('finished'),
  canceled('canceled');

  // The field to hold the string
  final String value;

  // The constructor to assign the string
  const GameStatus(this.value);
}