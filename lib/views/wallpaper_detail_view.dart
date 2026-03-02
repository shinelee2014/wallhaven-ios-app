import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/wallpaper.dart';
import '../widgets/glass_container.dart';
import 'package:url_launcher/url_launcher.dart';

class WallpaperDetailView extends StatelessWidget {
  final Wallpaper wallpaper;

  const WallpaperDetailView({super.key, required this.wallpaper});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GlassContainer(
            borderRadius: BorderRadius.circular(50),
            blur: 10,
            opacity: 0.2,
            child: const BackButton(color: Colors.white),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: Hero(
                tag: wallpaper.id,
                child: CachedNetworkImage(
                  imageUrl: wallpaper.path,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CachedNetworkImage(
                      imageUrl: wallpaper.thumbs['large']!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: GlassContainer(
              blur: 25,
              opacity: 0.1,
              borderRadius: BorderRadius.circular(24),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            wallpaper.resolution,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(wallpaper.fileSize / 1024 / 1024).toStringAsFixed(2)} MB • ${wallpaper.category.toUpperCase()}',
                            style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      _PurityBadge(purity: wallpaper.purity),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.download_rounded,
                          label: 'DOWNLOAD',
                          onPressed: () => launchUrl(Uri.parse(wallpaper.path)),
                          isPrimary: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _ActionButton(
                        icon: Icons.share_rounded,
                        label: '',
                        onPressed: () {},
                        isPrimary: false,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PurityBadge extends StatelessWidget {
  final String purity;
  const _PurityBadge({required this.purity});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (purity.toLowerCase()) {
      case 'sfw':
        color = Colors.greenAccent;
        break;
      case 'sketchy':
        color = Colors.orangeAccent;
        break;
      case 'nsfw':
        color = Colors.redAccent;
        break;
      default:
        color = Colors.white24;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        purity.toUpperCase(),
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.white : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.black : Colors.white,
              size: 20,
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 1,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
