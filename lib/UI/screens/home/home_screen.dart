import 'package:flutter/material.dart';
import 'package:flutterapp/core/constants/app_colors.dart';
import 'package:flutterapp/UI/screens/editor/deck_form_screen.dart';
import 'package:flutterapp/UI/screens/study/quiz_screen.dart';
import 'package:flutterapp/UI/screens/study/flashcard_screen.dart';
import 'package:flutterapp/UI/screens/study/matching_screen.dart';
import 'package:flutterapp/UI/screens/home/settings_screen.dart'; 
import 'package:flutterapp/UI/widgets/deck_card.dart'; 
import 'package:flutterapp/UI/widgets/main_bottom_nav.dart';
import 'package:flutterapp/UI/widgets/user_level.dart';
import 'package:flutterapp/data/datascource/local_database.dart';
import 'package:flutterapp/data/repositories/deck_repository_impl.dart';
import 'package:flutterapp/data/repositories/user_repository_impl.dart';
import 'package:flutterapp/domain/models/deck.dart';
import 'package:flutterapp/domain/models/user_stats.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DeckRepositoryImpl _deckRepo = DeckRepositoryImpl(LocalDataSource());
  final UserRepositoryImpl _userRepo  = UserRepositoryImpl(LocalDataSource());
  
  List<Deck> _allDecks = [];         
  List<Deck> _filteredDecks = [];    
  bool _isLoading = true;
  UserStats? _stats;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDecks();
    _loadUserStats();
  }

  Future<void> _loadDecks() async {
    setState(() => _isLoading = true);
    final data = await _deckRepo.getAllDecks();
    setState(() {
      _allDecks = data;
      _filteredDecks = data; 
      _isLoading = false;
    });
  }

  Future<void> _loadUserStats() async {
    final UserStats stats = await _userRepo.getUserStats("current_user");
    setState(() {
      _stats = stats;
    });
  }

  void _filterDecks(String query) {
    setState(() {
      _filteredDecks = _allDecks
          .where((deck) => deck.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _goToCreate() async {
    final refresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditDeckScreen()),
    );
    if (refresh == true) _loadDecks();
  }

  void _goToEdit(Deck deck) async {
    final bool? refreshNeeded = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditDeckScreen(deckToEdit: deck)),
    );
    if (refreshNeeded == true) _loadDecks();
  }

  void _handleDelete(String deckId) async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.textPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Delete Deck?", style: TextStyle(color: AppColors.textDark)),
            content: const Text("This action cannot be undone.", style: TextStyle(color: AppColors.textSecondary)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: AppColors.error))),
            ],
          ),
        ) ?? false;

    if (confirm) {
      await _deckRepo.deleteDeck(deckId);
      _loadDecks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Column(
        children: [
          _buildHeader(), // Now contains Title, Level, and Search
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryNavy))
                : RefreshIndicator(
                    onRefresh: _loadDecks,
                    color: AppColors.primaryNavy,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          const Text("My Study Decks", 
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          const SizedBox(height: 15),
                          _buildDeckGrid(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: 0,
        onTabSelected: (index) {
          if (index == 1) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToCreate,
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(Icons.add, color: AppColors.textPrimary, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // --- UPDATED HEADER (TITLE + LEVEL + SEARCH) ---
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 5 , 25, 5),
      decoration: const BoxDecoration(
        color: AppColors.scaffoldBg, // Keep it seamless with background
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Side: Title and Subtitle
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Study Flow", 
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primaryNavy)),
                    Text("Ready to learn?", 
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              
              // Right Side: Compact Level Box
              SizedBox(
                width: 135, 
                child: UserLevel(
                  level: _stats?.level ?? 1, 
                  currentExp: _stats?.totalEXP ?? 0, 
                  totalExpNeeded: _stats?.nextLevel?? 1000, 
                  streak: _stats?.dailyStreak ?? 0
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSearchBox(), // Search is now inside the header area
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      height: 50, // Fixed height for a cleaner look
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), 
            blurRadius: 15, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterDecks,
        decoration: const InputDecoration(
          hintText: "Search decks...",
          border: InputBorder.none,
          icon: Icon(Icons.search, color: AppColors.primaryNavy, size: 22),
        ),
      ),
    );
  }

  Widget _buildDeckGrid() {
    if (_filteredDecks.isEmpty) return const Center(child: Text("No decks found."));
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        crossAxisSpacing: 15, 
        mainAxisSpacing: 15, 
        childAspectRatio: 0.85
      ),
      itemCount: _filteredDecks.length,
      itemBuilder: (context, index) {
        final deck = _filteredDecks[index];
        return DeckCard(
          deck: deck,
          onTap: () => _showOptionsOverlay(deck),
          onActionSelected: (value) {
            if (value == 'edit') _goToEdit(deck);
            if (value == 'delete') _handleDelete(deck.id);
          },
        );
      },
    );
  }

  void _showOptionsOverlay(Deck deck) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.textPrimary,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(30, 15, 30, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.scaffoldBg, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            Text(deck.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _modeIcon(Icons.help_outline, "Quiz", () async { 
                  Navigator.pop(context); 
                  final earnedExp = await Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(deck: deck))); 
                  if (earnedExp != null && earnedExp is int){
                  _loadUserStats();
                  }
                  }),
                _modeIcon(Icons.extension_outlined, "Match", () async { 
                  Navigator.pop(context); 
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => MatchingScreen(deck: deck))); 
                  if (result != null) {
                  _loadUserStats();
                  }
                  }),
                _modeIcon(Icons.style_outlined, "Study", () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => FlashcardScreen(deck: deck))); }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeIcon(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: 70, height: 70, 
            decoration: BoxDecoration(color: AppColors.navyLight, borderRadius: BorderRadius.circular(20)), 
            child: Icon(icon, color: AppColors.primaryNavy, size: 30)
          ),
        ),
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}