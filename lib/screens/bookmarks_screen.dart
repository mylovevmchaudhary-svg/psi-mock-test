import 'package:flutter/material.dart';
import '../data/curated_question_bank.dart';
import '../models/quiz_model.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  Widget build(BuildContext context) {
    // Gather all bookmarked questions across all mock tests
    final List<Question> bookmarkedQuestions = [];
    for (final qList in CuratedQuestionBank.cachedQuestions.values) {
      for (final q in qList) {
        if (q.isBookmarked) {
          bookmarkedQuestions.add(q);
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D253F),
        title: const Text(
          'સાચવેલા પ્રશ્નો (Bookmarks)',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: bookmarkedQuestions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'હજુ સુધી કોઈ પ્રશ્ન સાચવેલ નથી.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'મોક ટેસ્ટ આપતી વખતે બુકમાર્ક આઇકોન પર ક્લિક કરીને પ્રશ્નો અહીં સાચવો.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarkedQuestions.length,
              itemBuilder: (context, index) {
                final q = bookmarkedQuestions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                q.subject,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.bookmark_remove, color: Colors.redAccent),
                              tooltip: 'દૂર કરો',
                              onPressed: () {
                                setState(() {
                                  q.isBookmarked = false;
                                });
                              },
                            ),
                          ],
                        ),
                        Text(
                          q.questionText,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D253F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'સાચો ઉત્તર: ${q.options[q.correctOptionIndex]}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'સમજૂતી: ${q.explanation}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
