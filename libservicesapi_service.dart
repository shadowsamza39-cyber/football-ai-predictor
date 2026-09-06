import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class MatchPrediction {
  final String id;
  final String league;
  final String homeTeam;
  final String awayTeam;
  final DateTime date;

  final double homeXg;
  final double awayXg;

  final double homeWin;
  final double draw;
  final double awayWin;

  final double over25;
  final double under25;

  final double bttsYes;
  final double bttsNo;

  final List<ScoreProbability> exactScores;

  MatchPrediction({
    required this.id,
    required this.league,
    required this.homeTeam,
    required this.awayTeam,
    required this.date,
    required this.homeXg,
    required this.awayXg,
    required this.homeWin,
    required this.draw,
    required this.awayWin,
    required this.over25,
    required this.under25,
    required this.bttsYes,
    required this.bttsNo,
    required this.exactScores,
  });
}

class ScoreProbability {
  final int homeGoals;
  final int awayGoals;
  final double probability;

  ScoreProbability({
    required this.homeGoals,
    required this.awayGoals,
    required this.probability,
  });

  String get score => '$homeGoals - $awayGoals';
}

class FootballApiService {
  /*
   * ============================================================
   * POISSON MODEL
   * ============================================================
   *
   * P(k ; lambda) =
   *       lambda^k * e^(-lambda)
   *       ---------------------
   *               k!
   *
   * lambda = nombre moyen de buts attendu (xG).
   *
   * Nous construisons ensuite une matrice :
   *
   * P(Home = i AND Away = j)
   * = P(Home = i) * P(Away = j)
   *
   * sous l'hypothèse d'indépendance.
   */

  /// Probabilité de marquer exactement [goals] buts
  /// avec une moyenne attendue [lambda].
  static double poissonProbability(
    int goals,
    double lambda,
  ) {
    if (lambda < 0) return 0;

    if (goals == 0) {
      return exp(-lambda);
    }

    double factorial = 1;

    for (int i = 1; i <= goals; i++) {
      factorial *= i;
    }

    return pow(lambda, goals) * exp(-lambda) / factorial;
  }

  /// Calcule toutes les probabilités du match.
  static MatchPrediction calculatePrediction({
    required String id,
    required String league,
    required String homeTeam,
    required String awayTeam,
    required DateTime date,
    required double homeXg,
    required double awayXg,
  }) {
    const int maxGoals = 10;

    final homeProbabilities = <int, double>{};
    final awayProbabilities = <int, double>{};

    for (int i = 0; i <= maxGoals; i++) {
      homeProbabilities[i] =
          poissonProbability(i, homeXg);

      awayProbabilities[i] =
          poissonProbability(i, awayXg);
    }

    double homeWin = 0;
    double draw = 0;
    double awayWin = 0;

    double over25 = 0;
    double under25 = 0;

    double bttsYes = 0;
    double bttsNo = 0;

    final scores = <ScoreProbability>[];

    for (int homeGoals = 0;
        homeGoals <= maxGoals;
        homeGoals++) {
      for (int awayGoals = 0;
          awayGoals <= maxGoals;
          awayGoals++) {

        final probability =
            homeProbabilities[homeGoals]! *
                awayProbabilities[awayGoals]!;

        scores.add(
          ScoreProbability(
            homeGoals: homeGoals,
            awayGoals: awayGoals,
            probability: probability,
          ),
        );

        // 1N2
        if (homeGoals > awayGoals) {
          homeWin += probability;
        } else if (homeGoals == awayGoals) {
          draw += probability;
        } else {
          awayWin += probability;
        }

        // Over / Under 2.5
        if (homeGoals + awayGoals >= 3) {
          over25 += probability;
        } else {
          under25 += probability;
        }

        // BTTS
        if (homeGoals >= 1 && awayGoals >= 1) {
          bttsYes += probability;
        } else {
          bttsNo += probability;
        }
      }
    }

    scores.sort(
      (a, b) =>
          b.probability.compareTo(a.probability),
    );

    return MatchPrediction(
      id: id,
      league: league,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      date: date,
      homeXg: homeXg,
      awayXg: awayXg,
      homeWin: homeWin,
      draw: draw,
      awayWin: awayWin,
      over25: over25,
      under25: under25,
      bttsYes: bttsYes,
      bttsNo: bttsNo,
      exactScores: scores.take(5).toList(),
    );
  }

  /*
   * ============================================================
   * CALCUL DES xG
   * ============================================================
   *
   * Exemple simplifié :
   *
   * Home xG =
   * moyenne attaque domicile
   * × faiblesse défense extérieure
   *
   * Dans une vraie application, ces valeurs devraient provenir
   * d'une base statistique historique.
   */

  static double calculateExpectedGoals({
    required double attackStrength,
    required double opponentDefenseWeakness,
    required double leagueAverage,
    double homeAdvantage = 1.0,
  }) {
    if (leagueAverage <= 0) return 0.1;

    final result =
        leagueAverage *
        attackStrength *
        opponentDefenseWeakness *
        homeAdvantage;

    return result.clamp(0.05, 5.0);
  }

  /*
   * ============================================================
   * API HTTP
   * ============================================================
   *
   * Remplacez cette URL par votre fournisseur de données.
   *
   * Le backend devrait retourner quelque chose comme :
   *
   * {
   *   "matches": [
   *      {
   *        "id": "1",
   *        "league": "Premier League",
   *        "homeTeam": "Arsenal",
   *        "awayTeam": "Chelsea",
   *        "date": "2026-09-06T15:00:00Z",
   *        "homeXg": 1.85,
   *        "awayXg": 1.10
   *      }
   *   ]
   * }
   */

  static const String apiUrl =
      'https://YOUR-API-ENDPOINT.com/matches';

  Future<List<MatchPrediction>> fetchMatches() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Erreur API : ${response.statusCode}',
        );
      }

      final json = jsonDecode(response.body);

      final List<dynamic> matches =
          json['matches'] ?? [];

      return matches.map((match) {
        return calculatePrediction(
          id: match['id'].toString(),
          league: match['league'] ?? 'Unknown',
          homeTeam: match['homeTeam'] ?? '',
          awayTeam: match['awayTeam'] ?? '',
          date: DateTime.parse(match['date']),
          homeXg:
              (match['homeXg'] as num).toDouble(),
          awayXg:
              (match['awayXg'] as num).toDouble(),
        );
      }).toList();
    } catch (e) {
      /*
       * Pour permettre de tester l'application immédiatement,
       * nous retournons ici des données de démonstration.
       *
       * En production, vous pouvez supprimer ce fallback.
       */

      return demoMatches();
    }
  }

  static List<MatchPrediction> demoMatches() {
    final now = DateTime.now();

    return [
      calculatePrediction(
        id: '1',
        league: 'Premier League',
        homeTeam: 'Arsenal',
        awayTeam: 'Chelsea',
        date: now,
        homeXg: 1.95,
        awayXg: 1.15,
      ),
      calculatePrediction(
        id: '2',
        league: 'La Liga',
        homeTeam: 'Real Madrid',
        awayTeam: 'Valencia',
        date: now,
        homeXg: 2.10,
        awayXg: 0.85,
      ),
      calculatePrediction(
        id: '3',
        league: 'Ligue 1',
        homeTeam: 'PSG',
        awayTeam: 'Lyon',
        date: now,
        homeXg: 2.25,
        awayXg: 1.00,
      ),
      calculatePrediction(
        id: '4',
        league: 'Champions League',
        homeTeam: 'Manchester City',
        awayTeam: 'Inter',
        date: now,
        homeXg: 1.75,
        awayXg: 1.20,
      ),
    ];
  }
}
