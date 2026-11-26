import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

const _baseUrl = 'http://test.local';

/// Builds an [ApiClient] whose HTTP layer is replaced by [handler].
ApiClient _clientWith(Future<http.Response> Function(http.Request) handler) {
  return ApiClient(client: MockClient(handler), baseUrl: _baseUrl);
}

http.Response _json(Object body, [int status = 200]) {
  return http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json'},
  );
}

void main() {
  group('Experience model', () {
    test('toJson uses snake_case keys and omits read-only fields', () {
      final experience = Experience(
        id: '1',
        title: 'Backend Intern',
        description: 'Built REST APIs',
        category: 'internship',
        startedAt: DateTime.utc(2026, 1, 1),
        endedAt: DateTime.utc(2026, 6, 1),
        isOngoing: false,
      );

      final json = experience.toJson();

      expect(json['title'], 'Backend Intern');
      expect(json['category'], 'internship');
      expect(json['started_at'], '2026-01-01T00:00:00.000Z');
      expect(json['ended_at'], '2026-06-01T00:00:00.000Z');
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('is_ongoing'), isFalse);
      expect(json.containsKey('startedAt'), isFalse);
    });

    test('fromJson parses a Django response', () {
      final experience = Experience.fromJson({
        'id': '7',
        'title': 'Freelance Dev',
        'description': 'Mobile apps',
        'category': 'freelance',
        'thumbnail': null,
        'started_at': '2026-01-01T00:00:00Z',
        'ended_at': null,
        'is_ongoing': true,
      });

      expect(experience.id, '7');
      expect(experience.category, 'freelance');
      expect(experience.thumbnail, isNull);
      expect(experience.startedAt, DateTime.utc(2026, 1, 1));
      expect(experience.endedAt, isNull);
      expect(experience.isOngoing, isTrue);
    });

    test('fromJson falls back to the default category', () {
      final experience = Experience.fromJson({
        'title': 'No category',
        'description': 'Field missing from the response',
      });

      expect(experience.category, 'full-time');
    });
  });

  group('ApiClient.getExperience', () {
    test('sends a public GET and maps the JSON list to models', () async {
      late http.Request captured;
      final api = _clientWith((request) async {
        captured = request;
        return _json([
          {
            'id': '1',
            'title': 'A',
            'description': 'first',
            'category': 'full-time',
            'started_at': '2026-01-01T00:00:00Z',
            'ended_at': null,
            'is_ongoing': true,
          },
          {
            'id': '2',
            'title': 'B',
            'description': 'second',
            'category': 'part-time',
            'started_at': null,
            'ended_at': null,
            'is_ongoing': false,
          },
        ]);
      });

      final result = await api.getExperience();

      expect(captured.method, 'GET');
      expect(captured.url.toString(), '$_baseUrl/api/v1/experiences/');
      // Reading is public: no token must be required.
      expect(captured.headers.containsKey('Authorization'), isFalse);
      expect(result, hasLength(2));
      expect(result.first.title, 'A');
      expect(result.first.isOngoing, isTrue);
      expect(result.last.category, 'part-time');
    });

    test('returns an empty list when the server has no entries', () async {
      final api = _clientWith((_) async => _json([]));

      expect(await api.getExperience(), isEmpty);
    });

    test('throws ApiException with the status code on a 500', () async {
      final api = _clientWith(
        (_) async => http.Response('Internal Server Error', 500),
      );

      await expectLater(
        api.getExperience(),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });
  });

  group('ApiClient.createExperience', () {
    test('sends an authenticated POST without read-only fields', () async {
      late http.Request captured;
      final api = _clientWith((request) async {
        captured = request;
        return _json({
          'id': '99',
          'title': 'Backend Intern',
          'description': 'Built REST APIs',
          'category': 'internship',
          'thumbnail': null,
          'started_at': '2026-01-01T00:00:00Z',
          'ended_at': null,
          'is_ongoing': true,
        }, 201);
      });

      final created = await api.createExperience(
        Experience(
          title: 'Backend Intern',
          description: 'Built REST APIs',
          category: 'internship',
          startedAt: DateTime.utc(2026, 1, 1),
        ),
        token: 'abc123',
      );

      expect(captured.method, 'POST');
      expect(captured.url.toString(), '$_baseUrl/api/v1/experiences/');
      expect(captured.headers['Authorization'], 'Token abc123');
      expect(captured.headers['Content-Type'], contains('application/json'));

      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['title'], 'Backend Intern');
      expect(body['category'], 'internship');
      expect(body['started_at'], '2026-01-01T00:00:00.000Z');
      expect(body['ended_at'], isNull);
      expect(body.containsKey('id'), isFalse);
      expect(body.containsKey('is_ongoing'), isFalse);

      // Server-assigned values come back in the parsed response.
      expect(created.id, '99');
      expect(created.isOngoing, isTrue);
    });

    test('throws ApiException(401) when the token is rejected', () async {
      final api = _clientWith(
        (_) async => _json({'detail': 'Invalid token.'}, 401),
      );

      await expectLater(
        api.createExperience(
          const Experience(title: 'X', description: 'Y'),
          token: 'expired',
        ),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401)
              .having((e) => e.message, 'message', contains('Invalid token')),
        ),
      );
    });

    test('throws ApiException(400) when the server rejects the data', () async {
      final api = _clientWith(
        (_) async => _json({
          'category': ['"weird" is not a valid choice.'],
        }, 400),
      );

      await expectLater(
        api.createExperience(
          const Experience(title: 'X', description: 'Y', category: 'weird'),
          token: 'abc123',
        ),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
    });
  });

  group('ApiClient auth endpoints', () {
    test('obtainToken posts credentials and returns the token', () async {
      late http.Request captured;
      final api = _clientWith((request) async {
        captured = request;
        return _json({'token': 'tok-1'});
      });

      final token = await api.obtainToken('geols', 'secret');

      expect(captured.method, 'POST');
      expect(captured.url.toString(), '$_baseUrl/api/v1/auth/token/');
      expect(jsonDecode(captured.body), {
        'username': 'geols',
        'password': 'secret',
      });
      expect(token, 'tok-1');
    });

    test('obtainToken throws ApiException(400) on bad credentials', () async {
      final api = _clientWith(
        (_) async => _json({
          'non_field_errors': ['Unable to log in with provided credentials.'],
        }, 400),
      );

      await expectLater(
        api.obtainToken('geols', 'wrong'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
    });

    test('logout sends the token in the Authorization header', () async {
      late http.Request captured;
      final api = _clientWith((request) async {
        captured = request;
        return http.Response('', 204);
      });

      await api.logout(token: 'tok-1');

      expect(captured.method, 'POST');
      expect(captured.url.toString(), '$_baseUrl/api/v1/auth/logout/');
      expect(captured.headers['Authorization'], 'Token tok-1');
    });
  });
}
