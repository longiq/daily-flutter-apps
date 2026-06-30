import 'package:flutter/material.dart';
import 'models.dart';

/// Màn hình học: lật thẻ, vuốt qua thẻ tiếp theo.
class StudyScreen extends StatefulWidget {
  final Deck deck;
  const StudyScreen({super.key, required this.deck});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  int _index = 0;
  bool _showAnswer = false;

  void _next() {
    setState(() {
      _showAnswer = false;
      _index = (_index + 1) % widget.deck.cards.length;
    });
  }

  void _prev() {
    setState(() {
      _showAnswer = false;
      _index =
          (_index - 1 + widget.deck.cards.length) % widget.deck.cards.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.deck.cards;
    final card = cards[_index];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deck.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_index + 1) / cards.length,
              minHeight: 6,
            ),
            const SizedBox(height: 8),
            Text('Thẻ ${_index + 1}/${cards.length}',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _showAnswer = !_showAnswer),
                onHorizontalDragEnd: (d) {
                  if ((d.primaryVelocity ?? 0) < 0) {
                    _next();
                  } else if ((d.primaryVelocity ?? 0) > 0) {
                    _prev();
                  }
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Card(
                    key: ValueKey('$_index-$_showAnswer'),
                    color: _showAnswer
                        ? Colors.teal.shade50
                        : Colors.indigo.shade50,
                    elevation: 4,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _showAnswer ? 'TRẢ LỜI' : 'CÂU HỎI',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _showAnswer ? card.answer : card.question,
                              textAlign: TextAlign.center,
                              style:
                                  Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _showAnswer
                                  ? 'Chạm để xem câu hỏi'
                                  : 'Chạm để xem đáp án',
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton.filledTonal(
                  iconSize: 32,
                  onPressed: _prev,
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton.filledTonal(
                  iconSize: 32,
                  onPressed: () => setState(() => _showAnswer = !_showAnswer),
                  icon: const Icon(Icons.flip),
                ),
                IconButton.filledTonal(
                  iconSize: 32,
                  onPressed: _next,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
