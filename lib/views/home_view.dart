import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/wallpaper_provider.dart';
import '../widgets/glass_container.dart';
import 'wallpaper_detail_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<WallpaperProvider>().fetchWallpapers());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      context.read<WallpaperProvider>().fetchWallpapers();
    }
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const FilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: GlassContainer(
          blur: 20,
          opacity: 0.05,
          child: AppBar(
            centerTitle: true,
            title: const Text('WALLHAVEN',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.tune_rounded, color: Colors.white70),
                onPressed: () => _showFilterSheet(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      body: Consumer<WallpaperProvider>(
        builder: (context, provider, child) {
          if (provider.wallpapers.isEmpty && provider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white24));
          }

          return MasonryGridView.count(
            controller: _scrollController,
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            padding: const EdgeInsets.fromLTRB(12, 110, 12, 12),
            itemCount: provider.wallpapers.length,
            itemBuilder: (context, index) {
              final wallpaper = provider.wallpapers[index];
              return _WallpaperCard(wallpaper: wallpaper);
            },
          );
        },
      ),
    );
  }
}

class _WallpaperCard extends StatelessWidget {
  final dynamic wallpaper;
  const _WallpaperCard({required this.wallpaper});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WallpaperDetailView(wallpaper: wallpaper),
        ),
      ),
      child: Hero(
        tag: wallpaper.id,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: wallpaper.thumbs['large']!,
              fit: BoxFit.cover,
              placeholder: (context, url) => AspectRatio(
                aspectRatio: wallpaper.dimensionX / wallpaper.dimensionY,
                child: Container(color: Colors.white.withOpacity(0.03)),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
      ),
    );
  }
}

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      blur: 30,
      opacity: 0.1,
      color: Colors.black,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('CATEGORIES',
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
          const SizedBox(height: 12),
          _CategorySelector(),
          const SizedBox(height: 24),
          const Text('PURITY',
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
          const SizedBox(height: 12),
          _PuritySelector(),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('APPLY FILTERS',
                  style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WallpaperProvider>();
    final cats = provider.currentCategories;

    return Row(
      children: [
        _FilterChip(
          label: 'GENERAL',
          isSelected: cats[0] == '1',
          onTap: () => provider.updateCategories(
              '${cats[0] == '1' ? '0' : '1'}${cats[1]}${cats[2]}'),
        ),
        const SizedBox(width: 10),
        _FilterChip(
          label: 'ANIME',
          isSelected: cats[1] == '1',
          onTap: () => provider.updateCategories(
              '${cats[0]}${cats[1] == '1' ? '0' : '1'}${cats[2]}'),
        ),
        const SizedBox(width: 10),
        _FilterChip(
          label: 'PEOPLE',
          isSelected: cats[2] == '1',
          onTap: () => provider.updateCategories(
              '${cats[0]}${cats[1]}${cats[2] == '1' ? '0' : '1'}'),
        ),
      ],
    );
  }
}

class _PuritySelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WallpaperProvider>();
    final purity = provider.currentPurity;

    return Row(
      children: [
        _FilterChip(
          label: 'SFW',
          isSelected: purity[0] == '1',
          onTap: () => provider.setPurity(
              '${purity[0] == '1' ? '0' : '1'}${purity[1]}${purity[2]}'),
        ),
        const SizedBox(width: 10),
        _FilterChip(
          label: 'SKETCHY',
          isSelected: purity[1] == '1',
          onTap: () => provider.setPurity(
              '${purity[0]}${purity[1] == '1' ? '0' : '1'}${purity[2]}'),
        ),
        const SizedBox(width: 10),
        _FilterChip(
          label: 'NSFW',
          isSelected: purity[2] == '1',
          onTap: () => provider.setPurity(
              '${purity[0]}${purity[1]}${purity[2] == '1' ? '0' : '1'}'),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white60,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
