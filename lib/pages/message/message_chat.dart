import 'package:flutter/material.dart';

class MessageChat extends StatelessWidget {
  MessageChat({
    required this.onSubmitted,
    required this.awaitingResponse,
    super.key,
  });

  final TextEditingController _messageController = TextEditingController();

  final void Function(String) onSubmitted;
  final bool awaitingResponse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.05),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: !awaitingResponse
                  ? TextField(
                      controller: _messageController,
                      onSubmitted: onSubmitted,
                      decoration: const InputDecoration(
                        hintText: 'Write your message here...',
                        border: OutlineInputBorder(),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Fetching response...'),
                        ),
                      ],
                    ),
            ),
            IconButton(
              onPressed: !awaitingResponse
                  ? () => onSubmitted(_messageController.text)
                  : null,
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
