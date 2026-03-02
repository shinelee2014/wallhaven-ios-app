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
  String _currentToplistRange = '1M';

  List<Wallpaper> get wallpapers => _wallpapers;
  bool get isLoading => _isLoading;
  String get currentPurity => _currentPurity;
  String get currentCategories => _currentCategories;
  String get currentSorting => _currentSorting;
  String get currentToplistRange => _currentToplistRange;

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
        toplistRange: _currentToplistRange,
      );
      
      _wallpapers.addAll(newWallpapers);
      _currentPage++;
    } catch (e) {
      debugPrint('Error fetching wallpapers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSorting(String sorting) {
    if (_currentSorting == sorting) return;
    _currentSorting = sorting;
    fetchWallpapers(refresh: true);
  }

  void setPurity(String purity) {
    if (_currentPurity == purity) return;
    _currentPurity = purity;
    fetchWallpapers(refresh: true);
  }

  void updateCategories(String categories) {
    if (_currentCategories == categories) return;
    _currentCategories = categories;
    fetchWallpapers(refresh: true);
  }

  void setToplistRange(String range) {
    if (_currentToplistRange == range) return;
    _currentToplistRange = range;
    if (_currentSorting == 'toplist') {
      fetchWallpapers(refresh: true);
    } else {
      notifyListeners();
    }
  }
}
