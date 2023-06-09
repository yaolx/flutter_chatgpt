import 'package:flutter_chatgpt/api/chat.dart';
import 'package:flutter_chatgpt/api/poetry.dart';
import 'package:flutter_chatgpt/model/chat.dart';
import 'package:flutter_chatgpt/pages/message/bubble.dart';
import 'package:flutter_chatgpt/pages/message/message_chat.dart';
import 'package:flutter_chatgpt/utils/cahce.dart';
import 'package:flutter_chatgpt/utils/string.dart';
import 'package:flutter_chatgpt/constant/prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatgpt/routes/index.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

final Uri _url = Uri.parse('https://yaolx.github.io/poetry');

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messages = <ChatMessage>[
    ChatMessage('Hello, how can I help?', false, 'text'),
  ];
  var _awaitingResponse = false;
  PromptType _promptType = PromptType.none;
  late ChatApi chatApi = ChatApi(AppCache.openAiApiKey);
  final ScrollController _controller = ScrollController();

  // 解析古诗
  void genPoetry(String message) async {
    RegExp reg = RegExp(r"【([^]*?)】");
    String content = message;
    String? title = '';
    String? author = '';
    String? dynasty = '';
    late String? text = '';
    Iterable<RegExpMatch> arr = reg.allMatches(message);
    for (int i = 0; i < arr.length; i++) {
      text = arr.elementAt(i)[0] ?? '';
      if (i == 0) {
        title = text.replaceAll('【', '').replaceAll('】', '');
      }

      if (i == 1) {
        author = text.replaceAll('【', '').replaceAll('】', '');
      }

      if (i == 2) {
        dynasty = text.replaceAll('【', '').replaceAll('】', '');
      }
      content = content.replaceAll(text, '');
    }
    // 古诗名称、作者、朝代都存在才录入issues
    if (StringUtils.isNotNill(title) &&
        StringUtils.isNotNill(author) &&
        StringUtils.isNotNill(dynasty)) {
      await PoetryApi.addPoetry({'title': title, 'body': content});
      // 加载完成后，自动滑动到底部
      _controller.jumpTo(_controller.position.maxScrollExtent);
    }
  }

  Future<void> _onSubmitted(String message, [bool isAi = false]) async {
    if (message.isEmpty) {
      return;
    }
    setState(() {
      _messages.add(ChatMessage(message, true, 'text'));
      _awaitingResponse = true;
    });
    final response = await chatApi.completeChat(_messages);
    setState(() {
      _messages.add(ChatMessage(response, false, 'text'));
      // 古诗录入过程
      if (!isAi && _promptType == PromptType.poetry) {
        genPoetry(response);
      }
      _awaitingResponse = false;
    });
  }

  void _selectTool(PromptType type) async {
    switch (type) {
      // 古诗背诵
      case PromptType.poetry:
        _promptType = type;
        await _onSubmitted(Prompt.poetry, true);
        break;
      default:
    }
  }

  Future<void> _launchUrl() async {
    if (await canLaunchUrl(_url)) {
      await launchUrl(_url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('chatgpt'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              if (!kIsWeb) {
                _launchUrl();
              } else {
                Routes.navigateTo(context, Routes.poetry);
              }
            },
            icon: const Icon(Icons.list),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _controller,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: <Widget>[
                      const Text('功能列表：'),
                      TextButton(
                        style: TextButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 14),
                        ),
                        onPressed: () {
                          _selectTool(PromptType.poetry);
                        },
                        child: const Text('古诗背诵'),
                      ),
                    ],
                  ),
                ),
                ..._messages.map((msg) => MessageBubble(
                      content: msg.content,
                      isUserMessage: msg.isUserMessage,
                    )),
              ],
            ),
          ),
          MessageChat(
            onSubmitted: _onSubmitted,
            awaitingResponse: _awaitingResponse,
          ),
        ],
      ),
    );
  }
}
