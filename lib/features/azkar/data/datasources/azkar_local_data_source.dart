import '../../domain/entities/entities.dart';

/// Static local data source for Azkar categories and their contents.
///
/// Contains authentic Morning (أذكار الصباح) and Evening (أذكار المساء)
/// azkar with accurate Arabic texts and repetition targets.
abstract final class AzkarLocalDataSource {
  // ─── Categories ──────────────────────────────────────────────────────────────

  static const List<AzkarCategoryEntity> categories = [
    AzkarCategoryEntity(
      id: 'morning',
      title: 'أذكار الصباح',
      icon: 'wb_sunny',
      description: 'أذكار ما بعد صلاة الفجر حتى الشروق',
    ),
    AzkarCategoryEntity(
      id: 'evening',
      title: 'أذكار المساء',
      icon: 'nights_stay',
      description: 'أذكار ما بعد صلاة العصر حتى المغرب',
    ),
    AzkarCategoryEntity(
      id: 'sleep',
      title: 'أذكار النوم',
      icon: 'bedtime',
      description: 'أذكار قبل النوم',
    ),
    AzkarCategoryEntity(
      id: 'prayer',
      title: 'أذكار بعد الصلاة',
      icon: 'mosque',
      description: 'أذكار ما بعد الصلوات المفروضة',
    ),
  ];

  // ─── Morning Azkar (أذكار الصباح) ───────────────────────────────────────────

  static const List<ZekrEntity> _morningAzkar = [
    ZekrEntity(
      id: 'morning_1',
      categoryId: 'morning',
      text: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، '
          'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ '
          'وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      count: 1,
      description: 'من قالها حين يصبح فقد أدى شكر يومه',
    ),
    ZekrEntity(
      id: 'morning_2',
      categoryId: 'morning',
      text: 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ '
          'نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
      count: 1,
    ),
    ZekrEntity(
      id: 'morning_3',
      categoryId: 'morning',
      text: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي '
          'وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، '
          'أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ '
          'عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ '
          'الذُّنُوبَ إِلَّا أَنْتَ',
      count: 1,
      description: 'سيد الاستغفار - من قالها موقناً بها فمات من يومه دخل الجنة',
    ),
    ZekrEntity(
      id: 'morning_4',
      categoryId: 'morning',
      text: 'اللَّهُمَّ إِنِّي أَصْبَحْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ '
          'عَرْشِكَ، وَمَلَائِكَتَكَ، وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ '
          'اللهُ لَا إِلَهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيكَ لَكَ، '
          'وَأَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُولُكَ',
      count: 4,
      description: 'من قالها أربع مرات أعتقه الله من النار',
    ),
    ZekrEntity(
      id: 'morning_5',
      categoryId: 'morning',
      text: 'اللَّهُمَّ مَا أَصْبَحَ بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ '
          'خَلْقِكَ فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ '
          'وَلَكَ الشُّكْرُ',
      count: 1,
      description: 'من قالها حين يصبح فقد أدى شكر يومه',
    ),
    ZekrEntity(
      id: 'morning_6',
      categoryId: 'morning',
      text: 'حَسْبِيَ اللهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ '
          'وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
      count: 7,
      description: 'من قالها كفاه الله ما أهمه من أمر الدنيا والآخرة',
    ),
    ZekrEntity(
      id: 'morning_7',
      categoryId: 'morning',
      text: 'بِسْمِ اللهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي '
          'الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
      count: 3,
      description: 'لم يضره من الله شيء',
    ),
    ZekrEntity(
      id: 'morning_8',
      categoryId: 'morning',
      text: 'رَضِيتُ بِاللهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، '
          'وَبِمُحَمَّدٍ ﷺ نَبِيًّا',
      count: 3,
      description: 'كان حقاً على الله أن يرضيه يوم القيامة',
    ),
    ZekrEntity(
      id: 'morning_9',
      categoryId: 'morning',
      text: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ '
          'لِي شَأْنِي كُلَّهُ، وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ',
      count: 1,
    ),
    ZekrEntity(
      id: 'morning_10',
      categoryId: 'morning',
      text: 'أَعُوذُ بِكَلِمَاتِ اللهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      count: 3,
      description: 'لم يضره شيء من الحيات والعقارب',
    ),
    ZekrEntity(
      id: 'morning_11',
      categoryId: 'morning',
      text: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
      count: 100,
      description: 'حُطَّت خطاياه وإن كانت مثل زبد البحر',
    ),
    ZekrEntity(
      id: 'morning_12',
      categoryId: 'morning',
      text: 'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ '
          'الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      count: 10,
      description: 'كانت له عدل عشر رقاب، وكتبت له مئة حسنة',
    ),
    ZekrEntity(
      id: 'morning_13',
      categoryId: 'morning',
      text: 'سُبْحَانَ اللهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَهَ إِلَّا اللهُ '
          'وَاللهُ أَكْبَرُ',
      count: 100,
      description: 'أحب الكلام إلى الله',
    ),
    ZekrEntity(
      id: 'morning_14',
      categoryId: 'morning',
      text: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
      count: 10,
    ),
    ZekrEntity(
      id: 'morning_15',
      categoryId: 'morning',
      text: 'أَسْتَغْفِرُ اللهَ وَأَتُوبُ إِلَيْهِ',
      count: 100,
      description: 'من قالها غفرت ذنوبه وإن كان فر من الزحف',
    ),
  ];

