import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:chat_gpt_sdk/src/model/openai_model/model_data.dart';
import 'package:chatbot_gpt/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:velocity_x/velocity_x.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  late OpenAI? chatGPT;

  bool _isTyping = false;

  @override
  void initState() {
    chatGPT = OpenAI.instance.build(
        token: dotenv.env["API_KEY"],
        baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 60)));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    ChatMessage message = ChatMessage(
      text: _controller.text,
      sender: "user",
      isImage: false,
    );

    setState(() {
      _messages.insert(0, message);
      _isTyping = true;
    });

    _controller.clear();

    final request = CompleteText(
        prompt: message.text,
        model: ModelFromValue(model: kChatGptTurbo0301Model),
        maxTokens: 100);

    final response = await chatGPT!.onCompletion(request: request);
    Vx.log(response!.choices[0].text);
    insertNewData(response.choices[0].text);
  }

  void insertNewData(String response) {
    ChatMessage botMessage = ChatMessage(
      text: response,
      sender: "bot",
      isImage: false,
    );

    setState(() {
      _isTyping = false;
      _messages.insert(0, botMessage);
    });
  }

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 80.0,
      child: Row(
        children: [
          Flexible(
            child: Container(
              height: 50.0,
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.0),
                boxShadow: const [
                  BoxShadow(
                    offset: Offset(0, 3),
                    blurRadius: 5,
                    color: Colors.grey,
                  ),
                ],
              ),
              child: Container(
                alignment: Alignment.center,
                child: TextField(
                  maxLines: null,
                  controller: _controller,
                  onSubmitted: (value) => _sendMessage(),
                  decoration: InputDecoration.collapsed(
                    hintText: "Type a message",
                    hintStyle: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.blue),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("ChatGPT Demo")),
        body: SafeArea(
          child: Column(
            children: [
              Flexible(
                  child: ListView.builder(
                reverse: true,
                padding: Vx.m8,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _messages[index];
                },
              )),
              if (_isTyping) const CircularProgressIndicator(),
              const Divider(
                height: 1.0,
              ),
              Container(
                decoration: BoxDecoration(
                  color: context.cardColor,
                ),
                child: _buildTextComposer(),
              )
            ],
          ),
        ));
  }
}
