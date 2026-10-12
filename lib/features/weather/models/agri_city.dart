class AgriCity {
  final String nameEnglish;
  final String nameUrdu;
  final double latitude;
  final double longitude;
  final String province;

  const AgriCity({
    required this.nameEnglish,
    required this.nameUrdu,
    required this.latitude,
    required this.longitude,
    required this.province,
  });

  static const List<AgriCity> pakistaniCities = [
    AgriCity(
      nameEnglish: "Multan",
      nameUrdu: "ملتان",
      latitude: 30.1575,
      longitude: 71.5249,
      province: "Punjab",
    ),
    AgriCity(
      nameEnglish: "Bahawalpur",
      nameUrdu: "بہاولپور",
      latitude: 29.3956,
      longitude: 71.6833,
      province: "Punjab",
    ),
    AgriCity(
      nameEnglish: "Rahim Yar Khan",
      nameUrdu: "رحیم یار خان",
      latitude: 28.4212,
      longitude: 70.2989,
      province: "Punjab",
    ),
    AgriCity(
      nameEnglish: "Sahiwal",
      nameUrdu: "ساہیوال",
      latitude: 30.6682,
      longitude: 73.1114,
      province: "Punjab",
    ),
    AgriCity(
      nameEnglish: "Faisalabad",
      nameUrdu: "فیصل آباد",
      latitude: 31.4504,
      longitude: 73.1350,
      province: "Punjab",
    ),
    AgriCity(
      nameEnglish: "Lahore",
      nameUrdu: "لاہور",
      latitude: 31.5204,
      longitude: 74.3587,
      province: "Punjab",
    ),
    AgriCity(
      nameEnglish: "Sargodha",
      nameUrdu: "سرگودھا",
      latitude: 32.0836,
      longitude: 72.6711,
      province: "Punjab",
    ),
    AgriCity(
      nameEnglish: "Gujranwala",
      nameUrdu: "گوجرانوالہ",
      latitude: 32.1877,
      longitude: 74.1945,
      province: "Punjab",
    ),
    AgriCity(
      nameEnglish: "Khanewal",
      nameUrdu: "خانیوال",
      latitude: 30.3017,
      longitude: 71.9321,
      province: "Punjab",
    ),
    AgriCity(
      nameEnglish: "Vehari",
      nameUrdu: "وہاڑی",
      latitude: 30.0419,
      longitude: 72.3489,
      province: "Punjab",
    ),
    AgriCity(
      nameEnglish: "Lodhran",
      nameUrdu: "لودھراں",
      latitude: 29.5405,
      longitude: 71.6336,
      province: "Punjab",
    ),
    AgriCity(
      nameEnglish: "Muzaffargarh",
      nameUrdu: "مظفر گڑھ",
      latitude: 30.0750,
      longitude: 71.1921,
      province: "Punjab",
    ),
    AgriCity(
      nameEnglish: "Dera Ghazi Khan",
      nameUrdu: "ڈیرہ غازی خان",
      latitude: 30.0561,
      longitude: 70.6348,
      province: "Punjab",
    ),
    AgriCity(
      nameEnglish: "Jhang",
      nameUrdu: "جھنگ",
      latitude: 31.2781,
      longitude: 72.3317,
      province: "Punjab",
    ),
    AgriCity(
      nameEnglish: "Okara",
      nameUrdu: "اوکاڑہ",
      latitude: 30.8081,
      longitude: 73.4458,
      province: "Punjab",
    ),
    AgriCity(
      nameEnglish: "Pakpattan",
      nameUrdu: "پاکپتن",
      latitude: 30.3410,
      longitude: 73.3866,
      province: "Punjab",
    ),
    AgriCity(
      nameEnglish: "Sheikhupura",
      nameUrdu: "شیخوپورہ",
      latitude: 31.7131,
      longitude: 73.9783,
      province: "Punjab",
    ),
    AgriCity(
      nameEnglish: "Kasur",
      nameUrdu: "قصور",
      latitude: 31.1179,
      longitude: 74.4464,
      province: "Punjab",
    ),
    AgriCity(
      nameEnglish: "Hyderabad",
      nameUrdu: "حیدرآباد",
      latitude: 25.3960,
      longitude: 68.3578,
      province: "Sindh",
    ),
    AgriCity(
      nameEnglish: "Sukkur",
      nameUrdu: "سکھر",
      latitude: 27.7052,
      longitude: 68.8574,
      province: "Sindh",
    ),
    AgriCity(
      nameEnglish: "Larkana",
      nameUrdu: "لاڑکانہ",
      latitude: 27.5590,
      longitude: 68.2120,
      province: "Sindh",
    ),
    AgriCity(
      nameEnglish: "Mirpur Khas",
      nameUrdu: "میرپور خاص",
      latitude: 25.5276,
      longitude: 69.0125,
      province: "Sindh",
    ),
    AgriCity(
      nameEnglish: "Peshawar",
      nameUrdu: "پشاور",
      latitude: 34.0151,
      longitude: 71.5249,
      province: "KPK",
    ),
    AgriCity(
      nameEnglish: "Mardan",
      nameUrdu: "مردان",
      latitude: 34.1989,
      longitude: 72.0404,
      province: "KPK",
    ),
    AgriCity(
      nameEnglish: "Quetta",
      nameUrdu: "کوئٹہ",
      latitude: 30.1798,
      longitude: 66.9750,
      province: "Balochistan",
    ),
    AgriCity(
      nameEnglish: "Islamabad / Rawalpindi",
      nameUrdu: "اسلام آباد / راولپنڈی",
      latitude: 33.6844,
      longitude: 73.0479,
      province: "Federal / Punjab",
    ),
    AgriCity(
      nameEnglish: "Taxila",
      nameUrdu: "ٹیکسلا",
      latitude: 33.7460,
      longitude: 72.8397,
      province: "Punjab",
    ),
    AgriCity(
      nameEnglish: "Wah Cantt",
      nameUrdu: "واہ کینٹ",
      latitude: 33.7715,
      longitude: 72.7511,
      province: "Punjab",
    ),
    AgriCity(
      nameEnglish: "Fateh Jang",
      nameUrdu: "فتح جنگ",
      latitude: 33.5649,
      longitude: 72.6428,
      province: "Punjab",
    ),
  ];

  static AgriCity get defaultCity => pakistaniCities.first; // Multan
}
