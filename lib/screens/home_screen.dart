import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../providers/word_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/streak_provider.dart';
import '../models/word.dart';
import '../theme/app_theme.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  final VoidCallback onAddWordPressed;

  const HomeScreen({super.key, required this.onAddWordPressed});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late ConfettiController _confettiController;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _flipController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_flipController.isAnimating) return;
    if (_showBack) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _showBack = !_showBack);
  }

  void _nextWord() {
    final provider = context.read<WordProvider>();
    provider.refreshRandomWord();
    if (_showBack) {
      _flipController.reverse();
      setState(() => _showBack = false);
    }
  }

  void _onKnewIt() {
    final wordProvider = context.read<WordProvider>();
    final word = wordProvider.randomWord;
    if (word != null && word.id != null) {
      wordProvider.promoteWord(word.id!);
    }
    _nextWord();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final wordProvider = context.watch<WordProvider>();
    final streakProvider = context.watch<StreakProvider>();
    final isDark = themeProvider.isDark;

    // Trigger confetti when milestone reached
    if (streakProvider.showCelebration) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _confettiController.play();
        streakProvider.dismissCelebration();
      });
    }

    return Stack(
      children: [
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header with Streak ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'The Persistent',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.grey[900],
                          ),
                        ),
                        Text(
                          'Vault',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accent,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // ── Streak Flame ──
                        _StreakFlame(
                          streakCount: streakProvider.streakCount,
                          isActive: streakProvider.isActive,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        // Theme toggle
                        GestureDetector(
                          onTap: themeProvider.toggleTheme,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              isDark
                                  ? Icons.wb_sunny_rounded
                                  : Icons.nightlight_round,
                              color: AppTheme.accent,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                Text(
                  '"Stay persistent, grow relentless."',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Stats Row ──
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.library_books_rounded,
                      label: '${wordProvider.wordCount}',
                      subtitle: 'Words',
                      isDark: isDark,
                    ),
                    const SizedBox(width: 12),
                    _StatChip(
                      icon: Icons.local_fire_department_rounded,
                      label: '${streakProvider.streakCount}',
                      subtitle: 'Day Streak',
                      isDark: isDark,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Mastery Progress ──
                if (wordProvider.wordCount > 0) _MasteryBar(
                  masteryStats: wordProvider.masteryStats,
                  totalWords: wordProvider.wordCount,
                  isDark: isDark,
                ),

                const SizedBox(height: 28),

                // ── Flash-Flip Card ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Word of the Day',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.grey[900],
                      ),
                    ),
                    if (wordProvider.randomWord != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _masteryColor(
                                  wordProvider.randomWord!.masteryLevel)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${wordProvider.randomWord!.masteryLevel.emoji} ${wordProvider.randomWord!.masteryLevel.label}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _masteryColor(
                                wordProvider.randomWord!.masteryLevel),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                if (wordProvider.randomWord != null)
                  _buildFlipCard(wordProvider.randomWord!, isDark)
                else
                  _buildEmptyFlipCard(isDark),

                if (wordProvider.randomWord != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: _nextWord,
                        icon:
                            const Icon(Icons.close_rounded, size: 18),
                        label: Text("Didn't know",
                            style:
                                GoogleFonts.inter(fontWeight: FontWeight.w500)),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.errorRed,
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        onPressed: _onKnewIt,
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text('Knew it!',
                            style:
                                GoogleFonts.inter(fontWeight: FontWeight.w500)),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.successGreen,
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: TextButton.icon(
                      onPressed: _nextWord,
                      icon: const Icon(Icons.shuffle_rounded, size: 18),
                      label: Text('Another word',
                          style:
                              GoogleFonts.inter(fontWeight: FontWeight.w500)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.accent,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // ── Quick Actions ──
                Text(
                  'Quick Actions',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.grey[900],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.add_circle_outline_rounded,
                        label: 'Add Word',
                        color: AppTheme.accent,
                        isDark: isDark,
                        onTap: widget.onAddWordPressed,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.auto_stories_rounded,
                        label: 'Journal',
                        color: AppTheme.successGreen,
                        isDark: isDark,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),

        // ── Confetti Overlay ──
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            numberOfParticles: 30,
            maxBlastForce: 20,
            minBlastForce: 8,
            gravity: 0.2,
            colors: const [
              AppTheme.accent,
              AppTheme.accentLight,
              AppTheme.successGreen,
              AppTheme.warningAmber,
            ],
          ),
        ),
      ],
    );
  }

  Color _masteryColor(MasteryLevel level) {
    switch (level) {
      case MasteryLevel.seed:
        return AppTheme.warningAmber;
      case MasteryLevel.sprout:
        return AppTheme.accent;
      case MasteryLevel.oak:
        return AppTheme.successGreen;
    }
  }

  Widget _buildFlipCard(Word word, bool isDark) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * pi;
          final isBack = _flipAnimation.value >= 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildCardBack(word, isDark),
                  )
                : _buildCardFront(word, isDark),
          );
        },
      ),
    );
  }

  Widget _buildCardFront(Word word, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF2A2218), const Color(0xFF1A1510)]
              : [const Color(0xFFFFF8F0), const Color(0xFFF5E6D3)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accent.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withValues(alpha: isDark ? 0.15 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome,
            color: AppTheme.accent.withValues(alpha: 0.6),
            size: 28,
          ),
          const SizedBox(height: 16),
          Text(
            word.term,
            style: GoogleFonts.playfairDisplay(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.grey[900],
            ),
          ),
          if (word.phonetic != null) ...[
            const SizedBox(height: 8),
            Text(
              word.phonetic!,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppTheme.accent,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Tap to reveal meaning',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(Word word, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1A2218), const Color(0xFF101A10)]
              : [const Color(0xFFF0FFF0), const Color(0xFFD3F5D3)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.successGreen.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.successGreen.withValues(alpha: isDark ? 0.15 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            word.meaning,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.grey[900],
            ),
          ),
          if (word.exampleSentence != null &&
              word.exampleSentence!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '"${word.exampleSentence}"',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
          ],
          if (word.synonymList.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: word.synonymList.take(4).map((syn) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    syn,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.accent,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyFlipCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.bookmark_add_outlined,
            size: 48,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Your vault is empty',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first word to get started!',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? Colors.grey[600] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Streak Flame Widget ──

class _StreakFlame extends StatelessWidget {
  final int streakCount;
  final bool isActive;
  final bool isDark;

  const _StreakFlame({
    required this.streakCount,
    required this.isActive,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                colors: [
                  Colors.orange.withValues(alpha: 0.2),
                  Colors.deepOrange.withValues(alpha: 0.15),
                ],
              )
            : null,
        color: isActive
            ? null
            : (isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? Colors.orange.withValues(alpha: 0.4)
              : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: 20,
            color: isActive ? Colors.orange : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            '$streakCount',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isActive
                  ? Colors.orange
                  : (isDark ? Colors.grey[500] : Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mastery Progress Bar ──

class _MasteryBar extends StatelessWidget {
  final Map<MasteryLevel, int> masteryStats;
  final int totalWords;
  final bool isDark;

  const _MasteryBar({
    required this.masteryStats,
    required this.totalWords,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final seed = masteryStats[MasteryLevel.seed] ?? 0;
    final sprout = masteryStats[MasteryLevel.sprout] ?? 0;
    final oak = masteryStats[MasteryLevel.oak] ?? 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mastery Progress',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              Text(
                '$oak/$totalWords mastered',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  if (oak > 0)
                    Flexible(
                      flex: oak,
                      child: Container(color: AppTheme.successGreen),
                    ),
                  if (sprout > 0)
                    Flexible(
                      flex: sprout,
                      child: Container(color: AppTheme.accent),
                    ),
                  if (seed > 0)
                    Flexible(
                      flex: seed,
                      child: Container(
                          color: AppTheme.warningAmber.withValues(alpha: 0.5)),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MasteryLabel(
                emoji: '🌱',
                label: 'Seed',
                count: seed,
                color: AppTheme.warningAmber,
              ),
              _MasteryLabel(
                emoji: '🌿',
                label: 'Sprout',
                count: sprout,
                color: AppTheme.accent,
              ),
              _MasteryLabel(
                emoji: '🌳',
                label: 'Oak',
                count: oak,
                color: AppTheme.successGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MasteryLabel extends StatelessWidget {
  final String emoji;
  final String label;
  final int count;
  final Color color;

  const _MasteryLabel({
    required this.emoji,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isDark;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.accent, size: 22),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.grey[900],
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isDark ? 0.1 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.grey[900],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
