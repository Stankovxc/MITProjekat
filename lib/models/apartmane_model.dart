class ApartmaneModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double pricePerNight;
  final int capacity;
  final bool hasWifi;
  final double rating;
  final int totalRatings;
  final double sumOfRatings;
  final List<String> ratedUsers;

  ApartmaneModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.pricePerNight,
    required this.capacity,
    required this.hasWifi,
    required this.rating,
    required this.totalRatings,
    required this.sumOfRatings,
    required this.ratedUsers,
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
      totalRatings: data['totalRatings'] ?? 0,
      sumOfRatings: (data['sumOfRatings'] ?? 0.0).toDouble(),
      ratedUsers: List<String>.from(data['ratedUsers'] ?? []),
    );
  }
}
