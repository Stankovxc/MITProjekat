class ApartmaneModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double pricePerNight;
  final int capacity;
  final bool hasWifi;
  final double rating;

  ApartmaneModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.pricePerNight,
    required this.capacity,
    required this.hasWifi,
    required this.rating,
  });

  factory ApartmaneModel.fromMap(Map<String, dynamic> data, String id) {
    return ApartmaneModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      pricePerNight: (data['pricePerNight'] ?? 0).toDouble(),
      capacity: data['capacity'] ?? 1,
      hasWifi: data['hasWifi'] ?? false,
      rating: data['rating'] ?? 0.00,
    );
  }
}
