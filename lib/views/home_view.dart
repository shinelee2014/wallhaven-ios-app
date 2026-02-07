import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/wallpaper_provider.dart';
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
    Future.microtask(() =>
        context.read<WallpaperProvider>().fetchWallpapers());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<WallpaperProvider>().fetchWallpapers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('WALLHAVEN',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 4)),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () {
              // TODO: Show filter bottom sheet
            },
          ),
        ],
      ),
      body: Consumer<WallpaperProvider>(
        builder: (context, provider, child) {
          if (provider.wallpapers.isEmpty && provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          return MasonryGridView.count(
            controller: _scrollController,
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: const EdgeInsets.all(8),
            itemCount: provider.wallpapers.length,
            itemBuilder: (context, index) {
              final wallpaper = provider.wallpapers[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WallpaperDetailView(wallpaper: wallpaper),
                  ),
                ),
                child: Hero(
                  tag: wallpaper.id,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: wallpaper.thumbs['large']!,
                      placeholder: (context, url) => AspectRatio(
                        aspectRatio: wallpaper.dimensionX / wallpaper.dimensionY,
                        child: Container(color: Colors.grey[900]),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
