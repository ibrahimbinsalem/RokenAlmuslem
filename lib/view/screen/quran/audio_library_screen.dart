import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/quran_controller.dart';
import 'package:rokenalmuslem/core/services/localnotification.dart';
import 'package:rokenalmuslem/data/data/data_surat.dart';

class QuranAudioLibraryPage extends StatefulWidget {
  const QuranAudioLibraryPage({super.key});

  @override
  State<QuranAudioLibraryPage> createState() => _QuranAudioLibraryPageState();
}

class _QuranAudioLibraryPageState extends State<QuranAudioLibraryPage> {
  final QuranController quranController = Get.find();
  final NotificationService _notificationService = Get.find();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _selectedReciterId;
  String? _lastReciterId;
  int? _lastSurahNumber;
  bool _recitersLoaded = false;
  bool _isLoading = false;
  bool _isPlaying = false;
  int? _currentSurahNumber;
  String _query = '';
  final Map<String, double> _downloadProgress = {};
  final Set<String> _downloading = {};
  final List<int> _queue = [];
  final Set<int> _favoriteSurahs = {};
  final Set<String> _favoriteReciters = {};
  bool _isOnline = true;
  bool _checkingConnection = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String? _countryFilter;
  String? _riwayaFilter;
  bool _showFavoriteSurahsOnly = false;
  bool _showFavoriteRecitersOnly = false;
  Timer? _sleepTimer;
  DateTime? _sleepEndAt;
  bool _stopAfterSurah = false;
  StreamSubscription<String>? _notificationSub;

  static const _pageBackground = Color(0xFFFDFBF5);
  static const _pageBorder = Color(0xFFE4D8C7);
  static const _inkColor = Color(0xFF3D2B1F);
  static const _accent = Color(0xFF8B6B4A);
  static const _softAccent = Color(0xFFEFE5D8);

