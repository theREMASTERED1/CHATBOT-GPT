import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage(
      {Key? key,
      required this.text,
      required this.sender,
      this.isImage = false})
      : super(key: key);
  final String text;
  final String sender;
  final bool isImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(child: Text(sender[0])),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(sender,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: isImage
                      ? AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.network(
                            text,
                            loadingBuilder: (context, child, loadingProgress) =>
                                loadingProgress == null
                                    ? child
                                    : const CircularProgressIndicator
                                        .adaptive(),
                          ),
                        )
                      : Text(text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
