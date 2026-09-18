import 'package:flutter/material.dart';
import '../library/classifiers/mpesa_message_classifier.dart';
import '../database/app_database.dart';
import '../repositories/financial_records_repository.dart';
import '../repositories/raw_messages_repository.dart';
import '../services/permission_service.dart';
import '../services/transaction_import_service.dart';
import '../sources/sms_transaction_source.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _permissionService = PermissionService();
  final _smsSource = SmsTransactionSource();

  late final AppDatabase _database;
  late final FinancialRecordsRepository _financialRecordsRepository;
  late final RawMessagesRepository _rawMessagesRepository;
  late final TransactionImportService _importService;

  bool _loading = true;
  String? _error;
  ImportResult? _result;

  @override
  void initState() {
    super.initState();

    _database = AppDatabase();

    _financialRecordsRepository = FinancialRecordsRepository(_database);
    _rawMessagesRepository = RawMessagesRepository(_database);

    _importService = TransactionImportService(
      classifier: MpesaMessageClassifier(),
      financialRecordsRepository: _financialRecordsRepository,
      rawMessagesRepository: _rawMessagesRepository,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _importMessages();
    });
  }

  // Future<void> _importMessages() async {
  //   try {
  //     final granted = await _permissionService.requestSmsPermission();

  //     if (!granted) {
  //       setState(() {
  //         _loading = false;
  //         _error = 'SMS permission denied';
  //       });
  //       return;
  //     }

  //     final result = await _importService.importFromSource(_smsSource);

  //     if (!mounted) return;

  //     setState(() {
  //       _result = result;
  //       _loading = false;
  //     });
  //   } catch (e) {
  //     if (!mounted) return;

  //     setState(() {
  //       _loading = false;
  //       _error = e.toString();
  //     });
  //   }
  // }

  Future<void> _importMessages() async {
    try {
      debugPrint('IMPORT START');

      final granted = await _permissionService.requestSmsPermission();

      debugPrint('PERMISSION COMPLETE: $granted');

      if (!granted) {
        setState(() {
          _loading = false;
          _error = 'SMS permission denied';
        });
        return;
      }

      debugPrint('BEFORE IMPORT');

      final result = await _importService.importFromSource(_smsSource);

      debugPrint('AFTER IMPORT');

      if (!mounted) return;

      debugPrint('BEFORE UI STATE UPDATED');

      setState(() {
        _result = result;
        _loading = false;
      });

      debugPrint('UI STATE UPDATED');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Importing transactions...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('ExpTrail')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(_error!),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('ExpTrail')),
      body: Center(
        child: _result == null
            ? const Text('No import result')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Import complete',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  Text('Imported: ${_result!.imported}'),
                  Text('Skipped: ${_result!.skipped}'),
                  Text('Failed: ${_result!.failed}'),
                ],
              ),
      ),
    );
  }
}
