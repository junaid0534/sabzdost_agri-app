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
        titleSpacing: 18,
        title: Text(
          _isUrdu ? "موسم" : "Weather",
          style: _isUrdu
              ? AppTheme.urdu(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                )
              : AppTheme.english(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: InkWell(
              onTap: _showCityPicker,
              borderRadius: BorderRadius.circular(22),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.primaryMedium.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: AppColors.primaryMedium,
                    ),
                    const SizedBox(width: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 110),
                      child: Text(
                        _isUrdu ? _selectedCity.nameUrdu : _selectedCity.nameEnglish,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _isUrdu
                            ? AppTheme.urdu(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              )
                            : AppTheme.english(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: AppColors.primaryMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
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
                        // 1. Current Live Weather Hero Card (Compact)
                        _buildCurrentWeatherCard(_report!),
                        const SizedBox(height: 12),

                        // 2. Smart Agricultural Spray Advisory Card (Concise)
                        _buildSprayAdvisoryCard(_report!.sprayAdvisory),
                        const SizedBox(height: 12),

                        // 3. Irrigation Recommendation Card (Compact)
                        _buildIrrigationCard(_report!.irrigationAdvisory),
                        const SizedBox(height: 16),

                        // 4. Hourly Forecast
                        Text(
                          _isUrdu ? "گھنٹہ وار پیشگوئی" : "Hourly Forecast",
                          style: _isUrdu
                              ? AppTheme.urdu(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                )
                              : AppTheme.english(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                        ),
                        const SizedBox(height: 8),
                        _buildHourlyList(_report!.hourlyForecast),
                        const SizedBox(height: 16),

                        // 5. 7-Day Agriculture Forecast
                        Text(
                          _isUrdu ? "۷ روزہ زرعی موسم" : "7-Day Agri Forecast",
                          style: _isUrdu
                              ? AppTheme.urdu(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                )
                              : AppTheme.english(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark,
                                ),
                        ),
                        const SizedBox(height: 8),
                        _buildDailyList(_report!.dailyForecast),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
      ),
    );
  }

  // --- 1. COMPACT CURRENT WEATHER HERO CARD ---
  Widget _buildCurrentWeatherCard(AgriWeatherReport report) {
    final cur = report.current;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: AppColors.freshLeafGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryMedium.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Temperature + Condition & Feels like (Left) & Weather Icon (Right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "${cur.temperature.round()}°",
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _isUrdu ? cur.conditionUrdu : cur.conditionEnglish,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: _isUrdu
                                ? AppTheme.urdu(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  )
                                : AppTheme.english(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isUrdu
                                ? "محسوس: ${cur.feelsLike.round()}°C"
                                : "Feels ${cur.feelsLike.round()}°C",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(cur.icon, size: 30, color: AppColors.accentGold),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Weather Metrics (Wind, Humidity, Rain) - Sleek & Compact
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    icon: Icons.air_rounded,
                    label: _isUrdu ? "ہوا" : "Wind",
                    value: "${cur.windSpeed.round()} km/h",
                  ),
                ),
                Container(
                    width: 1,
                    height: 20,
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
                    height: 20,
                    color: Colors.white.withValues(alpha: 0.2)),
                Expanded(
                  child: _buildMetric(
                    icon: Icons.umbrella_rounded,
                    label: _isUrdu ? "بارش" : "Rain",
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
        Icon(icon, size: 16, color: AppColors.accentLime),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 1),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
        ),
      ],
    );
  }

  // --- 2. SMART SPRAY ADVISORY CARD (Concise & Professional) ---
  Widget _buildSprayAdvisoryCard(SprayAdvisory advisory) {
    IconData statusIcon = Icons.check_circle_rounded;
    if (advisory.status == SprayStatus.caution) {
      statusIcon = Icons.warning_amber_rounded;
    } else if (advisory.status == SprayStatus.notRecommended) {
      statusIcon = Icons.cancel_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: advisory.statusColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: advisory.statusColor.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: advisory.statusColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: advisory.statusColor, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isUrdu ? advisory.titleUrdu : advisory.titleEnglish,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _isUrdu
                      ? AppTheme.urdu(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: advisory.statusColor,
                        )
                      : AppTheme.english(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: advisory.statusColor,
                        ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: advisory.statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _isUrdu
                      ? (advisory.status == SprayStatus.optimal
                          ? "موزوں"
                          : advisory.status == SprayStatus.caution
                              ? "احتیاط"
                              : "روک دیں")
                      : (advisory.status == SprayStatus.optimal
                          ? "Ideal"
                          : advisory.status == SprayStatus.caution
                              ? "Caution"
                              : "Avoid"),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: advisory.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _isUrdu ? advisory.reasonUrdu : advisory.reasonEnglish,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: _isUrdu
                ? AppTheme.urdu(
                    fontSize: 11,
                    color: AppColors.textDark,
                    height: 1.4,
                  )
                : AppTheme.english(
                    fontSize: 11.5,
                    color: AppColors.textDark,
                    height: 1.35,
                  ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time_filled_rounded,
                    size: 13, color: AppColors.primaryDark),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    _isUrdu
                        ? "وقت: ${advisory.bestWindowUrdu}"
                        : "Timing: ${advisory.bestWindowEnglish}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _isUrdu
                        ? AppTheme.urdu(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          )
                        : AppTheme.english(
                            fontSize: 10.5,
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

  // --- 3. IRRIGATION ADVISORY CARD (Compact & Clean) ---
  Widget _buildIrrigationCard(IrrigationAdvisory advisory) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
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
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isUrdu ? advisory.titleUrdu : advisory.titleEnglish,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _isUrdu
                      ? AppTheme.urdu(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        )
                      : AppTheme.english(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isUrdu
                      ? advisory.descriptionUrdu
                      : advisory.descriptionEnglish,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _isUrdu
                      ? AppTheme.urdu(
                          fontSize: 10.5,
                          color: AppColors.textMuted,
                        )
                      : AppTheme.english(
                          fontSize: 10.5,
                          color: AppColors.textMuted,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. HOURLY FORECAST LIST (Sleek 82px Height) ---
  Widget _buildHourlyList(List<HourlyForecastItem> list) {
    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = list[index];
          return Container(
            width: 58,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  item.hourString,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
                Icon(item.icon, size: 19, color: AppColors.primaryDark),
                Text(
                  "${item.temperature.round()}°",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                if (item.rainChance > 15)
                  Text(
                    "${item.rainChance}%",
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E88E5),
                      height: 1.0,
                    ),
                  ),
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
