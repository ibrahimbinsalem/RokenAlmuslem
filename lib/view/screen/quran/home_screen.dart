import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rokenalmuslem/controller/more/quran_controller.dart';
import 'package:rokenalmuslem/view/screen/quran/detail_screen.dart';

class SurahListPage extends StatefulWidget {
  const SurahListPage({super.key});

  @override
  State<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> {
  final QuranController quranController = Get.put(QuranController());
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  static const _pageBackground = Color(0xFFFDFBF5);
  static const _pageBorder = Color(0xFFE4D8C7);
  static const _inkColor = Color(0xFF3D2B1F);
  static const _accent = Color(0xFF8B6B4A);
  static const _softAccent = Color(0xFFEFE5D8);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        title: const Text(
          'القرآن الكريم',
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 24,
            color: _inkColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: _pageBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: _inkColor),
      ),
      body: GetX<QuranController>(builder: (controller) {
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
        }).toList();

        final lastReadSurahNumber = controller.lastReadSurahNumber.value;
        final lastReadAyah = controller.lastReadPosition.value;
        final lastReadSurah = surahs.firstWhereOrNull(
          (surah) => surah.number == lastReadSurahNumber,
        );

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(surahs.length),
            ),
            SliverToBoxAdapter(
              child: _buildSearchBar(),
            ),
            if (lastReadSurah != null && lastReadAyah > 0)
              SliverToBoxAdapter(
                child: _buildContinueCard(
                  controller,
                  lastReadSurah,
                  lastReadAyah,
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final surah = filtered[index];
                    return _buildSurahCard(controller, surah);
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(int totalSurahs) {
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _softAccent,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _pageBorder, width: 1),
            ),
            child: const Icon(Icons.menu_book, color: _accent),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'فهرس السور',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 18,
                  color: _inkColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'عدد السور: ${_arabicNumber(totalSurahs)}',
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 14,
                  color: _accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: _pageBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _pageBorder, width: 1.1),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _query = value.trim()),
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          fontFamily: 'Amiri',
          fontSize: 16,
          color: _inkColor,
        ),
        decoration: const InputDecoration(
          hintText: 'ابحث عن سورة...',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: _accent),
        ),
      ),
    );
  }

  Widget _buildContinueCard(
    QuranController controller,
    dynamic surah,
    int lastReadAyah,
  ) {
    final progress = surah.numberOfAyahs > 0
        ? lastReadAyah / surah.numberOfAyahs
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: _softAccent,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _pageBorder, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'آخر موضع قراءة',
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 16,
              color: _inkColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${surah.name} • آية ${controller.convertToArabicNumber(lastReadAyah.toString())}',
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 14,
              color: _accent,
              fontWeight: FontWeight.w600,
            ),
          ),
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
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Get.to(() => SurahDetailPage(surah: surah));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.bookmark),
            label: const Text('العودة إلى موضع الوقف'),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahCard(QuranController controller, dynamic surah) {
    return InkWell(
      onTap: () => Get.to(() => SurahDetailPage(surah: surah)),
      child: Container(
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
                      fontSize: 20,
                      color: _inkColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    surah.englishName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${surah.englishNameTranslation} • ${controller.convertToArabicNumber(surah.numberOfAyahs.toString())} آية',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 13,
                      color: _inkColor.withOpacity(0.65),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left, color: _accent),
          ],
        ),
      ),
    );
  }

  static String _arabicNumber(int number) {
    const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final digits = number.toString().split('');
    return digits.map((d) => arabicNumbers[int.parse(d)]).join();
  }
}
