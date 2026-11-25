import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/experience.dart';

class ExperienceDetailScreen extends StatelessWidget {
  const ExperienceDetailScreen({super.key, required this.experience});

  final Experience experience;

  String _formatDate(DateTime date) {
    return date.toLocal().toString().split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final thumbnailUrl = experience.thumbnail ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(experience.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (thumbnailUrl.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  thumbnailUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    height: 200,
                    child: Center(child: Icon(Icons.broken_image, size: 48)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(experience.title, style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Category', style: textTheme.labelLarge),
            Text(experience.category),
            const SizedBox(height: 16),
            Text('Duration', style: textTheme.labelLarge),
            Text(
              '${experience.startedAt != null ? _formatDate(experience.startedAt!) : 'N/A'}'
              ' - '
              '${experience.endedAt != null ? _formatDate(experience.endedAt!) : 'Ongoing'}',
            ),
            const SizedBox(height: 16),
            Text('Description', style: textTheme.labelLarge),
            Text(experience.description),
          ],
        ),
      ),
    );
  }
}
