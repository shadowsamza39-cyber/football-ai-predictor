import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'screens/detail_screen.dart';

void main() {
  runApp(const FootballAiPredictor());
}

class FootballAiPredictor extends StatelessWidget {
  const FootballAiPredictor({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Football AI Predictor',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor:
            const Color(0xFF08111F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FootballApiService api =
      FootballApiService();

  List<MatchPrediction> matches = [];

  bool loading = true;

  String selectedLeague = 'Toutes';

  final leagues = const [
    'Toutes',
    'Premier League',
    'Ligue 1',
    'Champions League',
    'La Liga',
  ];

  @override
  void initState() {
    super.initState();
    loadMatches();
  }

  Future<void> loadMatches() async {
    setState(() {
      loading = true;
    });

    final result = await api.fetchMatches();

    setState(() {
      matches = result;
      loading = false;
    });
  }

  List<MatchPrediction> get filteredMatches {
    if (selectedLeague == 'Toutes') {
      return matches;
    }

    return matches
        .where(
          (m) => m.league == selectedLeague,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Football AI Predictor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loadMatches,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadMatches,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildStatistics(),
              const SizedBox(height: 24),
              _buildLeagueFilter(),
              const SizedBox(height: 20),
              if (loading)
                const Center(
                  child:
                      CircularProgressIndicator(),
                )
              else if (filteredMatches.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Text(
                      'Aucun match disponible.',
                    ),
                  ),
                )
              else
                ...filteredMatches.map(
                  _buildMatchCard,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF123B2A),
            Color(0xFF0B1F2F),
          ],
        ),
      ),
      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.psychology,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            'Football AI Predictor',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Analyses statistiques basées sur xG + Loi de Poisson',
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            'Précision',
            '78%',
            Icons.analytics,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            'Modèle',
            'Poisson',
            Icons.auto_graph,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            'Matchs',
            '${matches.length}',
            Icons.sports_soccer,
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF101D2D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 25),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeagueFilter() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Compétitions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: leagues.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 8),
            itemBuilder: (_, index) {
              final league = leagues[index];
              final selected =
                  selectedLeague == league;

              return ChoiceChip(
                label: Text(league),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    selectedLeague = league;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMatchCard(
    MatchPrediction match,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                DetailScreen(match: match),
          ),
        );
      },
      child: Container(
        margin:
            const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF101D2D),
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white10,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  match.league,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Text(
                    match.homeTeam,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
                const Text(
                  'VS',
                  style: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    match.awayTeam,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _probability(
                    '1',
                    match.homeWin,
                  ),
                ),
                Expanded(
                  child: _probability(
                    'N',
                    match.draw,
                  ),
                ),
                Expanded(
                  child: _probability(
                    '2',
                    match.awayWin,
                  ),
                ),
              ],
            ),
            const Divider(height: 25),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
              children: [
                _miniMetric(
                  'Over 2.5',
                  match.over25,
                ),
                _miniMetric(
                  'BTTS',
                  match.bttsYes,
                ),
                Text(
                  'xG ${match.homeXg.toStringAsFixed(2)}'
                  ' - '
                  '${match.awayXg.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _probability(
    String label,
    double probability,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(probability * 100).toStringAsFixed(1)}%',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _miniMetric(
    String label,
    double value,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
        Text(
          '${(value * 100).toStringAsFixed(1)}%',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
