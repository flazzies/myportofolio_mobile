import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/models/project.dart';

void main() {
  group('Project', () {
    test('toJson uses snake_case keys and omits id', () {
      const project = Project(
        id: '1',
        title: 'My App',
        description: 'A cool app',
        techStack: 'Flutter, Django',
        projectUrl: 'https://example.com',
      );

      final json = project.toJson();

      expect(json['title'], 'My App');
      expect(json['tech_stack'], 'Flutter, Django');
      expect(json['project_url'], 'https://example.com');
      expect(json['project_image_url'], '');
      expect(json.containsKey('id'), isFalse);
    });

    test('fromJson parses a Django response', () {
      final project = Project.fromJson({
        'id': '7',
        'title': 'My App',
        'description': 'A cool app',
        'tech_stack': 'Flutter',
        'project_url': 'https://example.com',
      });

      expect(project.id, '7');
      expect(project.techStack, 'Flutter');
      expect(project.projectImageUrl, '');
    });
  });
}
