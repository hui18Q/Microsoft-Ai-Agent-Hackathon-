class ServiceCenter {
  final String id;
  final String name;
  final String category;
  final double distance;
  final String address;
  final String phone;
  final String operatingHours;
  final String? email;
  final String? website;
  final double latitude;
  final double longitude;

  ServiceCenter({
    required this.id,
    required this.name,
    required this.category,
    required this.distance,
    required this.address,
    required this.phone,
    required this.operatingHours,
    required this.latitude,
    required this.longitude,
    this.email,
    this.website,
  });
} 