  // ─── Evening Azkar (أذكار المساء) ───────────────────────────────────────────

  static const List<ZekrEntity> _eveningAzkar = [
    ZekrEntity(
      id: 'evening_1',
      categoryId: 'evening',
      text: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، '
          'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ '
          'وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      count: 1,
      description: 'من قالها حين يمسي فقد أدى شكر يومه',
    ),
    ZekrEntity(
      id: 'evening_2',
      categoryId: 'evening',
      text: 'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ '
          'نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ',
      count: 1,
    ),
    ZekrEntity(
      id: 'evening_3',
      categoryId: 'evening',
      text: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي '
          'وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، '
          'أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ '
          'عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ '
          'الذُّنُوبَ إِلَّا أَنْتَ',
      count: 1,
      description: 'سيد الاستغفار - من قالها موقناً بها فمات من ليلته دخل الجنة',
    ),
    ZekrEntity(
      id: 'evening_4',
      categoryId: 'evening',
      text: 'اللَّهُمَّ إِنِّي أَمْسَيْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ '
          'عَرْشِكَ، وَمَلَائِكَتَكَ، وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ '
          'اللهُ لَا إِلَهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيكَ لَكَ، '
          'وَأَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُولُكَ',
      count: 4,
      description: 'من قالها أربع مرات أعتقه الله من النار',
    ),
    ZekrEntity(
      id: 'evening_5',
      categoryId: 'evening',
      text: 'اللَّهُمَّ مَا أَمْسَى بِي مِنْ نِعْمَةٍ أَوْ بِأَحَدٍ مِنْ '
          'خَلْقِكَ فَمِنْكَ وَحْدَكَ لَا شَرِيكَ لَكَ، فَلَكَ الْحَمْدُ '
          'وَلَكَ الشُّكْرُ',
      count: 1,
      description: 'من قالها حين يمسي فقد أدى شكر يومه',
    ),
    ZekrEntity(
      id: 'evening_6',
      categoryId: 'evening',
      text: 'حَسْبِيَ اللهُ لَا إِلَهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ '
          'وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
      count: 7,
      description: 'من قالها كفاه الله ما أهمه من أمر الدنيا والآخرة',
    ),
    ZekrEntity(
      id: 'evening_7',
      categoryId: 'evening',
      text: 'بِسْمِ اللهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي '
          'الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
      count: 3,
      description: 'لم يضره من الله شيء',
    ),
    ZekrEntity(
      id: 'evening_8',
      categoryId: 'evening',
      text: 'رَضِيتُ بِاللهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، '
          'وَبِمُحَمَّدٍ ﷺ نَبِيًّا',
      count: 3,
      description: 'كان حقاً على الله أن يرضيه يوم القيامة',
    ),
    ZekrEntity(
      id: 'evening_9',
      categoryId: 'evening',
      text: 'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ '
          'لِي شَأْنِي كُلَّهُ، وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ',
      count: 1,
    ),
    ZekrEntity(
      id: 'evening_10',
      categoryId: 'evening',
      text: 'أَعُوذُ بِكَلِمَاتِ اللهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      count: 3,
      description: 'لم يضره شيء من الحيات والعقارب',
    ),
    ZekrEntity(
      id: 'evening_11',
      categoryId: 'evening',
      text: 'سُبْحَانَ اللهِ وَبِحَمْدِهِ',
      count: 100,
      description: 'حُطَّت خطاياه وإن كانت مثل زبد البحر',
    ),
    ZekrEntity(
      id: 'evening_12',
      categoryId: 'evening',
      text: 'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ '
          'الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      count: 10,
      description: 'كانت له عدل عشر رقاب، وكتبت له مئة حسنة',
    ),
    ZekrEntity(
      id: 'evening_13',
      categoryId: 'evening',
      text: 'سُبْحَانَ اللهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَهَ إِلَّا اللهُ '
          'وَاللهُ أَكْبَرُ',
      count: 100,
      description: 'أحب الكلام إلى الله',
    ),
    ZekrEntity(
      id: 'evening_14',
      categoryId: 'evening',
      text: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
      count: 10,
    ),
    ZekrEntity(
      id: 'evening_15',
      categoryId: 'evening',
      text: 'أَسْتَغْفِرُ اللهَ وَأَتُوبُ إِلَيْهِ',
      count: 100,
      description: 'من قالها غفرت ذنوبه وإن كان فر من الزحف',
    ),
  ];

