import 'package:flutter/material.dart';
import '../models/wallpaper.dart';
import '../services/wallhaven_service.dart';

class WallpaperProvider with ChangeNotifier {
  final WallhavenService _service = WallhavenService();
  
  List<Wallpaper> _wallpapers = [];
  bool _isLoading = false;
  int _currentPage = 1;
  String _currentSorting = 'date_added';
  String _currentPurity = '110'; // SFW & Sketchy by default
  String _currentCategories = '111'; // All categories

  List<Wallpaper> get wallpapers => _wallpapers;
  bool get isLoading => _isLoading;

  Future<void> fetchWallpapers({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _wallpapers = [];
    }

    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newWallpapers = await _service.getWallpapers(
        page: _currentPage,
        sorting: _currentSorting,
        purity: _currentPurity,
        categories: _currentCategories,
      );
      
      _wallpapers.addAll(newWallpapers);
      _currentPage++;
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSorting(String sorting) {
    _currentSorting = sorting;
    fetchWallpapers(refresh: true);
  }

  void setPurity(String purity) {
    _currentPurity = purity;
    fetchWallpapers(refresh: true);
  }
}
