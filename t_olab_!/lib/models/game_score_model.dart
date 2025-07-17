class GameScoreModel {
  final String id;
  final String userId;
  final String gameType; // e.g., "wordle", "puzzle"
  final int score;
  final DateTime playedAt;

  GameScoreModel({
    required this.id,
    required this.userId,
    required this.gameType,
    required this.score,
    required this.playedAt,
  });

  factory GameScoreModel.fromJson(Map<String, dynamic> json) => GameScoreModel(
    id: json['id'],
    userId: json['user_id'],
    gameType: json['game_type'],
    score: json['score'],
    playedAt: DateTime.parse(json['played_at']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'game_type': gameType,
    'score': score,
    'played_at': playedAt.toIso8601String(),
  };
}
