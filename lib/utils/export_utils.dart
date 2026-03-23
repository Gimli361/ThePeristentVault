import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../db/database_helper.dart';
import 'package:intl/intl.dart';

class ExportUtils {
  /// Exports all words to a CSV file and returns the file path
  static Future<String> exportToCSV() async {
    final words = await DatabaseHelper.instance.getAllWords();
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filePath = '${dir.path}/persistent_vault_export_$timestamp.csv';

    final rows = <List<String>>[
      ['Term', 'Meaning', 'Example Sentence', 'Synonyms', 'Phonetic', 'Tag', 'Date'],
      ...words.map((w) => [
            w.term,
            w.meaning,
            w.exampleSentence ?? '',
            w.synonyms ?? '',
            w.phonetic ?? '',
            w.categoryTag ?? '',
            DateFormat('yyyy-MM-dd').format(w.createdAt),
          ]),
    ];

    final csvData = const ListToCsvConverter().convert(rows);
    final file = File(filePath);
    await file.writeAsString(csvData);

    return filePath;
  }

  /// Exports all words to a styled PDF and triggers print/share
  static Future<void> exportToPDF() async {
    final words = await DatabaseHelper.instance.getAllWords();

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'The Persistent Vault',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Word Warehouse Export — ${DateFormat('MMMM d, yyyy').format(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: 8),
            pw.Divider(thickness: 0.5),
            pw.SizedBox(height: 12),
          ],
        ),
        build: (context) => words.map((word) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 16),
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      word.term,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (word.phonetic != null)
                      pw.Text(
                        word.phonetic!,
                        style: const pw.TextStyle(
                            fontSize: 12, color: PdfColors.grey600),
                      ),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Text(word.meaning, style: const pw.TextStyle(fontSize: 12)),
                if (word.exampleSentence != null &&
                    word.exampleSentence!.isNotEmpty)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 4),
                    child: pw.Text(
                      '"${word.exampleSentence}"',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontStyle: pw.FontStyle.italic,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ),
                if (word.categoryTag != null)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 6),
                    child: pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.amber50,
                        borderRadius: pw.BorderRadius.circular(10),
                      ),
                      child: pw.Text('#${word.categoryTag}',
                          style: const pw.TextStyle(fontSize: 10)),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
        footer: (context) => pw.Center(
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
          ),
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }
}
