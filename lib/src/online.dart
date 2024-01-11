import 'package:callup247/main.dart';
import 'package:flutter/material.dart';

import 'responsive_text_styles.dart';

class Online extends StatefulWidget {
  final String userId;

  const Online({Key? key, required this.userId}) : super(key: key);

  @override
  State<Online> createState() => _OnlineState();
}

class _OnlineState extends State<Online> {
  late final Stream<List<Map<String, dynamic>>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = supabase.from('online').stream(primaryKey: ['user_id']);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _stream,
      builder: (BuildContext context,
          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasData) {
          final onlineUsers = snapshot.data!;
          final isUserOnline = onlineUsers.any(
            (user) => user['user_id'] == widget.userId,
          );

          return Row(
            children: [
              CircleAvatar(
                backgroundColor: isUserOnline ? Colors.green : Colors.grey,
                radius: 10,
              ),
              const SizedBox(width: 8),
              Text(isUserOnline ? 'Online' : 'Offline',
                  style: responsiveTextStyle(
                      context,
                      10,
                      isUserOnline ? Colors.green : Colors.grey,
                      FontWeight.bold)),
            ],
          );
        } else {
          // Handle loading or error state
          return Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 10,
              ),
              const SizedBox(width: 8),
              Text('Offline',
                  style: responsiveTextStyle(
                      context, 10, Colors.grey, FontWeight.bold)),
            ],
          );
        }
      },
    );
  }
}
