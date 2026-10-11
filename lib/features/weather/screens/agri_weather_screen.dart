import 'package:flutter/material.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/agri_city.dart';
import '../models/weather_models.dart';
import '../services/weather_service.dart';

class AgriWeatherScreen extends StatefulWidget {
  final bool? isUrdu;

  const AgriWeatherScreen({super.key, this.isUrdu});

  @override
  State<AgriWeatherScreen> createState() => _AgriWeatherScreenState();
}

class _AgriWeatherScreenState extends State<AgriWeatherScreen> {
  bool get _isUrdu => widget.isUrdu ?? LanguageController.instance.isUrdu;

  AgriCity _selectedCity = WeatherService.currentCity;
  bool _isLoading = true;
  AgriWeatherReport? _report;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
    });

    final report = await WeatherService.fetchWeather(
      city: _selectedCity,
      forceRefresh: forceRefresh,
    );

    if (mounted) {
      setState(() {
        _report = report;
        _selectedCity = report.city;
        _isLoading = false;
      });
    }
  }

  void _showCityPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Material(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isUrdu ? "اپنا زرعی شہر منتخب کریں" : "Select Your Agricultural City",
                    style: _isUrdu
                        ? AppTheme.urdu(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          )
                        : AppTheme.english(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Auto-Detect Live Location Action
              InkWell(
                onTap: () async {
                  Navigator.pop(context);
                  setState(() {
                    _isLoading = true;
                  });
                  final detected = await WeatherService.autoDetectLiveLocation();
                  if (detected != null) {
                    setState(() {
                      _selectedCity = detected;
                    });
                  }
                  _loadWeather(forceRefresh: true);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primaryMedium.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryDark,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.my_location_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isUrdu
                                  ? "موجودہ لائیو لوکیشن خودکار حاصل کریں"
                                  : "Auto-detect My Live Location",
                              style: _isUrdu
                                  ? AppTheme.urdu(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDark,
                                    )
                                  : AppTheme.english(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDark,
                                    ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isUrdu
                                  ? "نیٹ ورک سے آپ کے ضلع یا شہر کا لائیو موسم"
                                  : "Detect exact district & coordinates via network",
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 13,
                        color: AppColors.primaryMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Expanded(
                child: ListView.separated(
                  itemCount: AgriCity.pakistaniCities.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: AppColors.borderLight),
                  itemBuilder: (context, index) {
                    final city = AgriCity.pakistaniCities[index];
                    final isSelected = city.nameEnglish == _selectedCity.nameEnglish;

                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryDark
                              : AppColors.surfaceAlt,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.location_city_rounded,
                          size: 18,
                          color: isSelected ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                      title: Text(
                        _isUrdu ? city.nameUrdu : city.nameEnglish,
                        style: _isUrdu
                            ? AppTheme.urdu(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isSelected
                                    ? AppColors.primaryDark
                                    : AppColors.textDark,
                              )
                            : AppTheme.english(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isSelected
                                    ? AppColors.primaryDark
                                    : AppColors.textDark,
                              ),
                      ),
                      subtitle: Text(
                        "${city.province} • ${_isUrdu ? city.nameEnglish : city.nameUrdu}",
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded,
                              color: AppColors.primaryDark)
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        WeatherService.setCity(city);
                        setState(() {
                          _selectedCity = city;
                        });
                        _loadWeather(forceRefresh: true);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isUrdu ? "موسم اور زرعی ایڈوائزری" : "Agri Weather & Advisory",
              style: _isUrdu
                  ? AppTheme.urdu(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    )
                  : AppTheme.english(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
            ),
            const SizedBox(height: 2),
            InkWell(
              onTap: _showCityPicker,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_rounded,
                      size: 13, color: AppColors.primaryMedium),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _isUrdu
                          ? "${_selectedCity.nameUrdu} (تبدیل کریں ▾)"
                          : "${_selectedCity.nameEnglish} (Change ▾)",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _isUrdu
                          ? AppTheme.urdu(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryMedium,
                            )
                          : AppTheme.english(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryMedium,
                            ),
                    ),
                  ),
                  if (WeatherService.isAutoDetected) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _isUrdu ? "لائیو" : "LIVE",
                        style: const TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _loadWeather(forceRefresh: true),
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryDark),
            tooltip: _isUrdu ? "ریفریش کریں" : "Refresh Weather",
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryDark,
        onRefresh: () => _loadWeather(forceRefresh: true),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryDark),
              )
            : _report == null
                ? Center(
                    child: Text(
                      _isUrdu
                          ? "موسم کا ڈیٹا لوڈ نہ ہو سکا"
                          : "Unable to load weather data",
                      style: AppTheme.urdu(fontSize: 14),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18.0, vertical: 14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Current Live Weather Hero Card
                        _buildCurrentWeatherCard(_report!),
                        const SizedBox(height: 16),

                        // 2. Smart Agricultural Spray Advisory Card (Most Important for Farmers)
                        _buildSprayAdvisoryCard(_report!.sprayAdvisory),
                        const SizedBox(height: 16),

                        // 3. Irrigation Recommendation Card
                        _buildIrrigationCard(_report!.irrigationAdvisory),
                        const SizedBox(height: 20),

                        // 4. 24-Hour Hourly Forecast
                        Text(
                          _isUrdu
                            ? "آج کی گھنٹہ وار پیشگوئی"
                            : "Today's Hourly Forecast",
                          style: _isUrdu
                              ? AppTheme.urdu(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                )
                              : AppTheme.english(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                        ),
                        const SizedBox(height: 10),
                        _buildHourlyList(_report!.hourlyForecast),
                        const SizedBox(height: 20),

                        // 5. 7-Day Agriculture Forecast
                        Text(
                          _isUrdu
                              ? "اگلے ۷ دنوں کا زرعی موسم"
                              : "7-Day Agricultural Forecast",
                          style: _isUrdu
                              ? AppTheme.urdu(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                )
                              : AppTheme.english(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                        ),
                        const SizedBox(height: 10),
                        _buildDailyList(_report!.dailyForecast),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
      ),
    );
  }

  // --- 1. CURRENT WEATHER CARD ---
  Widget _buildCurrentWeatherCard(AgriWeatherReport report) {
    final cur = report.current;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.greenGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "${cur.temperature.round()}°",
                        style: const TextStyle(
                          fontSize: 54,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "C",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accentLime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isUrdu ? cur.conditionUrdu : cur.conditionEnglish,
                    style: _isUrdu
                        ? AppTheme.urdu(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          )
                        : AppTheme.english(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                  ),
                  Text(
                    _isUrdu
                        ? "محسوس شدہ: ${cur.feelsLike.round()}°C"
                        : "Feels like ${cur.feelsLike.round()}°C",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(cur.icon, size: 44, color: AppColors.accentGold),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Weather Metrics (Wind, Humidity, Rain)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    icon: Icons.air_rounded,
                    label: _isUrdu ? "ہوا کی رفتار" : "Wind Speed",
                    value: "${cur.windSpeed.round()} km/h",
                  ),
                ),
                Container(
                    width: 1,
                    height: 26,
                    color: Colors.white.withValues(alpha: 0.2)),
                Expanded(
                  child: _buildMetric(
                    icon: Icons.water_drop_rounded,
                    label: _isUrdu ? "نمی" : "Humidity",
                    value: "${cur.humidity}%",
                  ),
                ),
                Container(
                    width: 1,
                    height: 26,
                    color: Colors.white.withValues(alpha: 0.2)),
                Expanded(
                  child: _buildMetric(
                    icon: Icons.umbrella_rounded,
                    label: _isUrdu ? "بارش" : "Precipitation",
                    value: "${cur.precipitation} mm",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.accentLime),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ),
      ],
    );
  }

  // --- 2. SMART SPRAY ADVISORY CARD ---
  Widget _buildSprayAdvisoryCard(SprayAdvisory advisory) {
    IconData statusIcon = Icons.check_circle_rounded;
    if (advisory.status == SprayStatus.caution) {
      statusIcon = Icons.warning_amber_rounded;
    } else if (advisory.status == SprayStatus.notRecommended) {
      statusIcon = Icons.cancel_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: advisory.statusColor.withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: advisory.statusColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: advisory.statusColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: advisory.statusColor, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isUrdu ? "زرعی اسپرے ایڈوائزری" : "Crop Spray Advisory",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      _isUrdu ? advisory.titleUrdu : advisory.titleEnglish,
                      style: _isUrdu
                          ? AppTheme.urdu(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: advisory.statusColor,
                            )
                          : AppTheme.english(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: advisory.statusColor,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _isUrdu ? advisory.reasonUrdu : advisory.reasonEnglish,
            style: _isUrdu
                ? AppTheme.urdu(
                    fontSize: 11.5,
                    color: AppColors.textDark,
                    height: 1.5,
                  )
                : AppTheme.english(
                    fontSize: 12,
                    color: AppColors.textDark,
                    height: 1.4,
                  ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_filled_rounded,
                    size: 15, color: AppColors.primaryDark),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _isUrdu
                        ? "بہترین وقت: ${advisory.bestWindowUrdu}"
                        : "Best Window: ${advisory.bestWindowEnglish}",
                    style: _isUrdu
                        ? AppTheme.urdu(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          )
                        : AppTheme.english(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. IRRIGATION ADVISORY CARD ---
  Widget _buildIrrigationCard(IrrigationAdvisory advisory) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (advisory.canIrrigate
                      ? AppColors.primaryMedium
                      : AppColors.accentGold)
                  .withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.water_drop_outlined,
              color: advisory.canIrrigate
                  ? AppColors.primaryMedium
                  : AppColors.accentGold,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isUrdu ? advisory.titleUrdu : advisory.titleEnglish,
                  style: _isUrdu
                      ? AppTheme.urdu(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        )
                      : AppTheme.english(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isUrdu
                      ? advisory.descriptionUrdu
                      : advisory.descriptionEnglish,
                  style: _isUrdu
                      ? AppTheme.urdu(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          height: 1.45,
                        )
                      : AppTheme.english(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          height: 1.4,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. HOURLY FORECAST LIST ---
  Widget _buildHourlyList(List<HourlyForecastItem> list) {
    return SizedBox(
      height: 105,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = list[index];
          return Container(
            width: 72,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.hourString,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
                Icon(item.icon, size: 22, color: AppColors.primaryDark),
                Text(
                  "${item.temperature.round()}°",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                if (item.rainChance > 0)
                  Text(
                    "${item.rainChance}%",
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E88E5),
                    ),
                  )
                else
                  const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- 5. 7-DAY DAILY FORECAST LIST ---
  Widget _buildDailyList(List<DailyForecastItem> list) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: AppColors.borderLight),
        itemBuilder: (context, index) {
          final item = list[index];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 9.0),
            child: Row(
              children: [
                // 1. Day Name (Sized with ellipsis)
                SizedBox(
                  width: 65,
                  child: Text(
                    _isUrdu ? item.dayNameUrdu : item.dayNameEnglish,
                    overflow: TextOverflow.ellipsis,
                    style: _isUrdu
                        ? AppTheme.urdu(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          )
                        : AppTheme.english(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                  ),
                ),
                const SizedBox(width: 4),

                // 2. Weather Condition Icon & Text (Expanded to absorb remaining width)
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.icon, size: 17, color: AppColors.primaryDark),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          _isUrdu ? item.conditionUrdu : item.conditionEnglish,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),

                // 3. Rain chance & Min/Max Temp
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.rainChance > 20) ...[
                      const Icon(Icons.water_drop_rounded,
                          size: 10, color: Color(0xFF1E88E5)),
                      Text(
                        "${item.rainChance}% ",
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                    ],
                    Text(
                      "${item.maxTemp.round()}° / ${item.minTemp.round()}°",
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
