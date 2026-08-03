/// A local structured data source for Tafseer (التفسير الميسر) and
/// word meanings (معاني الكلمات).
///
/// In a production app this would be backed by a JSON asset or database;
/// here it uses an in-memory map keyed by surah number for instant access
/// with zero network dependency.
class TafseerLocalDataSource {
  const TafseerLocalDataSource._();

  /// Returns the easy explanation (التفسير الميسر) for [surahNumber].
  ///
  /// Falls back to a generic introduction when no curated entry exists.
  static String tafseerForSurah(int surahNumber) {
    return _tafseer[surahNumber] ?? _genericTafseer(surahNumber);
  }

  /// Returns a map of key-word meanings (معاني الكلمات) for [surahNumber].
  ///
  /// Each entry maps an Arabic word/phrase to its concise meaning.
  static Map<String, String> wordMeaningsForSurah(int surahNumber) {
    return _wordMeanings[surahNumber] ?? const {};
  }

  /// Curated easy tafseer for key surahs (مختصر التفسير).
  static const Map<int, String> _tafseer = {
    1: 'سورة الفاتحة: تفتتح القرآن الكريم، وفيها يُثني العبد على ربه '
        'ويطلب منه الهداية إلى الصراط المستقيم، صراط الذين أنعم الله عليهم '
        'من النبيين والصديقين والشهداء والصالحين، لا صراط المغضوب عليهم ولا الضالين. '
        'وهي أعظم سورة في القرآن، وتُقرأ في كل ركعة من الصلاة.',
    2: 'سورة البقرة: أطول سور القرآن، وتشتمل على أحكام الشريعة وأصول الإيمان '
        'وقصة بني إسرائيل، وأعظم آية فيها آية الكرسي التي وصف الله بها نفسه '
        'بصفات الكمال، وتختم السورة بآيتين من كنوز العرش.',
    36: 'سورة يس: تُسمى قلب القرآن، وتتناول الدعوة إلى التوحيد والبعث '
        'والجزاء، وقصص أهل القرية الذين كذبوا المرسلين، وتبشّر المؤمنين بالجنة.',
    55: 'سورة الرحمن: تفتتح بذكر نعمة تعليم القرآن، ثم تعدد نِعَم الله الظاهرة '
        'والباطنة على عباده في الدنيا والآخرة، وتخاطب الجن والإنس بـ"فبأي '
        'آلاء ربكما تكذبان".',
    67: 'سورة الملك: تثبت كمال قدرة الله في ملكه وتدبيره، وتنفي أن يكون '
        'له شريك في الملك، وتبيّن عاقبة المكذبين والعذاب الذي ينتظرهم، '
        'وتُشفع لصاحبها يوم القيامة.',
    112: 'سورة الإخلاص: تعدل ثلث القرآن، وهي قاعدة التوحيد الخالص؛ '
        'تثبت وحدانية الله تعالى، واستغناؤه عن كل ما سواه، وأنه لم يلد ولم يُولد '
        'ولم يكن له كفؤاً أحد.',
    113: 'سورة الفلق: تدعو إلى الاستعاذة بالله رب الفلق من شر جميع المخلوقات، '
        'ومن شر الليل إذا وقب، ومن شر النفاثات في العقد، ومن شر حاسد إذا حسد.',
    114: 'سورة الناس: تدعو إلى الاستعاذة بالله ملك الناس وإله الناس من شر '
        'الوسواس الخناس الذي يوسوس في صدور الناس، من الجنة والناس.',
  };

  /// Curated key-word meanings for common surahs.
  static const Map<int, Map<String, String>> _wordMeanings = {
    1: {
      'الحمد': 'الثناء والمدح',
      'العالمين': 'جميع المخلوقات',
      'الرحمن': 'ذو الرحمة الواسعة',
      'الرحيم': 'ذو الرحمة الدائمة',
      'الصراط': 'الطريق الواضح',
      'المستقيم': 'المعتدل القويم',
      'المغضوب عليهم': 'الذين غضب الله عليهم',
      'الضالين': 'الذين انحرفوا عن الحق',
    },
    112: {
      'أحد': 'واحد لا نظير له',
      'الصمد': 'المقصود في الحوائج',
      'لم يلد': 'ليس له ولد',
      'ولم يولد': 'لم يولد من أحد',
      'كفواً': 'مثلاً أو نظيراً',
    },
  };

  /// A generic intro tafseer for surahs without a curated entry.
  static String _genericTafseer(int surahNumber) {
    return 'سورة رقم $surahNumber: من سور القرآن الكريم. يُستحب قراءتها '
        'بتدبر وتفكر في معانيها، والعمل بما فيها من أحكام وتوجيهات.';
  }
}