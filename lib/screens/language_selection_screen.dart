import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  static const List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'es', 'name': 'Español (Spanish)'},
    {'code': 'fr', 'name': 'Français (French)'},
    {'code': 'de', 'name': 'Deutsch (German)'},
    {'code': 'pt', 'name': 'Português (Portuguese)'},
    {'code': 'it', 'name': 'Italiano (Italian)'},
    {'code': 'nl', 'name': 'Nederlands (Dutch)'},
    {'code': 'sv', 'name': 'Svenska (Swedish)'},
    {'code': 'no', 'name': 'Norsk (Norwegian)'},
    {'code': 'da', 'name': 'Dansk (Danish)'},
    {'code': 'fi', 'name': 'Suomi (Finnish)'},
    {'code': 'pl', 'name': 'Polski (Polish)'},
    {'code': 'cs', 'name': 'Čeština (Czech)'},
    {'code': 'sk', 'name': 'Slovenčina (Slovak)'},
    {'code': 'hu', 'name': 'Magyar (Hungarian)'},
    {'code': 'ro', 'name': 'Română (Romanian)'},
    {'code': 'bg', 'name': 'Български (Bulgarian)'},
    {'code': 'ru', 'name': 'Русский (Russian)'},
    {'code': 'uk', 'name': 'Українська (Ukrainian)'},
    {'code': 'el', 'name': 'Ελληνικά (Greek)'},
    {'code': 'tr', 'name': 'Türkçe (Turkish)'},
    {'code': 'ar', 'name': 'العربية (Arabic)'},
    {'code': 'he', 'name': 'עברית (Hebrew)'},
    {'code': 'fa', 'name': 'فارسی (Persian)'},
    {'code': 'hi', 'name': 'हिन्दी (Hindi)'},
    {'code': 'bn', 'name': 'বাংলা (Bengali)'},
    {'code': 'ta', 'name': 'தமிழ் (Tamil)'},
    {'code': 'te', 'name': 'తెలుగు (Telugu)'},
    {'code': 'ml', 'name': 'മലയാളം (Malayalam)'},
    {'code': 'kn', 'name': 'ಕನ್ನಡ (Kannada)'},
    {'code': 'mr', 'name': 'मराठी (Marathi)'},
    {'code': 'gu', 'name': 'ગુજરાતી (Gujarati)'},
    {'code': 'pa', 'name': 'ਪੰਜਾਬੀ (Punjabi)'},
    {'code': 'ur', 'name': 'اردو (Urdu)'},
    {'code': 'zh', 'name': '中文 (Chinese)'},
    {'code': 'zh-Hans', 'name': '简体中文 (Chinese Simplified)'},
    {'code': 'zh-Hant', 'name': '繁體中文 (Chinese Traditional)'},
    {'code': 'ja', 'name': '日本語 (Japanese)'},
    {'code': 'ko', 'name': '한국어 (Korean)'},
    {'code': 'th', 'name': 'ไทย (Thai)'},
    {'code': 'vi', 'name': 'Tiếng Việt (Vietnamese)'},
    {'code': 'id', 'name': 'Bahasa Indonesia'},
    {'code': 'ms', 'name': 'Bahasa Melayu (Malay)'},
    {'code': 'fil', 'name': 'Filipino'},
    {'code': 'sw', 'name': 'Kiswahili (Swahili)'},
    {'code': 'am', 'name': 'አማርኛ (Amharic)'},
    {'code': 'yo', 'name': 'Yorùbá'},
    {'code': 'ig', 'name': 'Igbo'},
    {'code': 'ha', 'name': 'Hausa'},
    {'code': 'zu', 'name': 'isiZulu'},
    {'code': 'xh', 'name': 'isiXhosa'},
    {'code': 'st', 'name': 'Sesotho'},
    {'code': 'sn', 'name': 'Shona'},
    {'code': 'af', 'name': 'Afrikaans'},
    {'code': 'sr', 'name': 'Српски (Serbian)'},
    {'code': 'hr', 'name': 'Hrvatski (Croatian)'},
    {'code': 'sl', 'name': 'Slovenščina (Slovenian)'},
    {'code': 'et', 'name': 'Eesti (Estonian)'},
    {'code': 'lv', 'name': 'Latviešu (Latvian)'},
    {'code': 'lt', 'name': 'Lietuvių (Lithuanian)'},
    {'code': 'is', 'name': 'Íslenska (Icelandic)'},
    {'code': 'ga', 'name': 'Gaeilge (Irish)'},
    {'code': 'cy', 'name': 'Cymraeg (Welsh)'},
    {'code': 'mt', 'name': 'Malti (Maltese)'},
    {'code': 'sq', 'name': 'Shqip (Albanian)'},
    {'code': 'mk', 'name': 'Македонски (Macedonian)'},
    {'code': 'bs', 'name': 'Bosanski (Bosnian)'},
    {'code': 'ca', 'name': 'Català (Catalan)'},
    {'code': 'eu', 'name': 'Euskara (Basque)'},
    {'code': 'gl', 'name': 'Galego (Galician)'},
    {'code': 'fa-AF', 'name': 'دری (Dari)'},
    {'code': 'ps', 'name': 'پښتو (Pashto)'},
    {'code': 'km', 'name': 'ភាសាខ្មែរ (Khmer)'},
    {'code': 'lo', 'name': 'ລາວ (Lao)'},
    {'code': 'my', 'name': 'မြန်မာ (Burmese)'},
    {'code': 'ne', 'name': 'नेपाली (Nepali)'},
    {'code': 'si', 'name': 'සිංහල (Sinhala)'},
    {'code': 'mn', 'name': 'Монгол (Mongolian)'},
    {'code': 'kk', 'name': 'Қазақ (Kazakh)'},
    {'code': 'uz', 'name': 'O‘zbek (Uzbek)'},
    {'code': 'tt', 'name': 'Татар (Tatar)'},
    {'code': 'ky', 'name': 'Кыргызча (Kyrgyz)'},
    {'code': 'az', 'name': 'Azərbaycan (Azerbaijani)'},
    {'code': 'ka', 'name': 'ქართული (Georgian)'},
    {'code': 'hy', 'name': 'Հայերեն (Armenian)'},
    {'code': 'lv', 'name': 'Latviešu (Latvian)'},
    {'code': 'ta-LK', 'name': 'தமிழ் (Sri Lanka Tamil)'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Choose Language',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          final currentCode = settings.languageCode;

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: _languages.length + 2,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Select your preferred language for HealTrack.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                );
              }
              if (index == 1) {
                return const SizedBox(height: 4);
              }

              final language = _languages[index - 2];
              return _buildLanguageTile(
                context,
                settings,
                language['name']!,
                language['code']!,
                currentCode,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context,
    SettingsProvider settings,
    String label,
    String code,
    String currentCode,
  ) {
    final isSelected = currentCode == code;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(label),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Color(0xFF3366FF))
            : const Icon(Icons.circle_outlined, color: Colors.grey),
        onTap: () async {
          await settings.setLanguageCode(code);
        },
      ),
    );
  }
}
