import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/word_provider.dart';
import '../providers/theme_provider.dart';
import '../models/word.dart';
import '../services/dictionary_service.dart';
import '../theme/app_theme.dart';

class AddWordScreen extends StatefulWidget {
  const AddWordScreen({super.key});

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _termController = TextEditingController();
  final _meaningController = TextEditingController();
  final _sentenceController = TextEditingController();
  final _tagController = TextEditingController();

  bool _isEnriching = false;
  bool _isSaving = false;
  String? _phonetic;
  String? _audioUrl;
  String? _synonyms;
  bool _enriched = false;

  final DictionaryService _dictionaryService = DictionaryService();

  @override
  void dispose() {
    _termController.dispose();
    _meaningController.dispose();
    _sentenceController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _enrichWord() async {
    if (_termController.text.trim().isEmpty) return;

    setState(() => _isEnriching = true);

    final data =
        await _dictionaryService.fetchWordData(_termController.text.trim());

    setState(() {
      _isEnriching = false;
      if (data.isNotEmpty) {
        _phonetic = data['phonetic'];
        _audioUrl = data['audioUrl'];
        _synonyms = data['synonyms'];
        _enriched = true;
      }
    });

    if (data.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No data found for "${_termController.text}"'),
          backgroundColor: AppTheme.warningAmber,
        ),
      );
    }
  }

  Future<void> _saveWord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final word = Word(
      term: _termController.text.trim(),
      meaning: _meaningController.text.trim(),
      exampleSentence: _sentenceController.text.trim().isEmpty
          ? null
          : _sentenceController.text.trim(),
      categoryTag:
          _tagController.text.trim().isEmpty ? null : _tagController.text.trim(),
      phonetic: _phonetic,
      audioUrl: _audioUrl,
      synonyms: _synonyms,
    );

    await context.read<WordProvider>().addWord(word, autoEnrich: !_enriched);

    setState(() => _isSaving = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${word.term}" added to your vault!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Word',
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.grey[900],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Word input + enrich
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _termController,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.grey[900],
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Word',
                        hintText: 'e.g. persistent',
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Enter a word' : null,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: ElevatedButton.icon(
                      onPressed: _isEnriching ? null : _enrichWord,
                      icon: _isEnriching
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.auto_fix_high_rounded, size: 18),
                      label: Text(_isEnriching ? '...' : 'Enrich',
                          style: GoogleFonts.inter(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),

              // Enriched info
              if (_enriched) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.successGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 16, color: AppTheme.successGreen),
                          const SizedBox(width: 6),
                          Text(
                            'Auto-enriched from Dictionary API',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.successGreen,
                            ),
                          ),
                        ],
                      ),
                      if (_phonetic != null) ...[
                        const SizedBox(height: 6),
                        Text('Phonetic: $_phonetic',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600])),
                      ],
                      if (_audioUrl != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('🔊 Audio available',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600])),
                        ),
                      if (_synonyms != null && _synonyms!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Synonyms: $_synonyms',
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600])),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Meaning
              TextFormField(
                controller: _meaningController,
                style: GoogleFonts.inter(
                  color: isDark ? Colors.white : Colors.grey[900],
                ),
                decoration: const InputDecoration(
                  labelText: 'Meaning',
                  hintText: 'Your personal definition...',
                ),
                maxLines: 3,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter a meaning' : null,
              ),

              const SizedBox(height: 16),

              // Example sentence
              TextFormField(
                controller: _sentenceController,
                style: GoogleFonts.inter(
                  color: isDark ? Colors.white : Colors.grey[900],
                ),
                decoration: const InputDecoration(
                  labelText: 'My Sentence (optional)',
                  hintText: 'Use the word in a sentence...',
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              // Tag
              TextFormField(
                controller: _tagController,
                style: GoogleFonts.inter(
                  color: isDark ? Colors.white : Colors.grey[900],
                ),
                decoration: const InputDecoration(
                  labelText: 'Tag (optional)',
                  hintText: 'e.g. Business, Daily, Academic',
                  prefixText: '#',
                ),
              ),

              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveWord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black),
                        )
                      : Text(
                          'Save to Vault',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
