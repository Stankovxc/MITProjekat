class LocationModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String imageUrl;
  bool isFavorite;

  LocationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    this.isFavorite = false,
  });

  // Ovo nam treba da bismo podatke iz baze (JSON) pretvorili u Dart objekat
  factory LocationModel.fromMap(Map<String, dynamic> data, String documentId) {
    return LocationModel(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'Opšte',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
    };
  }
}
