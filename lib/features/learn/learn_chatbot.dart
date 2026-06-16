import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LearnChatBot extends StatefulWidget {
  const LearnChatBot({super.key});

  @override
  State<LearnChatBot> createState() => _LearnChatBotState();
}

class _LearnChatBotState extends State<LearnChatBot> {
  final TextEditingController controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  bool loading = false;
  final Map<String, String> cache = {};

  Future<String> askAI(String input) async {
    final key = input.toLowerCase().trim();
    if (cache.containsKey(key)) return cache[key]!;

    try {
      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer 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', // ← paste your key here
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant', // ← updated model
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a friendly womens health assistant. Explain PCOS, PCOD, hormones, cycles in simple, safe language. Do NOT diagnose or give medical treatment. Answer briefly and clearly.'
            },
            {'role': 'user', 'content': input}
          ],
          'max_tokens': 500,
        }),
      );

      print('STATUS: ${response.statusCode}');
      print('BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['choices']?[0]?['message']?['content'] ??
            "I couldn't respond.";
        cache[key] = text;
        return text;
      } else {
        final error = jsonDecode(response.body);
        return "API Error: ${error['error']?['message'] ?? response.body}";
      }
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  void sendMessage(String text) async {
    setState(() {
      messages.add({"role": "user", "text": text});
      loading = true;
    });

    try {
      final reply = await askAI(text);
      setState(() => messages.add({"role": "bot", "text": reply}));
    } catch (e) {
      setState(() =>
          messages.add({"role": "bot", "text": "Error: ${e.toString()}"}));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [

          // ── Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.health_and_safety, color: Color(0xFF7ED6B2)),
              SizedBox(width: 8),
              Text(
                "AI Health Assistant 🤖",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const Divider(height: 20),

          // ── Messages ──
          Expanded(
            child: messages.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.chat_bubble_outline,
                          size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        "Ask me anything about\nPCOS, PCOD, hormones or cycles 🌿",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final msg = messages[i];
                      final isUser = msg["role"] == "user";

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(12),
                          constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isUser
                                ? const Color(0xFF7ED6B2)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: Radius.circular(isUser ? 12 : 0),
                              bottomRight: Radius.circular(isUser ? 0 : 12),
                            ),
                          ),
                          child: Text(
                            msg["text"]!,
                            style: TextStyle(
                              color: isUser ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // ── Loading ──
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF7ED6B2),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Thinking...",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

          const Divider(height: 8),

          // ── Input ──
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Ask about PCOS, hormones...",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      sendMessage(val.trim());
                      controller.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: const Color(0xFF7ED6B2),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      sendMessage(controller.text.trim());
                      controller.clear();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}