// lib/presentation/feed/widgets/ads_container.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:julink/common/helper/is_dark_mode.dart';
import 'package:julink/core/configs/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ad_item.dart';

/// robust base64 decoder (handles data URIs, whitespace, missing padding)
Uint8List? _decodeBase64Maybe(String src) {
  if (src.startsWith('http://') || src.startsWith('https://')) return null;
  var s = src.split(',').last;
  s = s.replaceAll(RegExp(r'\s+'), '');
  final mod4 = s.length % 4;
  if (mod4 != 0) s = s.padRight(s.length + (4 - mod4), '=');
  try {
    return base64Decode(s);
  } catch (_) {
    return null;
  }
}

class AdsContainer33 extends StatefulWidget {
  /// Provide your own ads, or let it use a small mock list.
  final List<AdItem>? items;
  final Duration rotateEvery;

  const AdsContainer33({
    super.key,
    this.items,
    this.rotateEvery = const Duration(seconds: 5),
  });

  @override
  State<AdsContainer33> createState() => _AdsContainer33State();
}

class _AdsContainer33State extends State<AdsContainer33> {
  late final List<AdItem> _ads;
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _ads =
        widget.items ??
        const [
          AdItem(
            id: 1,
            title: 'Learn Flutter the fun way',
            description: 'Interactive projects, bite-sized videos.',
            image: 'https://picsum.photos/seed/ads1/800/450',
            ctaText: 'Start now',
            targetUrl: 'https://flutter.dev',
          ),
          AdItem(
            id: 2,
            title: 'Design assets for devs',
            description: 'Icons, illustrations and mockups for your next app.',
            image: 'https://picsum.photos/seed/ads2/800/450',
            ctaText: 'Browse',
            targetUrl: 'https://www.figma.com/community',
          ),
          AdItem(
            id: 3,
            title: 'Deploy in minutes',
            description: 'Ship your full-stack projects with zero hassle.',
            image: 'https://picsum.photos/seed/ads3/800/450',
            ctaText: 'Try free',
            targetUrl: 'https://vercel.com',
          ),
        ];

    if (_ads.length > 1) {
      _timer = Timer.periodic(widget.rotateEvery, (_) {
        if (!mounted) return;
        setState(() => _index = (_index + 1) % _ads.length);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _open(AdItem ad) async {
    final url = ad.targetUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildImage(String src) {
    final bytes = _decodeBase64Maybe(src);
    final img = bytes != null
        ? Image.memory(
            bytes,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
          )
        : Image.network(
            src,
            fit: BoxFit.cover,
            loadingBuilder: (ctx, child, p) => p == null
                ? child
                : const Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
            errorBuilder: (ctx, err, st) =>
                const Center(child: Icon(Icons.broken_image_outlined)),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(aspectRatio: 16 / 9, child: img),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final ad = _ads[_index];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Card(
            elevation: isDark ? 0 : 1.5,
            shadowColor: Colors.black12,
            color: isDark
                ? AppColors.darkCardBackground
                : AppColors.lightCardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _open(ad),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildImage(ad.image),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ad.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        if (_ads.length > 1)
                          Row(
                            children: List.generate(_ads.length, (i) {
                              final active = i == _index;
                              return Container(
                                width: active ? 8 : 6,
                                height: active ? 8 : 6,
                                margin: const EdgeInsets.only(left: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: active
                                      ? (isDark
                                            ? Colors.white70
                                            : Colors.black87)
                                      : (isDark
                                            ? Colors.white24
                                            : Colors.black26),
                                ),
                              );
                            }),
                          ),
                      ],
                    ),
                    if (ad.description != null &&
                        ad.description!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          ad.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _open(ad),
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: Text(ad.ctaText),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
