import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/journal_provider.dart';
import '../providers/word_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/streak_provider.dart';
import '../models/journal_entry.dart';
import '../theme/app_theme.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  bool _showCalendar = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final journalProvider = context.watch<JournalProvider>();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'English Journal',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.grey[900],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () =>
                          setState(() => _showCalendar = !_showCalendar),
                      icon: Icon(
                        _showCalendar
                            ? Icons.edit_note_rounded
                            : Icons.calendar_month_rounded,
                        color: AppTheme.accent,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _openNewEntry(context),
                      icon: const Icon(Icons.add_circle_rounded,
                          color: AppTheme.accent),
                      iconSize: 32,
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: _showCalendar
                ? _buildCalendarView(isDark, journalProvider)
                : _buildEntryListView(isDark, journalProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView(bool isDark, JournalProvider provider) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          onDaySelected: (selectedDay, focusedDay) async {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            final entry = await provider.getEntryByDate(selectedDay);
            if (entry != null && mounted) {
              _openEntryEditor(context, entry);
            } else if (mounted) {
              _openNewEntry(context, date: selectedDay);
            }
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: AppTheme.accent,
              shape: BoxShape.circle,
            ),
            defaultTextStyle: GoogleFonts.inter(
              color: isDark ? Colors.white : Colors.grey[900],
            ),
            weekendTextStyle: GoogleFonts.inter(
              color: isDark ? Colors.grey[500] : Colors.grey[600],
            ),
            outsideTextStyle: GoogleFonts.inter(
              color: isDark ? Colors.grey[700] : Colors.grey[400],
            ),
            markerDecoration: BoxDecoration(
              color: AppTheme.successGreen,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? const Color(0xFF121212) : Colors.white,
                width: 1,
              ),
            ),
            markersMaxCount: 1,
            markerSize: 6,
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.grey[900],
            ),
            leftChevronIcon:
                Icon(Icons.chevron_left, color: isDark ? Colors.white : Colors.grey[700]),
            rightChevronIcon:
                Icon(Icons.chevron_right, color: isDark ? Colors.white : Colors.grey[700]),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: GoogleFonts.inter(
              fontSize: 13,
              color: isDark ? Colors.grey[500] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            weekendStyle: GoogleFonts.inter(
              fontSize: 13,
              color: isDark ? Colors.grey[600] : Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          eventLoader: (day) {
            final dateOnly = DateTime(day.year, day.month, day.day);
            return provider.journalDates.contains(dateOnly) ? ['entry'] : [];
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, date, events) {
              if (events.isNotEmpty) {
                return Positioned(
                  bottom: 1,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.successGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }
              return null;
            },
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Center(
            child: Text(
              'Tap a date to view or write an entry',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? Colors.grey[600] : Colors.grey[500],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEntryListView(bool isDark, JournalProvider provider) {
    if (provider.entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_stories_rounded,
                size: 64, color: isDark ? Colors.grey[700] : Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No journal entries yet',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Write about your day in English!',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? Colors.grey[600] : Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: provider.entries.length,
      itemBuilder: (context, index) {
        final entry = provider.entries[index];
        return _JournalCard(
          entry: entry,
          isDark: isDark,
          onTap: () => _openEntryEditor(context, entry),
          onDelete: () => _deleteEntry(entry),
        );
      },
    );
  }

  void _openNewEntry(BuildContext context, {DateTime? date}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _JournalEditorScreen(date: date),
      ),
    );
  }

  void _openEntryEditor(BuildContext context, JournalEntry entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _JournalEditorScreen(existingEntry: entry),
      ),
    );
  }

  void _deleteEntry(JournalEntry entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<JournalProvider>().deleteEntry(entry.id!);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _JournalCard extends StatelessWidget {
  final JournalEntry entry;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _JournalCard({
    required this.entry,
    required this.isDark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, MMM d, yyyy').format(entry.createdAt);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252525) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateStr,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accent,
                  ),
                ),
                Row(
                  children: [
                    if (entry.moodEmoji != null)
                      Text(entry.moodEmoji!, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: onDelete,
                      child: Icon(Icons.delete_outline_rounded,
                          size: 18,
                          color: isDark ? Colors.grey[600] : Colors.grey[400]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              entry.entryText,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.5,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Journal Editor ──

class _JournalEditorScreen extends StatefulWidget {
  final JournalEntry? existingEntry;
  final DateTime? date;

  const _JournalEditorScreen({this.existingEntry, this.date});

  @override
  State<_JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends State<_JournalEditorScreen> {
  final _textController = TextEditingController();
  String? _selectedMood;
  List<String> _warehouseTerms = [];
  bool _isSaving = false;

  static const List<String> _moods = [
    '😊',
    '😌',
    '🤔',
    '😤',
    '😢',
    '🥳',
    '😴',
    '💪',
    '🔥',
    '✨'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      _textController.text = widget.existingEntry!.entryText;
      _selectedMood = widget.existingEntry!.moodEmoji;
    }
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    final terms = await context.read<WordProvider>().getAllTerms();
    setState(() => _warehouseTerms = terms);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write something first!')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final entry = JournalEntry(
      id: widget.existingEntry?.id,
      entryText: _textController.text.trim(),
      moodEmoji: _selectedMood,
      createdAt: widget.existingEntry?.createdAt ?? widget.date ?? DateTime.now(),
    );

    await context.read<JournalProvider>().saveEntry(entry);

    // Record streak activity
    if (mounted) {
      context.read<StreakProvider>().recordActivity();
    }

    HapticFeedback.mediumImpact();

    setState(() => _isSaving = false);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  List<TextSpan> _buildHighlightedText(String text, bool isDark) {
    if (_warehouseTerms.isEmpty) {
      return [
        TextSpan(
          text: text,
          style: GoogleFonts.inter(
            fontSize: 16,
            height: 1.7,
            color: isDark ? Colors.white : Colors.grey[900],
          ),
        ),
      ];
    }

    final spans = <TextSpan>[];
    final lowerText = text.toLowerCase();
    int lastIndex = 0;

    // Sort terms by length desc so longer matches are found first
    final sortedTerms = List<String>.from(_warehouseTerms)
      ..sort((a, b) => b.length.compareTo(a.length));

    final matches = <_Match>[];
    for (final term in sortedTerms) {
      final lowerTerm = term.toLowerCase();
      int startPos = 0;
      while (true) {
        final idx = lowerText.indexOf(lowerTerm, startPos);
        if (idx == -1) break;

        // Check word boundaries
        final before = idx > 0 ? lowerText[idx - 1] : ' ';
        final after = idx + lowerTerm.length < lowerText.length
            ? lowerText[idx + lowerTerm.length]
            : ' ';
        if (!RegExp(r'[a-zA-Z]').hasMatch(before) &&
            !RegExp(r'[a-zA-Z]').hasMatch(after)) {
          matches.add(_Match(idx, idx + term.length));
        }
        startPos = idx + 1;
      }
    }

    // Sort by start position
    matches.sort((a, b) => a.start.compareTo(b.start));

    // Remove overlapping
    final filtered = <_Match>[];
    for (final m in matches) {
      if (filtered.isEmpty || m.start >= filtered.last.end) {
        filtered.add(m);
      }
    }

    for (final m in filtered) {
      if (m.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, m.start),
          style: GoogleFonts.inter(
            fontSize: 16,
            height: 1.7,
            color: isDark ? Colors.white : Colors.grey[900],
          ),
        ));
      }
      spans.add(TextSpan(
        text: text.substring(m.start, m.end),
        style: GoogleFonts.inter(
          fontSize: 16,
          height: 1.7,
          fontWeight: FontWeight.w700,
          color: AppTheme.accent,
          decoration: TextDecoration.underline,
          decorationColor: AppTheme.accent.withValues(alpha: 0.4),
        ),
      ));
      lastIndex = m.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: GoogleFonts.inter(
          fontSize: 16,
          height: 1.7,
          color: isDark ? Colors.white : Colors.grey[900],
        ),
      ));
    }

    return spans.isEmpty
        ? [
            TextSpan(
              text: text,
              style: GoogleFonts.inter(
                fontSize: 16,
                height: 1.7,
                color: isDark ? Colors.white : Colors.grey[900],
              ),
            ),
          ]
        : spans;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final charCount = _textController.text.length;
    final dateStr = DateFormat('EEEE, MMM d').format(
        widget.existingEntry?.createdAt ?? widget.date ?? DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          dateStr,
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.grey[900],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accent,
                    ),
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Mood picker
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _moods.length,
                itemBuilder: (context, index) {
                  final mood = _moods[index];
                  final isSelected = _selectedMood == mood;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedMood = isSelected ? null : mood),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.accent.withValues(alpha: 0.2)
                            : isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: AppTheme.accent, width: 1.5)
                            : null,
                      ),
                      child: Center(
                        child: Text(mood,
                            style: TextStyle(
                                fontSize: isSelected ? 22 : 18)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Preview of highlighted text
          if (_textController.text.isNotEmpty && _warehouseTerms.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: RichText(
                text: TextSpan(
                  children: _buildHighlightedText(_textController.text, isDark),
                ),
              ),
            ),

          // Text editor
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 1.7,
                  color: isDark ? Colors.white : Colors.grey[900],
                ),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Write about your day in English...\n\nTry to use 3-5 sentences.',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 16,
                    height: 1.7,
                    color: isDark ? Colors.grey[600] : Colors.grey[500],
                  ),
                  border: InputBorder.none,
                  filled: false,
                ),
              ),
            ),
          ),

          // Character count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$charCount characters',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
                if (_warehouseTerms.isNotEmpty)
                  Text(
                    'Words from vault will be highlighted',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.accent.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Match {
  final int start;
  final int end;
  _Match(this.start, this.end);
}