  @override
  void initState() {
    super.initState();
    _lastSurahNumber = quranController.getLastAudioSurah();
    _lastReciterId = quranController.getLastAudioReciter();
    _loadFavorites();
    _notificationSub =
        _notificationService.actionStream.listen(_handleNotificationAction);
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
      _syncAudioNotification();
    });
    _audioPlayer.onDurationChanged.listen((duration) {
      if (!mounted) return;
      setState(() {
        _duration = duration;
      });
      if (_currentSurahNumber != null && _selectedReciterId != null) {
        quranController.saveAudioDuration(
          _currentSurahNumber!,
          _selectedReciterId!,
          duration,
        );
      }
    });
    _audioPlayer.onPositionChanged.listen((position) {
      if (!mounted) return;
      setState(() {
        _position = position;
      });
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _currentSurahNumber = null;
        _position = Duration.zero;
        _duration = Duration.zero;
      });
      _handlePlaybackComplete();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkConnection();
    });
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _notificationSub?.cancel();
    _notificationService.cancelAudioNotification();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        title: const Text(
          'مكتبة القرآن الصوتية',
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 22,
            color: _inkColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: _pageBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: _inkColor),
        actions: [
          IconButton(
            tooltip: 'تحديث قائمة القرّاء',
            onPressed: () async {
              await quranController.loadReciters(force: true);
              if (!mounted) return;
              setState(() {
                _recitersLoaded = true;
                _selectedReciterId = null;
                _countryFilter = null;
                _riwayaFilter = null;
              });
              Get.snackbar('تم التحديث', 'تم تحديث قائمة القرّاء');
            },
            icon: const Icon(Icons.refresh, color: _accent),
          ),
        ],
      ),
      body: GetX<QuranController>(
        builder: (controller) {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final surahs = controller.surahs;
          final filtered = surahs.where((surah) {
            if (_query.isEmpty) return true;
            final query = _query.toLowerCase();
            return surah.name.toLowerCase().contains(query) ||
                surah.englishName.toLowerCase().contains(query) ||
                surah.englishNameTranslation.toLowerCase().contains(query);
          }).where((surah) {
            if (!_showFavoriteSurahsOnly) return true;
            return _favoriteSurahs.contains(surah.number);
          }).toList();

          return Column(
            children: [
              _buildReciterCard(controller),
              _buildLastPlayedCard(controller, surahs),
              _buildSearchBar(),
              _buildSurahFilters(),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(
                    bottom: _currentSurahNumber == null ? 24 : 110,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final surah = filtered[index];
                    return _buildAudioSurahCard(controller, surah);
                  },
                ),
              ),
              if (_currentSurahNumber != null)
                _buildMiniPlayer(controller, surahs),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReciterCard(QuranController controller) {
    final reciterEntries = _filteredReciters(controller);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: _pageBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _pageBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'اختر القارئ',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 16,
              color: _inkColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _softAccent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _pageBorder, width: 1),
            ),
            child: controller.reciters.isEmpty
                ? TextButton(
                    onPressed: () async {
                      await controller.loadReciters();
                      if (!mounted) return;
                      setState(() {
                        _recitersLoaded = true;
                        if (_selectedReciterId == null &&
                            controller.reciters.isNotEmpty) {
                          _selectedReciterId = controller.reciters.keys.first;
                        }
                      });
                    },
                    child: const Text(
                      'تحميل قائمة القرّاء',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        color: _accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : reciterEntries.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'لا توجد قرّاء مطابقون للفلترة',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            color: _accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: reciterEntries.any(
                                    (entry) =>
                                        entry.key == _selectedReciterId,
                                  )
                              ? _selectedReciterId
                              : null,
                          isExpanded: true,
                          dropdownColor: _accent,
                          iconEnabledColor: _accent,
                          hint: const Text(
                            'اختر القارئ',
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              color: _accent,
                            ),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          selectedItemBuilder: (context) {
                            return reciterEntries
                                .map(
                                  (entry) => Text(
                                    _formatReciterName(entry.value),
                                    style: const TextStyle(
                                      fontFamily: 'Amiri',
                                      color: _inkColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )
                                .toList();
                          },
                          items: reciterEntries
                              .map(
                                (entry) => DropdownMenuItem(
                                  value: entry.key,
                                  child: Text(
                                    _formatReciterName(entry.value),
                                    style: const TextStyle(
                                      fontFamily: 'Amiri',
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) async {
                            if (value == null) return;
                            setState(() {
                              _selectedReciterId = value;
                            });
                            await _audioPlayer.stop();
                            if (!mounted) return;
                            setState(() {
                              _isPlaying = false;
                              _currentSurahNumber = null;
                            });
                          },
                        ),
                      ),
          ),
          const SizedBox(height: 10),
          _buildReciterFilters(controller),
          _buildReciterMeta(controller),
          _buildReciterFavoriteAction(),
          Row(
            children: [
              Icon(
                _isOnline ? Icons.wifi : Icons.wifi_off,
                color: _isOnline ? const Color(0xFF4E8B5A) : Colors.redAccent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _checkingConnection
                      ? 'جارٍ فحص الاتصال...'
                      : (_isOnline
                          ? 'متصل بالإنترنت'
                          : 'غير متصل بالإنترنت'),
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 12,
                    color: _inkColor.withOpacity(0.7),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'تحديث حالة الاتصال',
                onPressed: _checkingConnection ? null : _checkConnection,
                icon: const Icon(Icons.refresh, color: _accent, size: 20),
              ),
            ],
          ),
          Text(
            'سيتم تشغيل التلاوات عبر الإنترنت حسب القارئ المحدد.',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 12,
              color: _inkColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReciterMeta(QuranController controller) {
    if (_selectedReciterId == null) return const SizedBox.shrink();
    final selectedName = controller.reciters[_selectedReciterId!];

    return FutureBuilder<Map<String, String>?>(
      future: controller.getReciterMetaAsync(
        reciterId: _selectedReciterId!,
        reciterName: selectedName,
      ),
      builder: (context, snapshot) {
        final meta = snapshot.data;
        if (meta == null || meta.isEmpty) {
          return const SizedBox.shrink();
        }
        final country = meta['country'];
        final riwaya = meta['riwaya'];
        if ((country == null || country.isEmpty) &&
            (riwaya == null || riwaya.isEmpty)) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (riwaya != null && riwaya.isNotEmpty)
                _buildMetaChip('الرواية: $riwaya'),
              if (country != null && country.isNotEmpty)
                _buildMetaChip('البلد: $country'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetaChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _softAccent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _pageBorder, width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Amiri',
          fontSize: 12,
          color: _inkColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildReciterFilters(QuranController controller) {
    if (controller.reciters.isEmpty) return const SizedBox.shrink();
    final countries = _availableCountries(controller);
    final riwayas = _availableRiwayas(controller);
    if (countries.isEmpty && riwayas.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          FilterChip(
            label: const Text(
              'المفضلة',
              style: TextStyle(fontFamily: 'Amiri'),
            ),
            selected: _showFavoriteRecitersOnly,
            onSelected: (value) {
              setState(() {
                _showFavoriteRecitersOnly = value;
                if (_selectedReciterId != null &&
                    !_filteredReciters(controller).any(
                      (entry) => entry.key == _selectedReciterId,
                    )) {
                  _selectedReciterId = null;
                }
              });
            },
            selectedColor: _softAccent,
            checkmarkColor: _accent,
          ),
          _buildFilterDropdown(
            label: 'البلد',
            value: _countryFilter,
            options: countries,
            onChanged: (value) {
              setState(() {
                _countryFilter = value;
                if (_selectedReciterId != null &&
                    !_filteredReciters(controller).any(
                      (entry) => entry.key == _selectedReciterId,
                    )) {
                  _selectedReciterId = null;
                }
              });
            },
          ),
          _buildFilterDropdown(
            label: 'الرواية',
            value: _riwayaFilter,
            options: riwayas,
            onChanged: (value) {
              setState(() {
                _riwayaFilter = value;
                if (_selectedReciterId != null &&
                    !_filteredReciters(controller).any(
                      (entry) => entry.key == _selectedReciterId,
                    )) {
                  _selectedReciterId = null;
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    if (options.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _softAccent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _pageBorder, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          hint: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Amiri',
              color: _accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          dropdownColor: _pageBackground,
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text(
                'الكل',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  color: _inkColor,
                ),
              ),
            ),
            ...options.map(
              (option) => DropdownMenuItem<String?>(
                value: option,
                child: Text(
                  option,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    color: _inkColor,
                  ),
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildReciterFavoriteAction() {
    if (_selectedReciterId == null) return const SizedBox.shrink();
    final isFavorite = _favoriteReciters.contains(_selectedReciterId);
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () {
          _toggleFavoriteReciter(_selectedReciterId!);
        },
        style: TextButton.styleFrom(
          foregroundColor: isFavorite ? const Color(0xFFF2B01E) : _accent,
          textStyle: const TextStyle(
            fontFamily: 'Amiri',
            fontWeight: FontWeight.w700,
          ),
        ),
        icon: Icon(
          isFavorite ? Icons.star : Icons.star_border,
          size: 18,
        ),
        label: Text(isFavorite ? 'إزالة من مفضلة القرّاء' : 'حفظ القارئ'),
      ),
    );
  }

  Widget _buildLastPlayedCard(
    QuranController controller,
    List<SurahData> surahs,
  ) {
    if (_lastSurahNumber == null || _lastSurahNumber == 0) {
      return const SizedBox.shrink();
    }

    SurahData? surah;
    try {
      surah = surahs.firstWhere((item) => item.number == _lastSurahNumber);
    } catch (_) {
      surah = null;
    }

    if (surah == null) return const SizedBox.shrink();
    final surahData = surah;
    final reciterName = _lastReciterId == null
        ? null
        : controller.reciters[_lastReciterId!];
    final hasOffline = _lastReciterId != null &&
        _isDownloaded(surahData.number, _lastReciterId);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _softAccent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _pageBorder, width: 1.1),
      ),
      child: Row(
        children: [
          const Icon(Icons.play_circle_fill, color: _accent, size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'آخر سورة تم تشغيلها',
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 14,
                    color: _inkColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${surahData.name}${reciterName == null ? '' : ' • $reciterName'}',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 12,
                    color: _inkColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              TextButton(
                onPressed: () async {
                  if (_lastReciterId != null) {
                    if (!_recitersLoaded) {
                      await controller.loadReciters();
                      _recitersLoaded = true;
                    }
                    setState(() {
                      _selectedReciterId = _lastReciterId;
                    });
                  }
                  await _togglePlayback(controller, surahData);
                },
                style: TextButton.styleFrom(
                  foregroundColor: _accent,
                  textStyle: const TextStyle(
                    fontFamily: 'Amiri',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('تشغيل الآن'),
              ),
              if (hasOffline)
                TextButton(
                  onPressed: () async {
                    if (_lastReciterId == null) return;
                    await _playOffline(controller, surahData, _lastReciterId!);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF4E8B5A),
                    textStyle: const TextStyle(
                      fontFamily: 'Amiri',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('تشغيل بدون إنترنت'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: _pageBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _pageBorder, width: 1.1),
      ),
      child: TextField(
        onChanged: (value) => setState(() => _query = value.trim()),
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          fontFamily: 'Amiri',
          fontSize: 16,
          color: _inkColor,
        ),
        decoration: const InputDecoration(
          hintText: 'ابحث عن سورة للصوت...',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: _accent),
        ),
      ),
    );
  }

  Widget _buildSurahFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          FilterChip(
            label: const Text(
              'المفضلة فقط',
              style: TextStyle(fontFamily: 'Amiri'),
            ),
            selected: _showFavoriteSurahsOnly,
            onSelected: (value) {
              setState(() {
                _showFavoriteSurahsOnly = value;
              });
            },
            selectedColor: _softAccent,
            checkmarkColor: _accent,
          ),
          const Spacer(),
          Text(
            'المفضلة: ${_arabicNumber(_favoriteSurahs.length)}',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 12,
              color: _inkColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioSurahCard(QuranController controller, SurahData surah) {
    final isCurrent = _currentSurahNumber == surah.number;
    final isBusy = _isLoading && isCurrent;
    final isPlaying = isCurrent && _isPlaying;
    final reciterId = _selectedReciterId;
    final downloadKey = reciterId == null ? null : '${surah.number}_$reciterId';
    final isDownloading =
        downloadKey != null && _downloading.contains(downloadKey);
    final progress =
        downloadKey != null ? _downloadProgress[downloadKey] : null;
    final isDownloaded =
        downloadKey != null && _isDownloaded(surah.number, reciterId);
    final isFavorite = _favoriteSurahs.contains(surah.number);
    final isQueued = _queue.contains(surah.number);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _pageBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _pageBorder, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _softAccent,
              shape: BoxShape.circle,
              border: Border.all(color: _pageBorder, width: 1.2),
            ),
            child: Center(
              child: Text(
                controller.convertToArabicNumber(surah.number.toString()),
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  color: _inkColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  surah.name,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    color: _inkColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  surah.englishName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_selectedReciterId != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: _buildAudioMeta(
                      surah.number,
                      _selectedReciterId!,
                    ),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: isQueued ? 'ضمن قائمة التشغيل' : 'إضافة لقائمة التشغيل',
                onPressed: () => _toggleQueue(surah.number),
                icon: Icon(
                  isQueued ? Icons.queue_music : Icons.playlist_add,
                  color: _accent,
                  size: 22,
                ),
              ),
              IconButton(
                tooltip: isFavorite ? 'إزالة من المفضلة' : 'إضافة للمفضلة',
                onPressed: () => _toggleFavoriteSurah(surah.number),
                icon: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? const Color(0xFFF2B01E) : _accent,
                  size: 22,
                ),
              ),
              IconButton(
                tooltip: isPlaying ? 'إيقاف مؤقت' : 'تشغيل التلاوة',
                onPressed:
                    isBusy ? null : () => _togglePlayback(controller, surah),
                icon: isBusy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _accent,
                        ),
                      )
                    : Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: _accent,
                        size: 28,
                      ),
              ),
              IconButton(
                tooltip:
                    isDownloaded ? 'تم التحميل' : 'تحميل للاستماع بدون إنترنت',
                onPressed: isDownloaded || isDownloading
                    ? null
                    : () => _downloadSurahAudio(controller, surah),
                icon: isDownloading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: progress,
                          color: _accent,
                        ),
                      )
                    : Icon(
                        isDownloaded ? Icons.check_circle : Icons.download,
                        color: isDownloaded ? const Color(0xFF4E8B5A) : _accent,
                        size: 22,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _togglePlayback(
    QuranController controller,
    SurahData surah,
  ) async {
    try {
      if (_isPlaying && _currentSurahNumber == surah.number) {
        await _audioPlayer.pause();
        return;
      }
      if (!_isPlaying &&
          _currentSurahNumber == surah.number &&
          _position > Duration.zero) {
        await _audioPlayer.resume();
        return;
      }
      await _startPlayback(controller, surah);
    } catch (e, s) {
      debugPrint('Audio playback error: $e\n$s');
      Get.snackbar('خطأ', 'تعذر تشغيل الصوت حالياً');
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startPlayback(
    QuranController controller,
    SurahData surah,
  ) async {
    if (!_recitersLoaded) {
      await controller.loadReciters();
      _recitersLoaded = true;
      if (_selectedReciterId == null && controller.reciters.isNotEmpty) {
        _selectedReciterId = controller.reciters.keys.first;
      }
    }

    if (_selectedReciterId == null) {
      Get.snackbar('تنبيه', 'يرجى اختيار القارئ أولاً');
      return;
    }

    setState(() {
      _isLoading = true;
      _currentSurahNumber = surah.number;
      _lastSurahNumber = surah.number;
      _lastReciterId = _selectedReciterId;
      _position = Duration.zero;
      _duration = Duration.zero;
    });
    controller.saveLastAudioPlay(surah.number, _selectedReciterId!);

    final cachedPath = await controller.getDownloadedAudioPath(
      surah.number,
      _selectedReciterId!,
    );
    if (cachedPath != null && cachedPath.isNotEmpty) {
      await _audioPlayer.play(DeviceFileSource(cachedPath));
    } else {
      final url = await controller.getAudioUrl(
        surah.number,
        _selectedReciterId!,
      );
      if (url == null || url.isEmpty) {
        Get.snackbar('خطأ', 'تعذر تشغيل الصوت حالياً');
        return;
      }
      await _audioPlayer.play(UrlSource(url));
    }
  }

  Future<void> _playOffline(
    QuranController controller,
    SurahData surah,
    String reciterId,
  ) async {
    try {
      setState(() {
        _isLoading = true;
        _currentSurahNumber = surah.number;
        _selectedReciterId = reciterId;
        _position = Duration.zero;
        _duration = Duration.zero;
      });
      controller.saveLastAudioPlay(surah.number, reciterId);

      final cachedPath = await controller.getDownloadedAudioPath(
        surah.number,
        reciterId,
      );
      if (cachedPath == null || cachedPath.isEmpty) {
        Get.snackbar('تنبيه', 'لا يوجد ملف صوتي محفوظ لهذه السورة');
        return;
      }

      await _audioPlayer.play(DeviceFileSource(cachedPath));
    } catch (e, s) {
      debugPrint('Audio offline play error: $e\n$s');
      Get.snackbar('خطأ', 'تعذر تشغيل الصوت دون إنترنت');
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handlePlaybackComplete() async {
    if (_stopAfterSurah) {
      setState(() {
        _stopAfterSurah = false;
      });
      _clearSleepTimer();
      _queue.clear();
      _syncAudioNotification();
      return;
    }
    if (_queue.isNotEmpty) {
      final nextSurahNumber = _queue.removeAt(0);
      await _playFromQueue(nextSurahNumber);
      return;
    }
    _syncAudioNotification();
  }

  Future<void> _playFromQueue(int surahNumber) async {
    SurahData? surah;
    try {
      surah = quranController.surahs
          .firstWhere((item) => item.number == surahNumber);
    } catch (_) {
      surah = null;
    }
    if (surah == null) return;
    await _startPlayback(quranController, surah);
  }

  void _toggleQueue(int surahNumber) {
    setState(() {
      if (_queue.contains(surahNumber)) {
        _queue.remove(surahNumber);
      } else {
        _queue.add(surahNumber);
      }
    });
    Get.snackbar(
      'قائمة التشغيل',
      _queue.contains(surahNumber)
          ? 'تمت إضافة السورة إلى قائمة التشغيل'
          : 'تمت إزالة السورة من قائمة التشغيل',
    );
  }

  void _showQueueSheet() {
    final surahs = quranController.surahs;
    showModalBottomSheet(
      context: context,
      backgroundColor: _pageBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'قائمة التشغيل',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  color: _inkColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              if (_queue.isEmpty)
                const Text(
                  'لا توجد سور مضافة بعد',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    color: _accent,
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _queue.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final number = _queue[index];
                      SurahData? surah;
                      try {
                        surah = surahs
                            .firstWhere((item) => item.number == number);
                      } catch (_) {
                        surah = null;
                      }
                      return ListTile(
                        title: Text(
                          surah?.name ?? 'سورة رقم $number',
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            color: _inkColor,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, color: _accent),
                          onPressed: () {
                            setState(() {
                              _queue.remove(number);
                            });
                            if (_queue.isEmpty) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                        onTap: () async {
                          Navigator.of(context).pop();
                          await _playFromQueue(number);
                        },
                      );
                    },
                  ),
                ),
              if (_queue.isNotEmpty) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _queue.clear();
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('مسح القائمة'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showSleepTimerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _pageBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'مؤقت النوم',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  color: _inkColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildTimerOption(const Duration(minutes: 10)),
                  _buildTimerOption(const Duration(minutes: 20)),
                  _buildTimerOption(const Duration(minutes: 30)),
                  _buildTimerOption(const Duration(minutes: 45)),
                  _buildTimerOption(const Duration(minutes: 60)),
                  _buildTimerOption(null, label: 'عند نهاية السورة'),
                ],
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  _clearSleepTimer();
                  Navigator.of(context).pop();
                },
                child: const Text('إلغاء المؤقت'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimerOption(Duration? duration, {String? label}) {
    final text = label ??
        'إيقاف بعد ${_arabicNumber(duration!.inMinutes)} دقيقة';
    return OutlinedButton(
      onPressed: () {
        Navigator.of(context).pop();
        if (duration == null) {
          setState(() {
            _stopAfterSurah = true;
          });
          _clearSleepTimer();
          return;
        }
        _setSleepTimer(duration);
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: _accent,
        side: const BorderSide(color: _pageBorder),
      ),
      child: Text(
        text,
        style: const TextStyle(fontFamily: 'Amiri'),
      ),
    );
  }

  void _setSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    setState(() {
      _stopAfterSurah = false;
      _sleepEndAt = DateTime.now().add(duration);
    });
    _sleepTimer = Timer(duration, () async {
      await _audioPlayer.stop();
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _currentSurahNumber = null;
        _sleepEndAt = null;
      });
      _queue.clear();
      _syncAudioNotification();
    });
  }

  void _clearSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    setState(() {
      _sleepEndAt = null;
    });
  }

  Widget _buildMiniPlayer(QuranController controller, List<SurahData> surahs) {
    final currentNumber = _currentSurahNumber;
    if (currentNumber == null) return const SizedBox.shrink();
    SurahData? surah;
    try {
      surah = surahs.firstWhere((item) => item.number == currentNumber);
    } catch (_) {
      surah = null;
    }
    if (surah == null) return const SizedBox.shrink();
    final reciterName = _selectedReciterId == null
        ? null
        : controller.reciters[_selectedReciterId!];
    final progress = _duration.inMilliseconds == 0
        ? 0.0
        : (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _pageBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _pageBorder, width: 1.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.graphic_eq, color: _accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.name,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 16,
                          color: _inkColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (reciterName != null)
                        Text(
                          reciterName,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 12,
                            color: _inkColor.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'قائمة التشغيل',
                  onPressed: _showQueueSheet,
                  icon: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      const Icon(Icons.queue_music, color: _accent),
                      if (_queue.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF2B01E),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            _arabicNumber(_queue.length),
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'مؤقت النوم',
                  onPressed: _showSleepTimerSheet,
                  icon: Icon(
                    _sleepEndAt != null || _stopAfterSurah
                        ? Icons.bedtime
                        : Icons.bedtime_outlined,
                    color: _accent,
                  ),
                ),
                IconButton(
                  tooltip: _isPlaying ? 'إيقاف مؤقت' : 'تشغيل',
                  onPressed: () => _togglePlayback(controller, surah!),
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: _accent,
                  ),
                ),
                IconButton(
                  tooltip: 'إيقاف',
                  onPressed: () async {
                    await _audioPlayer.stop();
                    if (!mounted) return;
                    setState(() {
                      _isPlaying = false;
                      _currentSurahNumber = null;
                      _position = Duration.zero;
                      _duration = Duration.zero;
                    });
                    _syncAudioNotification();
                  },
                  icon: const Icon(Icons.stop_circle, color: _accent),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: _pageBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(_accent),
              ),
            ),
            const SizedBox(height: 6),
            if (_sleepEndAt != null || _stopAfterSurah)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  _sleepEndAt != null
                      ? 'سيتوقف التشغيل في ${_formatSleepTime()}'
                      : 'سيتم الإيقاف بعد انتهاء السورة الحالية',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 11,
                    color: _inkColor.withOpacity(0.65),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(_position),
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 11,
                    color: _inkColor.withOpacity(0.6),
                  ),
                ),
                Text(
                  _formatDuration(_duration),
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 11,
                    color: _inkColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _formatSleepTime() {
    final endAt = _sleepEndAt;
    if (endAt == null) return '';
    final time =
        TimeOfDay.fromDateTime(endAt).format(context);
    return time;
  }

  Widget _buildAudioMeta(int surahNumber, String reciterId) {
    final filePath = _getDownloadedPath(surahNumber, reciterId);
    final duration = quranController.getAudioDuration(
      surahNumber,
      reciterId,
    );
    String? sizeText;
    if (filePath != null) {
      final file = File(filePath);
      if (file.existsSync()) {
        sizeText = _formatBytes(file.lengthSync());
      }
    }
    final durationText = duration == null ? null : _formatDuration(duration);
    if (sizeText == null && durationText == null) {
      return const SizedBox.shrink();
    }
    return Text(
      [
        if (sizeText != null) 'الحجم: $sizeText',
        if (durationText != null) 'المدة: $durationText',
      ].join(' • '),
      style: TextStyle(
        fontFamily: 'Amiri',
        fontSize: 11,
        color: _inkColor.withOpacity(0.65),
      ),
    );
  }

  Future<void> _checkConnection() async {
    setState(() {
      _checkingConnection = true;
    });
    try {
      final result = await InternetAddress.lookup('example.com');
      final online = result.isNotEmpty && result.first.rawAddress.isNotEmpty;
      if (!mounted) return;
      setState(() {
        _isOnline = online;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isOnline = false;
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _checkingConnection = false;
      });
    }
  }

  void _syncAudioNotification() {
    if (_currentSurahNumber == null) {
      _notificationService.cancelAudioNotification();
      return;
    }
    SurahData? surah;
    try {
      surah = quranController.surahs.firstWhere(
        (item) => item.number == _currentSurahNumber,
      );
    } catch (_) {
      surah = null;
    }
    if (surah == null) return;
    final reciterName = _selectedReciterId == null
        ? null
        : quranController.reciters[_selectedReciterId!];
    final body = reciterName == null
        ? 'سورة ${surah.name}'
        : 'سورة ${surah.name} • $reciterName';
    _notificationService.showAudioNotification(
      title: 'تلاوة القرآن',
      body: body,
      isPlaying: _isPlaying,
    );
  }

  Future<void> _handleNotificationAction(String actionId) async {
    if (actionId == 'audio_stop') {
      await _audioPlayer.stop();
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _currentSurahNumber = null;
        _position = Duration.zero;
        _duration = Duration.zero;
      });
      _syncAudioNotification();
      return;
    }

    if (actionId == 'audio_play_pause') {
      if (_currentSurahNumber == null) {
        if (_lastSurahNumber != null) {
          if (_lastReciterId != null) {
            _selectedReciterId = _lastReciterId;
          }
          await _playFromQueue(_lastSurahNumber!);
        }
        return;
      }
      try {
        if (_isPlaying) {
          await _audioPlayer.pause();
        } else {
          await _audioPlayer.resume();
        }
      } catch (e) {
        debugPrint('Notification play/pause error: $e');
      }
    }
  }

  bool _isDownloaded(int surahNumber, String? reciterId) {
    if (reciterId == null) return false;
    final path = _getDownloadedPath(surahNumber, reciterId);
    if (path == null) return false;
    return File(path).existsSync();
  }

  String? _getDownloadedPath(int surahNumber, String reciterId) {
    final key = 'audio_file_${surahNumber}_$reciterId';
    final cached = quranController.quranDataBox.get(key);
    if (cached == null) return null;
    return cached.toString();
  }

  Future<void> _downloadSurahAudio(
    QuranController controller,
    SurahData surah,
  ) async {
    if (_selectedReciterId == null) {
      Get.snackbar('تنبيه', 'يرجى اختيار القارئ أولاً');
      return;
    }

    final downloadKey = '${surah.number}_$_selectedReciterId';
    setState(() {
      _downloading.add(downloadKey);
      _downloadProgress[downloadKey] = 0;
    });

    double lastProgress = 0;
    final path = await controller.downloadAudio(
      surah.number,
      _selectedReciterId!,
      onProgress: (received, total) {
        if (total <= 0) return;
        final progress = received / total;
        if (progress - lastProgress < 0.05 && progress < 1) return;
        lastProgress = progress;
        if (!mounted) return;
        setState(() {
          _downloadProgress[downloadKey] = progress;
        });
      },
    );

    if (mounted) {
      setState(() {
        _downloading.remove(downloadKey);
        _downloadProgress.remove(downloadKey);
      });
    }

    if (path != null && path.isNotEmpty) {
      Get.snackbar('تم التحميل', 'تم حفظ السورة للاستماع بدون إنترنت');
    } else {
      Get.snackbar('خطأ', 'تعذر تحميل السورة حالياً');
    }
  }

  void _loadFavorites() {
    final surahList =
        quranController.quranSettingsBox.get('favorite_audio_surahs');
    final reciterList =
        quranController.quranSettingsBox.get('favorite_audio_reciters');
    if (surahList is List) {
      _favoriteSurahs
        ..clear()
        ..addAll(surahList.map((e) => int.tryParse(e.toString()) ?? 0));
      _favoriteSurahs.remove(0);
    }
    if (reciterList is List) {
      _favoriteReciters
        ..clear()
        ..addAll(reciterList.map((e) => e.toString()));
    }
  }

  void _persistFavorites() {
    quranController.quranSettingsBox.put(
      'favorite_audio_surahs',
      _favoriteSurahs.toList(),
    );
    quranController.quranSettingsBox.put(
      'favorite_audio_reciters',
      _favoriteReciters.toList(),
    );
  }

  void _toggleFavoriteSurah(int surahNumber) {
    setState(() {
      if (_favoriteSurahs.contains(surahNumber)) {
        _favoriteSurahs.remove(surahNumber);
      } else {
        _favoriteSurahs.add(surahNumber);
      }
    });
    _persistFavorites();
  }

  void _toggleFavoriteReciter(String reciterId) {
    setState(() {
      if (_favoriteReciters.contains(reciterId)) {
        _favoriteReciters.remove(reciterId);
      } else {
        _favoriteReciters.add(reciterId);
      }
    });
    _persistFavorites();
  }

  String _formatReciterName(String name) {
    final withArabicDigits = _toArabicDigits(name);
    final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(withArabicDigits);
    if (hasArabic) return withArabicDigits;
    return 'القارئ $withArabicDigits';
  }

  String _toArabicDigits(String input) {
    const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return input.replaceAllMapped(
      RegExp(r'\d'),
      (match) => arabicNumbers[int.parse(match.group(0)!)],
    );
  }

  String _arabicNumber(int number) {
    return _toArabicDigits(number.toString());
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 م.ب';
    final mb = bytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} م.ب';
  }

  List<MapEntry<String, String>> _filteredReciters(
    QuranController controller,
  ) {
    final entries = controller.reciters.entries.toList();
    return entries.where((entry) {
      if (_showFavoriteRecitersOnly &&
          !_favoriteReciters.contains(entry.key)) {
        return false;
      }
      if (_countryFilter == null && _riwayaFilter == null) return true;
      final meta = controller.getReciterMeta(entry.key);
      if (meta == null) return false;
      if (_countryFilter != null && meta['country'] != _countryFilter) {
        return false;
      }
      if (_riwayaFilter != null && meta['riwaya'] != _riwayaFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  List<String> _availableCountries(QuranController controller) {
    final values = <String>{};
    for (final entry in controller.reciters.entries) {
      final meta = controller.getReciterMeta(entry.key);
      final country = meta?['country'];
      if (country != null && country.isNotEmpty) {
        values.add(country);
      }
    }
    final list = values.toList()..sort();
    return list;
  }

  List<String> _availableRiwayas(QuranController controller) {
    final values = <String>{};
    for (final entry in controller.reciters.entries) {
      final meta = controller.getReciterMeta(entry.key);
      final riwaya = meta?['riwaya'];
      if (riwaya != null && riwaya.isNotEmpty) {
        values.add(riwaya);
      }
    }
    final list = values.toList()..sort();
    return list;
  }
}
