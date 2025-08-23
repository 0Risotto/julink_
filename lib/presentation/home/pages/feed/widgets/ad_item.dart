// lib/presentation/feed/widgets/ad_item.dart
class AdItem {
  final int id;
  final String title;
  final String? description;

  /// Can be an https URL or a base64 string (optionally with data URI prefix).
  final String image;
  final String ctaText;
  final String? targetUrl;

  const AdItem({
    required this.id,
    required this.title,
    required this.image,
    this.description,
    this.ctaText = 'Learn more',
    this.targetUrl,
  });
}
