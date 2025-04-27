import 'package:flutter/material.dart';
import '../models/service_center.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class ServiceFinderScreen extends StatefulWidget {
  const ServiceFinderScreen({super.key});

  @override
  State<ServiceFinderScreen> createState() => _ServiceFinderScreenState();
}

class _ServiceFinderScreenState extends State<ServiceFinderScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Food', 'Housing', 'Legal', 'Medical'];
  final List<ServiceCenter> _serviceCenters = [
    ServiceCenter(
      id: '1',
      name: 'Food Bank KL',
      category: 'Food',
      distance: 0.5,
      address: 'Jalan ABC, 50450 KL',
      phone: '+6012-0001234',
      operatingHours: 'Mon-Fri, 9AM-4PM',
      latitude: 3.1390,
      longitude: 101.6869,
      email: 'help@foodbank.my',
      website: 'www.foodbank.my',
    ),
    ServiceCenter(
      id: '2',
      name: 'House Bank KL',
      category: 'Housing',
      distance: 2.25,
      address: 'Jalan DEF, 50460 KL',
      phone: '+6012-0005678',
      operatingHours: 'Mon-Sat, 10AM-6PM',
      latitude: 3.1421,
      longitude: 101.6867,
    ),
    ServiceCenter(
      id: '3',
      name: 'Hospital Wawasan',
      category: 'Medical',
      distance: 12.0,
      address: 'Jalan GHI, 50470 KL',
      phone: '+6012-9101112',
      operatingHours: '24/7',
      latitude: 3.1399,
      longitude: 101.6868,
      email: 'info@wawasan.my',
      website: 'www.wawasan.my',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  List<ServiceCenter> get filteredCenters {
    return _serviceCenters.where((center) {
      final matchesSearch = _searchQuery.isEmpty || 
          center.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          center.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          center.category.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory =
          _selectedCategory == 'All' || center.category == _selectedCategory;
      
      return matchesSearch && matchesCategory;
    }).toList()
      ..sort((a, b) => a.distance.compareTo(b.distance));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 237, 250, 250),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on_outlined, 
              color: Color(0xFF1A237E),
              size: 28,
            ),
            const SizedBox(width: 3),
            Text(
              'Support Services',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A237E),
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.home, 
              color: Color(0xFF1A237E),
              size: 28,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search for services...',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                // Category Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            category,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? _getCategoryColor(category) : Colors.black87,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          backgroundColor: _getCategoryColor(category).withOpacity(0.1),
                          selectedColor: _getCategoryColor(category).withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: _getCategoryColor(category),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredCenters.length,
              itemBuilder: (context, index) {
                final center = filteredCenters[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
                  elevation: 2,
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: _getCategoryColor(center.category).withOpacity(0.1),
                      child: Icon(
                        _getCategoryIcon(center.category),
                        color: _getCategoryColor(center.category),
                      ),
                    ),
                    title: Text(
                      center.name,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    subtitle: Text(
                      '${center.distance} km away',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Color(0xFF424242),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(Icons.location_on, center.address),
                            const SizedBox(height: 8),
                            _buildInfoRow(Icons.phone, center.phone),
                            const SizedBox(height: 8),
                            _buildInfoRow(Icons.access_time, center.operatingHours),
                            if (center.email != null) ...[
                              const SizedBox(height: 8),
                              _buildInfoRow(Icons.email, center.email!),
                            ],
                            if (center.website != null) ...[
                              const SizedBox(height: 8),
                              _buildInfoRow(Icons.language, center.website!),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _openMap(center),
                                    icon: const Icon(Icons.map),
                                    label: const Text(
                                      'View on Map',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4CAF50),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _callPhone(center.phone),
                                    icon: const Icon(Icons.phone),
                                    label: const Text(
                                      'Call Now',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2196F3),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF424242)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.4,
              color: Color(0xFF424242),
            ),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return const Color(0xFFF0F00E);
      case 'Housing':
        return const Color(0xFF03C8FF);
      case 'Legal':
        return const Color(0xFF4CAF50);
      case 'Medical':
        return const Color(0xFFE58BFF);
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Housing':
        return Icons.home;
      case 'Legal':
        return Icons.gavel;
      case 'Medical':
        return Icons.local_hospital;
      default:
        return Icons.category;
    }
  }

  Future<void> _openMap(ServiceCenter center) async {
    final Uri url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${center.latitude},${center.longitude}');
    if (await launcher.canLaunchUrl(url)) {
      await launcher.launchUrl(url);
    } else {
      throw 'Could not launch maps';
    }
  }

  Future<void> _callPhone(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    if (await launcher.canLaunchUrl(url)) {
      await launcher.launchUrl(url);
    } else {
      throw 'Could not make call';
    }
  }
} 