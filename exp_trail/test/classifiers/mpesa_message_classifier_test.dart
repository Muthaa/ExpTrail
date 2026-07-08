import 'package:flutter_test/flutter_test.dart';

import 'package:exp_trail/library/classifiers/mpesa_message_classifier.dart';

import 'package:exp_trail/core/enums/record_subtype.dart';

import '../helpers/fixture_loader.dart';

void main() {
  final classifier = MpesaMessageClassifier();

  test('Classifies Send Money', () {
    final messages = FixtureLoader.load('send_money.txt');

    for (final sms in messages) {
      final result = classifier.classify(sms);

      expect(result.subtype, RecordSubtype.sendMoney);
    }
  });
}
