import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:surplus_served_mobile/features/donation/data/http_donation_repository.dart';
import 'package:surplus_served_mobile/features/donation/domain/donation.dart';

Map<String, dynamic> _donationJson() => {
      '_id': 'd1',
      'donorId': 'u1',
      'donorName': 'Kitchen',
      'title': 'Biryani',
      'portions': 10,
      'remainingPortions': 10,
      'status': 'available',
      'pickupWindowStart': '2026-01-01T10:00:00.000Z',
      'pickupWindowEnd': '2026-01-01T12:00:00.000Z',
      'expiresAt': '2026-01-01T14:00:00.000Z',
      'foodCategory': 'cooked_meal',
      'dietType': 'veg',
      'imageUrl': 'https://example.test/photo.jpg',
      'address': {'locality': 'Ameerpet'},
      'createdAt': '2026-01-01T09:00:00.000Z',
    };

Future<Donation> _create(
  HttpDonationRepository repo, {
  String? imagePath,
}) {
  return repo.create(
    donorId: 'u1',
    donorName: 'Kitchen',
    title: 'Biryani',
    portions: 10,
    pickupWindowStart: DateTime.utc(2026, 1, 1, 10),
    pickupWindowEnd: DateTime.utc(2026, 1, 1, 12),
    expiresAt: DateTime.utc(2026, 1, 1, 14),
    foodCategory: 'cooked_meal',
    dietType: 'veg',
    address: const PickupAddress(locality: 'Ameerpet'),
    imagePath: imagePath,
    authToken: 'token-123',
  );
}

void main() {
  test('without a photo sends JSON with expiry and food fields', () async {
    late http.Request sent;
    final repo = HttpDonationRepository(
      client: MockClient((request) async {
        sent = request;
        return http.Response(
          jsonEncode({'donation': _donationJson()}),
          201,
        );
      }),
    );

    final donation = await _create(repo);

    expect(sent.method, 'POST');
    expect(sent.headers['Authorization'], 'Bearer token-123');
    expect(sent.headers['Content-Type'], startsWith('application/json'));

    final body = jsonDecode(sent.body) as Map<String, dynamic>;
    expect(body['expiresAt'], '2026-01-01T14:00:00.000Z');
    expect(body['foodCategory'], 'cooked_meal');
    expect(body['dietType'], 'veg');
    expect(body['portions'], 10);
    expect(body['address'], {'locality': 'Ameerpet'});

    expect(donation.imageUrl, 'https://example.test/photo.jpg');
    expect(donation.foodCategory, 'cooked_meal');
    expect(donation.dietType, 'veg');
    expect(donation.expiresAt, DateTime.utc(2026, 1, 1, 14));
    expect(donation.remainingPortions, 10);
  });

  test('with a photo sends multipart with an image part', () async {
    final dir = await Directory.systemTemp.createTemp('donation_test');
    addTearDown(() => dir.delete(recursive: true));
    final photo = File('${dir.path}/food.png')
      ..writeAsBytesSync([0x89, 0x50, 0x4e, 0x47]);

    late http.BaseRequest sent;
    late String rawBody;
    final repo = HttpDonationRepository(
      client: MockClient((request) async {
        sent = request;
        rawBody = latin1.decode(request.bodyBytes);
        return http.Response(jsonEncode({'donation': _donationJson()}), 201);
      }),
    );

    await _create(repo, imagePath: photo.path);

    expect(sent.headers['Authorization'], 'Bearer token-123');
    expect(sent.headers['content-type'], startsWith('multipart/form-data'));
    expect(rawBody, contains('name="image"; filename="food.png"'));
    expect(rawBody, contains('content-type: image/png'));
    expect(rawBody, contains('name="expiresAt"'));
    expect(rawBody, contains('{"locality":"Ameerpet"}'));
  });

  test('rejects unsupported photo types before uploading', () async {
    var called = false;
    final repo = HttpDonationRepository(
      client: MockClient((_) async {
        called = true;
        return http.Response('{}', 201);
      }),
    );

    await expectLater(
      _create(repo, imagePath: '/tmp/photo.gif'),
      throwsA(
        predicate((e) => e.toString().contains('JPG, PNG and WEBP')),
      ),
    );
    expect(called, isFalse);
  });

  test('server error message is shown to the user', () async {
    final repo = HttpDonationRepository(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'message':
                'The food must stay safe to eat until the end of the pickup window.',
          }),
          400,
        ),
      ),
    );

    await expectLater(
      _create(repo),
      throwsA(predicate((e) => e.toString().contains('safe to eat'))),
    );
  });
}
