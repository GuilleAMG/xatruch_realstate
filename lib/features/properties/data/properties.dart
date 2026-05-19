// Modelo de datos de propiedad: define la clase Property con todos
// sus atributos y metodos de serializacion desde/hacia Firestore.
class Property {
  Property({
    required this.id,
    required this.title,
    required this.location,
    this.department = '',
    this.municipality = '',
    this.propertyType = '',
    required this.price,
    required this.imageUrls,
    this.videoUrls = const [],
    required this.description,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    this.isFavorite = false,
    required this.sellerName,
    this.sellerId = '',
    this.hasElectricity = false,
    this.hasWater = false,
    this.latitude,
    this.longitude,
    this.expiresAt,
    this.isSold = false,
    this.buyerName = '',
    this.buyerId = '',
    this.soldPrice,
    this.soldAt,
  });

  /// Crea una Property desde un mapa de documento de Firestore.
  factory Property.fromMap(Map<String, dynamic> map, String docId) {
    return Property(
      id: docId,
      title: (map['title'] as String?) ?? '',
      location: (map['location'] as String?) ?? '',
      department: (map['department'] as String?) ?? '',
      municipality: (map['municipality'] as String?) ?? '',
      propertyType: (map['propertyType'] as String?) ?? '',
      price: (map['price'] as num? ?? 0).toDouble(),
      imageUrls: List<String>.from((map['imageUrls'] as Iterable?) ?? []),
      videoUrls: List<String>.from((map['videoUrls'] as Iterable?) ?? []),
      description: (map['description'] as String?) ?? '',
      bedrooms: (map['bedrooms'] as num? ?? 0).toInt(),
      bathrooms: (map['bathrooms'] as num? ?? 0).toInt(),
      area: (map['area'] as num? ?? 0).toDouble(),
      sellerName: (map['sellerName'] as String?) ?? '',
      sellerId: (map['sellerId'] as String?) ?? '',
      hasElectricity: (map['hasElectricity'] as bool?) ?? false,
      hasWater: (map['hasWater'] as bool?) ?? false,
      latitude: (map['latitude'] as num? ?? 0.0).toDouble(),
      longitude: (map['longitude'] as num? ?? 0.0).toDouble(),
      expiresAt: map['expiresAt'] != null
          ? DateTime.parse(map['expiresAt'] as String)
          : null,
      isSold: (map['isSold'] as bool?) ?? false,
      buyerName: (map['buyerName'] as String?) ?? '',
      buyerId: (map['buyerId'] as String?) ?? '',
      soldPrice: map['soldPrice'] != null
          ? (map['soldPrice'] as num).toDouble()
          : null,
      soldAt: map['soldAt'] != null
          ? DateTime.parse(map['soldAt'] as String)
          : null,
    );
  }

  final String id;
  final String title;
  final String location;
  final String department;
  final String municipality;
  final String propertyType;
  final double price;
  final List<String> imageUrls;
  final List<String> videoUrls;
  final String description;
  final int bedrooms;
  final int bathrooms;
  final double area;
  bool isFavorite;
  final String sellerName;
  final String sellerId;
  final bool hasElectricity;
  final bool hasWater;
  final double? latitude;
  final double? longitude;
  final DateTime? expiresAt;

  // Información de venta
  bool isSold;
  String buyerName;
  String buyerId;
  double? soldPrice;
  DateTime? soldAt;

  /// Convierte la Property a un mapa compatible con Firestore.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'location': location,
      'department': department,
      'municipality': municipality,
      'propertyType': propertyType,
      'price': price,
      'imageUrls': imageUrls,
      'videoUrls': videoUrls,
      'description': description,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area': area,
      'sellerName': sellerName,
      'sellerId': sellerId,
      'hasElectricity': hasElectricity,
      'hasWater': hasWater,
      'latitude': latitude,
      'longitude': longitude,
      'expiresAt': expiresAt?.toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
      'isSold': isSold,
      'buyerName': buyerName,
      'buyerId': buyerId,
      'soldPrice': soldPrice,
      'soldAt': soldAt?.toIso8601String(),
    };
  }
}
