/// نموذج مدينة عربية بإحداثياتها.
class City {
  final String nameAr;
  final String nameEn;
  final String country;
  final double lat;
  final double lng;

  const City({
    required this.nameAr,
    required this.nameEn,
    required this.country,
    required this.lat,
    required this.lng,
  });

  @override
  String toString() => '$nameAr، $country';
}

/// 25 مدينة عربية رئيسية — تعمل بدون إنترنت (Offline-first)
const List<City> arabCities = [
  City(nameAr: 'القاهرة', nameEn: 'Cairo', country: 'مصر', lat: 30.0444, lng: 31.2357),
  City(nameAr: 'الإسكندرية', nameEn: 'Alexandria', country: 'مصر', lat: 31.2001, lng: 29.9187),
  City(nameAr: 'الرياض', nameEn: 'Riyadh', country: 'السعودية', lat: 24.7136, lng: 46.6753),
  City(nameAr: 'مكة المكرمة', nameEn: 'Makkah', country: 'السعودية', lat: 21.3891, lng: 39.8579),
  City(nameAr: 'المدينة المنورة', nameEn: 'Madinah', country: 'السعودية', lat: 24.5247, lng: 39.5692),
  City(nameAr: 'جدة', nameEn: 'Jeddah', country: 'السعودية', lat: 21.4858, lng: 39.1925),
  City(nameAr: 'دبي', nameEn: 'Dubai', country: 'الإمارات', lat: 25.2048, lng: 55.2708),
  City(nameAr: 'أبوظبي', nameEn: 'Abu Dhabi', country: 'الإمارات', lat: 24.4539, lng: 54.3773),
  City(nameAr: 'الدوحة', nameEn: 'Doha', country: 'قطر', lat: 25.2854, lng: 51.5310),
  City(nameAr: 'مدينة الكويت', nameEn: 'Kuwait City', country: 'الكويت', lat: 29.3759, lng: 47.9774),
  City(nameAr: 'المنامة', nameEn: 'Manama', country: 'البحرين', lat: 26.2285, lng: 50.5860),
  City(nameAr: 'مسقط', nameEn: 'Muscat', country: 'عُمان', lat: 23.5880, lng: 58.3829),
  City(nameAr: 'عمّان', nameEn: 'Amman', country: 'الأردن', lat: 31.9454, lng: 35.9284),
  City(nameAr: 'بيروت', nameEn: 'Beirut', country: 'لبنان', lat: 33.8938, lng: 35.5016),
  City(nameAr: 'دمشق', nameEn: 'Damascus', country: 'سوريا', lat: 33.5138, lng: 36.2765),
  City(nameAr: 'بغداد', nameEn: 'Baghdad', country: 'العراق', lat: 33.3152, lng: 44.3661),
  City(nameAr: 'القدس', nameEn: 'Jerusalem', country: 'فلسطين', lat: 31.7683, lng: 35.2137),
  City(nameAr: 'الخرطوم', nameEn: 'Khartoum', country: 'السودان', lat: 15.5007, lng: 32.5599),
  City(nameAr: 'طرابلس', nameEn: 'Tripoli', country: 'ليبيا', lat: 32.8966, lng: 13.1913),
  City(nameAr: 'تونس', nameEn: 'Tunis', country: 'تونس', lat: 36.8065, lng: 10.1815),
  City(nameAr: 'الجزائر', nameEn: 'Algiers', country: 'الجزائر', lat: 36.7538, lng: 3.0588),
  City(nameAr: 'الرباط', nameEn: 'Rabat', country: 'المغرب', lat: 34.0209, lng: -6.8416),
  City(nameAr: 'الدار البيضاء', nameEn: 'Casablanca', country: 'المغرب', lat: 33.5731, lng: -7.5898),
  City(nameAr: 'نواكشوط', nameEn: 'Nouakchott', country: 'موريتانيا', lat: 18.0858, lng: -15.9785),
  City(nameAr: 'صنعاء', nameEn: "Sanaa", country: 'اليمن', lat: 15.3694, lng: 44.1910),
];
