class MachineryModel {
  final String id;
  final String name;
  final String urduName;
  final String category;
  final double distanceKm; // Real-time distance from Google Maps API
  final double rate;
  final String rateUnit; // 'Acre' or 'Hour'
  final String ownerName;
  final String ownerPhone;
  final String location;
  final double rating;
  final int completedJobs;
  final bool isAvailable;
  final String imageUrl;

  const MachineryModel({
    required this.id,
    required this.name,
    required this.urduName,
    required this.category,
    required this.distanceKm,
    required this.rate,
    required this.rateUnit,
    required this.ownerName,
    required this.ownerPhone,
    required this.location,
    required this.rating,
    required this.completedJobs,
    required this.isAvailable,
    required this.imageUrl,
  });
}
