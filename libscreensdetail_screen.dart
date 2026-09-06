import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DetailScreen extends StatelessWidget {
  final MatchPrediction match;

  const DetailScreen({
    super.key,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse du match'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            _matchHeader(),
            const SizedBox(height: 24),

            const Text(
              'Probabilités 1N2',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _probabilityBar(
              'Victoire ${match.homeTeam}',
              match.homeWin,
            ),

            _probabilityBar(
              'Match nul',
              match.draw,
            ),

            _probabilityBar(
              'Victoire ${match.awayTeam}',
              match.awayWin,
            ),

            const SizedBox(height: 25),

            const Text(
              'Buts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _probabilityBar(
              'Over 2.5',
              match.over25,
            ),

            _probabilityBar(
              'Under 2.5',
              match.under25,
            ),

            const SizedBox(height: 25),

            const Text(
              'Les deux équipes marquent',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            _probabilityBar(
              'BTTS — Oui',
              match.bttsYes,
            ),

            _probabilityBar(
              'BTTS — Non',
              match.bttsNo,
            ),

            const SizedBox(height: 25),

            _xgCard(),

            const SizedBox(height: 25),

            const Text(
              'Top 5 des scores exacts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ...match.exactScores
                .map(_scoreCard),

            const SizedBox(height: 25),

            _poissonExplanation(),
          ],
        ),
      ),
    );
  }

  Widget _matchHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF123B2A),
            Color(0xFF102237),
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            match.league,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  match.homeTeam,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Text(
                'VS',
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
              Expanded(
                child: Text(
                  match.awayTeam,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'xG ${match.homeXg.toStringAsFixed(2)}'
            ' — '
            '${match.awayXg.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _probabilityBar(
    String title,
    double probability,
  ) {
    final percentage =
        probability.clamp(0.0, 1.0);

    return Container(
      margin:
          const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              Text(
                '${(percentage * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _xgCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF101D2D),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Expected Goals — xG',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround,
            children: [
              _xgValue(
                match.homeTeam,
                match.homeXg,
              ),
              _xgValue(
                match.awayTeam,
                match.awayXg,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _xgValue(
    String team,
    double xg,
  ) {
    return Column(
      children: [
        Text(
          team,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          xg.toStringAsFixed(2),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _scoreCard(
    ScoreProbability score,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF101D2D),
        borderRadius:
            BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            score.score,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${(score.probability * 100).toStringAsFixed(2)}%',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _poissonExplanation() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF101D2D),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Comment le modèle fonctionne',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 15),

          Text(
            '1. Le modèle estime le nombre moyen de buts '
            'attendus pour chaque équipe. Cette valeur est '
            'appelée λ (lambda) et correspond ici au xG.',

            style: TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),

          SizedBox(height: 12),

          Text(
            '2. La loi de Poisson calcule la probabilité '
            'qu’une équipe marque exactement k buts :',

            style: TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),

          SizedBox(height: 10),

          SelectableText(
            'P(k ; λ) = (λ^k × e^-λ) / k!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 12),

          Text(
            '3. La probabilité d’un score est obtenue en '
            'multipliant la probabilité des buts de l’équipe '
            'à domicile par celle de l’équipe extérieure.',

            style: TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),

          SizedBox(height: 12),

          Text(
            '4. Les probabilités 1N2, Over/Under 2.5 et BTTS '
            'sont ensuite obtenues en additionnant les '
            'probabilités des scores correspondants.',

            style: TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),

          SizedBox(height: 15),

          Text(
            '⚠️ Ces résultats sont statistiques et ne '
            'constituent pas une garantie de résultat.',
            style: TextStyle(
              color: Colors.orangeAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
