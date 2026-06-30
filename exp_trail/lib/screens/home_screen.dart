import 'package:flutter/material.dart';

import '../models/raw_message.dart';
import '../services/permission_service.dart';
import '../sources/sms_transaction_source.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _permissionService = PermissionService();
  final _smsSource = SmsTransactionSource();
  //final smsSource = ref.read(smsSourceProvider);

  bool _loading = true;
  String? _error;

  List<RawMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final granted = await _permissionService.requestSmsPermission();

      if (!granted) {
        setState(() {
          _loading = false;
          _error = "SMS permission denied";
        });
        return;
      }

      final messages = await _smsSource.load();

      setState(() {
        _messages = messages;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("ExpTrail")),
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Messages (${_messages.length})")),
      body: ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final sms = _messages[index];

          return ListTile(
            title: Text(sms.sender),
            subtitle: Text(
              sms.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
    );
  }
}