  // ─── Sleep Azkar (أذكار النوم) ──────────────────────────────────────────────

  static const List<ZekrEntity> _sleepAzkar = [
    ZekrEntity(
      id: 'sleep_1',
      categoryId: 'sleep',
      text: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      count: 1,
    ),
    ZekrEntity(
      id: 'sleep_2',
      categoryId: 'sleep',
      text: 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
      count: 3,
    ),
    ZekrEntity(
      id: 'sleep_3',
      categoryId: 'sleep',
      text: 'سُبْحَانَ اللهِ',
      count: 33,
    ),
    ZekrEntity(
      id: 'sleep_4',
      categoryId: 'sleep',
      text: 'الْحَمْدُ لِلَّهِ',
      count: 33,
    ),
    ZekrEntity(
      id: 'sleep_5',
      categoryId: 'sleep',
      text: 'اللهُ أَكْبَرُ',
      count: 34,
    ),
    ZekrEntity(
      id: 'sleep_6',
      categoryId: 'sleep',
      text: 'اللَّهُمَّ أَسْلَمْتُ نَفْسِي إِلَيْكَ، وَفَوَّضْتُ أَمْرِي '
          'إِلَيْكَ، وَوَجَّهْتُ وَجْهِي إِلَيْكَ، وَأَلْجَأْتُ ظَهْرِي '
          'إِلَيْكَ، رَغْبَةً وَرَهْبَةً إِلَيْكَ، لَا مَلْجَأَ وَلَا '
          'مَنْجَا مِنْكَ إِلَّا إِلَيْكَ',
      count: 1,
    ),
    ZekrEntity(
      id: 'sleep_7',
      categoryId: 'sleep',
      text: 'بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي، وَبِكَ أَرْفَعُهُ، '
          'فَإِنْ أَمْسَكْتَ نَفْسِي فَارْحَمْهَا، وَإِنْ أَرْسَلْتَهَا '
          'فَاحْفَظْهَا بِمَا تَحْفَظُ بِهِ عِبَادَكَ الصَّالِحِينَ',
      count: 1,
    ),
    ZekrEntity(
      id: 'sleep_8',
      categoryId: 'sleep',
      text: 'آمَنَ الرَّسُولُ بِمَا أُنْزِلَ إِلَيْهِ مِنْ رَبِّهِ '
          'وَالْمُؤْمِنُونَ... (آخر سورة البقرة)',
      count: 1,
      description: 'من قرأها في ليلة كفتاه',
    ),
  ];

  // ─── Post-Prayer Azkar (أذكار بعد الصلاة) ───────────────────────────────────

  static const List<ZekrEntity> _prayerAzkar = [
    ZekrEntity(
      id: 'prayer_1',
      categoryId: 'prayer',
      text: 'أَسْتَغْفِرُ اللهَ',
      count: 3,
    ),
    ZekrEntity(
      id: 'prayer_2',
      categoryId: 'prayer',
      text: 'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ، تَبَارَكْتَ '
          'يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
      count: 1,
    ),
    ZekrEntity(
      id: 'prayer_3',
      categoryId: 'prayer',
      text: 'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ '
          'الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، '
          'اللَّهُمَّ لَا مَانِعَ لِمَا أَعْطَيْتَ، وَلَا مُعْطِيَ لِمَا '
          'مَنَعْتَ، وَلَا يَنْفَعُ ذَا الْجَدِّ مِنْكَ الْجَدُّ',
      count: 1,
    ),
    ZekrEntity(
      id: 'prayer_4',
      categoryId: 'prayer',
      text: 'سُبْحَانَ اللهِ',
      count: 33,
    ),
    ZekrEntity(
      id: 'prayer_5',
      categoryId: 'prayer',
      text: 'الْحَمْدُ لِلَّهِ',
      count: 33,
    ),
    ZekrEntity(
      id: 'prayer_6',
      categoryId: 'prayer',
      text: 'اللهُ أَكْبَرُ',
      count: 33,
    ),
    ZekrEntity(
      id: 'prayer_7',
      categoryId: 'prayer',
      text: 'لَا إِلَهَ إِلَّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ '
          'الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      count: 1,
      description: 'من قالها بعد كل صلاة غفرت خطاياه وإن كانت مثل زبد البحر',
    ),
    ZekrEntity(
      id: 'prayer_8',
      categoryId: 'prayer',
      text: 'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
      count: 1,
    ),
  ];

  // ─── Lookup ─────────────────────────────────────────────────────────────────

  /// Returns all azkar for a given [categoryId].
  static List<ZekrEntity> azkarFor(String categoryId) {
    switch (categoryId) {
      case 'morning':
        return _morningAzkar;
      case 'evening':
        return _eveningAzkar;
      case 'sleep':
        return _sleepAzkar;
      case 'prayer':
        return _prayerAzkar;
      default:
        return const [];
    }
  }
}