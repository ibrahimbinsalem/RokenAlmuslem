import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/quran_controller.dart';
import 'package:rokenalmuslem/core/class/app_setting_mg.dart';
import 'package:rokenalmuslem/data/data/data_ayat.dart';
import 'package:rokenalmuslem/data/data/data_surat.dart';

class SurahDetailPage extends StatefulWidget {
  final SurahData surah;

  const SurahDetailPage({Key? key, required this.surah}) : super(key: key);

  @override
  _SurahDetailPageState createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  final QuranController quranController = Get.find();
  final AppSettingsController appSettings = Get.find<AppSettingsController>();
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = [];
  bool _didScrollToLastRead = false;
  bool _usePageMode = false;
  static const int _ayahsPerSection = 10;

  static const _pageBackground = Color(0xFFFDFBF5);
  static const _pageBorder = Color(0xFFE4D8C7);
  static const _inkColor = Color(0xFF3D2B1F);
  static const _accent = Color(0xFF8B6B4A);
  static const _highlight = Color(0xFFC9A36A);
  static const _softHighlight = Color(0xFFF7EFE5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint(
        'بدء تحميل آيات السورة: ${widget.surah.number} - ${widget.surah.name}',
      );
      quranController
          .loadAyahsForSurah(widget.surah)
          .catchError((e, s) {
            debugPrint(
              'خطأ أثناء تحميل آيات السورة ${widget.surah.number}: $e\n$s',
            );
          });
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
          IconButton(
            tooltip: _usePageMode ? 'عرض متصل' : 'عرض صفحات',
            onPressed: () {
              setState(() {
                _usePageMode = !_usePageMode;
              });
            },
            icon: Icon(
              _usePageMode ? Icons.view_stream : Icons.chrome_reader_mode,
              color: _inkColor,
            ),
          ),
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
          child: _usePageMode
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: _buildReaderToolbar(controller),
                    ),
                    Expanded(
                      child: PageView.builder(
                        itemCount: sections.length,
                        controller: PageController(),
                        itemBuilder: (context, pageIndex) {
                          final ayahs = sections[pageIndex];
                          final isFirst = pageIndex == 0;
                          final isSaved = _isSavedSection(controller, ayahs);
                          return SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            child: _buildSectionCard(
                              controller,
                              ayahs,
                              pageIndex,
                              isFirst,
                              isSaved,
                              isBasmalaShown,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  itemCount: sections.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildReaderToolbar(controller);
                    }

                    final sectionIndex = index - 1;
                    final ayahs = sections[sectionIndex];
                    final isFirst = sectionIndex == 0;
                    final isSaved = _isSavedSection(controller, ayahs);

                    return _buildSectionCard(
                      controller,
                      ayahs,
                      sectionIndex,
                      isFirst,
                      isSaved,
                      isBasmalaShown,
                      key: _sectionKeys[sectionIndex],
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

  Widget _buildSectionCard(
    QuranController controller,
    List<AyahData> ayahs,
    int sectionIndex,
    bool isFirst,
    bool isSaved,
    bool isBasmalaShown, {
    Key? key,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
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
          _buildSectionHeader(sectionIndex, ayahs, controller, _accent),
          const SizedBox(height: 12),
          _buildAyahBlock(ayahs, _inkColor),
        ],
      ),
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
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'يمكنك الاستماع للتلاوة من مكتبة القرآن الصوتية في صفحة الفهرس',
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 13,
                    color: _accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'أدوات القراءة',
                onPressed: () => _showReadingTools(controller),
                icon: const Icon(Icons.tune, color: _accent),
              ),
            ],
          ),
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
        TextSpan(text: '${ayah.text} ﴿$number﴾ '),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Obx(() {
        final fontScale = appSettings.fontSizeMultiplier.value;
        final lineHeight = appSettings.lineHeightMultiplier.value;
        return Text.rich(
          TextSpan(
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 24 * fontScale,
              color: inkColor,
              height: lineHeight,
              wordSpacing: 2,
            ),
            children: spans,
          ),
          textAlign: TextAlign.justify,
        );
      }),
    );
  }

  void _showReadingTools(QuranController controller) {
    if (controller.currentAyahs.isEmpty) return;
    var selectedAyahNumber =
        controller.lastReadSurahNumber.value == widget.surah.number &&
                controller.lastReadPosition.value > 0
            ? controller.lastReadPosition.value
            : 1;
    final maxAyah = controller.currentAyahs.length;
    if (selectedAyahNumber > maxAyah) {
      selectedAyahNumber = maxAyah;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: _pageBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final selectedAyah = _findAyah(controller, selectedAyahNumber);
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'أدوات القراءة',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 18,
                      color: _inkColor,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final parsed = int.tryParse(value);
                            if (parsed == null) return;
                            final bounded =
                                parsed.clamp(1, maxAyah).toInt();
                            setSheetState(() {
                              selectedAyahNumber = bounded;
                            });
                          },
                          decoration: InputDecoration(
                            hintText:
                                'رقم الآية (1 - ${quranController.convertToArabicNumber(maxAyah.toString())})',
                            hintStyle: const TextStyle(
                              fontFamily: 'Amiri',
                              color: _accent,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: _accent),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'تطبيق',
                        onPressed: () {
                          setSheetState(() {});
                        },
                        icon: const Icon(Icons.check_circle, color: _accent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (selectedAyah != null) ...[
                    Text(
                      selectedAyah.text,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 20,
                        color: _inkColor,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _accent,
                      side: const BorderSide(color: _pageBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: selectedAyah == null
                        ? null
                        : () {
                            quranController.saveLastReadPosition(
                              widget.surah.number,
                              selectedAyah.numberInSurah,
                            );
                            Navigator.of(context).pop();
                            Get.snackbar('تم الحفظ', 'تم حفظ موضع الوقف');
                          },
                    icon: const Icon(Icons.bookmark_add),
                    label: const Text('حفظ موضع الوقف'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _accent,
                      side: const BorderSide(color: _pageBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: selectedAyah == null
                        ? null
                        : () {
                            Clipboard.setData(
                              ClipboardData(text: selectedAyah.text),
                            );
                            Navigator.of(context).pop();
                            Get.snackbar('تم النسخ', 'تم نسخ الآية');
                          },
                    icon: const Icon(Icons.copy),
                    label: const Text('نسخ الآية'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  AyahData? _findAyah(QuranController controller, int numberInSurah) {
    for (final ayah in controller.currentAyahs) {
      if (ayah.numberInSurah == numberInSurah) return ayah;
    }
    return null;
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
