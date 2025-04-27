class Application {
  final String id;
  final String title;
  final String status;
  final String lastUpdated;
  final String organization;
  final String phone;
  final String email;
  final String hours;
  final String logoUrl;

  Application({
    required this.id,
    required this.title,
    required this.status,
    required this.lastUpdated,
    required this.organization,
    required this.phone,
    required this.email,
    required this.hours,
    required this.logoUrl,
  });

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'],
      title: json['title'],
      status: json['status'],
      lastUpdated: json['lastUpdated'],
      organization: json['organization'],
      phone: json['phone'],
      email: json['email'],
      hours: json['hours'],
      logoUrl: json['logoUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status,
      'lastUpdated': lastUpdated,
      'organization': organization,
      'phone': phone,
      'email': email,
      'hours': hours,
      'logoUrl': logoUrl,
    };
  }
} 