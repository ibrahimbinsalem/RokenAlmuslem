import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/quran_controller.dart';
import 'package:rokenalmuslem/data/data/data_ayat.dart';
import 'package:rokenalmuslem/data/data/data_surat.dart';
import 'dart:math';

class SurahDetailPage extends StatefulWidget {
  final SurahData surah;

  const SurahDetailPage({Key? key, required this.surah}) : super(key: key);

  @override
  _SurahDetailPageState createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  final QuranController quranController = Get.find();
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = [];
  bool _didScrollToLastRead = false;
  static const int _ayahsPerSection = 10;

  static const _pageBackground = Color(0xFFFDFBF5);
  static const _pageBorder = Color(0xFFE4D8C7);
  static const _inkColor = Color(0xFF3D2B1F);
  static const _accent = Color(0xFF8B6B4A);
  static const _highlight = Color(0xFFC9A36A);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      quranController.loadAyahsForSurah(widget.surah);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBasmalaShown = widget.surah.number != 9;
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        title: Text(
          widget.surah.name,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 22,
            color: _inkColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: _pageBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: _inkColor),
        actions: [
          GetX<QuranController>(
            builder: (controller) {
              final hasLastRead =
                  controller.lastReadSurahNumber.value == widget.surah.number &&
                  controller.lastReadPosition.value > 0;
              return IconButton(
                tooltip: 'متابعة القراءة',
                onPressed:
                    hasLastRead
                        ? () => _scrollToLastRead(controller, force: true)
                        : null,
                icon: const Icon(Icons.bookmark, color: _inkColor),
              );
            },
          ),
        ],
      ),
      floatingActionButton: GetX<QuranController>(
        builder: (controller) {
          final hasLastRead =
              controller.lastReadSurahNumber.value == widget.surah.number &&
              controller.lastReadPosition.value > 0;
          if (!hasLastRead) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            backgroundColor: _accent,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.bookmark),
            label: const Text('العودة لآخر موضع'),
            onPressed: () => _scrollToLastRead(controller, force: true),
          );
        },
      ),
      body: GetX<QuranController>(builder: (controller) {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.currentAyahs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning, size: 48, color: Colors.amber),
                SizedBox(height: 16),
                Text('لا توجد آيات متاحة', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => controller.loadAyahsForSurah(widget.surah),
                  child: Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        final sections = _splitAyahs(controller.currentAyahs);
        _ensureSectionKeys(sections.length);
        _scrollToLastRead(controller);

        return Container(
          color: _pageBackground,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            itemCount: sections.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildReaderToolbar(controller);
              }

              final sectionIndex = index - 1;
              final ayahs = sections[sectionIndex];
              final isFirst = sectionIndex == 0;
              final isSaved = _isSavedSection(controller, ayahs);

              return Container(
                key: _sectionKeys[sectionIndex],
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: _pageBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSaved ? _highlight : _pageBorder,
                    width: isSaved ? 1.6 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isFirst) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: _pageBorder, width: 1),
                            bottom: BorderSide(color: _pageBorder, width: 1),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            widget.surah.name,
                            style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 30,
                              color: _accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      if (isBasmalaShown) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 24,
                            color: _accent,
                            height: 1.8,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                    ],
                    _buildSectionHeader(
                      sectionIndex,
                      ayahs,
                      controller,
                      _accent,
                    ),
                    const SizedBox(height: 12),
                    _buildAyahBlock(ayahs, _inkColor),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(
    int index,
    List<AyahData> ayahs,
    QuranController controller,
    Color accent,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'المقطع ${quranController.convertToArabicNumber((index + 1).toString())}',
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 18,
            color: accent,
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton.icon(
          onPressed: () {
            controller.saveLastReadPosition(
              widget.surah.number,
              ayahs.first.numberInSurah,
            );
            Get.snackbar('تم الحفظ', 'تم حفظ آخر موضع للقراءة');
          },
          icon: const Icon(Icons.bookmark_add, size: 18),
          label: const Text('حفظ الموضع'),
          style: TextButton.styleFrom(
            foregroundColor: accent,
            textStyle: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReaderToolbar(QuranController controller) {
    final lastReadSurah = controller.lastReadSurahNumber.value;
    final lastReadAyah = controller.lastReadPosition.value;
    final hasLastRead =
        lastReadSurah == widget.surah.number && lastReadAyah > 0;
    final progress = hasLastRead && widget.surah.numberOfAyahs > 0
        ? lastReadAyah / widget.surah.numberOfAyahs
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: _pageBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _pageBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hasLastRead
                    ? 'آخر موضع: آية ${quranController.convertToArabicNumber(lastReadAyah.toString())}'
                    : 'ابدأ القراءة براحة وطمأنينة',
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 16,
                  color: _inkColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasLastRead)
                TextButton(
                  onPressed: () => _scrollToLastRead(controller, force: true),
                  style: TextButton.styleFrom(
                    foregroundColor: _accent,
                    textStyle: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('العودة للوقف'),
                ),
            ],
          ),
          if (hasLastRead) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 6,
                backgroundColor: _pageBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(_accent),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAyahBlock(List<AyahData> ayahs, Color inkColor) {
    final spans = <TextSpan>[];
    for (final ayah in ayahs) {
      final number = quranController.convertToArabicNumber(
        ayah.numberInSurah.toString(),
      );
      spans.add(
        TextSpan(
          text: '${ayah.text} ﴿$number﴾ ',
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Text.rich(
        TextSpan(
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 24,
            color: inkColor,
            height: 1.9,
            wordSpacing: 2,
          ),
          children: spans,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  List<List<AyahData>> _splitAyahs(List<AyahData> ayahs) {
    if (ayahs.isEmpty) return [];
    final sections = <List<AyahData>>[];
    for (var i = 0; i < ayahs.length; i += _ayahsPerSection) {
      sections.add(
        ayahs.sublist(i, min(i + _ayahsPerSection, ayahs.length)),
      );
    }
    return sections;
  }

  void _ensureSectionKeys(int count) {
    if (_sectionKeys.length == count) return;
    _sectionKeys
      ..clear()
      ..addAll(List.generate(count, (_) => GlobalKey()));
  }

  bool _isSavedSection(QuranController controller, List<AyahData> ayahs) {
    if (controller.lastReadSurahNumber.value != widget.surah.number) {
      return false;
    }
    final lastRead = controller.lastReadPosition.value;
    if (lastRead == 0) return false;
    final first = ayahs.first.numberInSurah;
    final last = ayahs.last.numberInSurah;
    return lastRead >= first && lastRead <= last;
  }

  void _scrollToLastRead(QuranController controller, {bool force = false}) {
    if (_didScrollToLastRead && !force) return;
    final lastReadSurah = controller.lastReadSurahNumber.value;
    final lastReadAyah = controller.lastReadPosition.value;
    if (lastReadSurah != widget.surah.number || lastReadAyah == 0) {
      _didScrollToLastRead = true;
      return;
    }

    final sectionIndex = (lastReadAyah - 1) ~/ _ayahsPerSection;
    if (sectionIndex < 0 || sectionIndex >= _sectionKeys.length) {
      _didScrollToLastRead = true;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _sectionKeys[sectionIndex].currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 450),
          alignment: 0.1,
          curve: Curves.easeOutCubic,
        );
      }
    });
    _didScrollToLastRead = true;
  }
}
