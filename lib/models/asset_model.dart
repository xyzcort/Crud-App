class AssetModel {
  // Properti aset
  String id; // ID aset
  String name;
  String type;
  String image;
  DateTime createdAt;
  DateTime updateAt;

  // Konstruktor AssetModel
  AssetModel({
    required this.id,
    required this.name,
    required this.type,
    required this.image,
    required this.createdAt,
    required this.updateAt,
  });

  // Factory method untuk membuat instance AssetModel dari JSON
  factory AssetModel.fromJson(Map<String, dynamic> json) => AssetModel(
        id: json["id"],
        name: json["name"],
        type: json["type"],
        image: json["image"],
        createdAt: DateTime.parse(json["created_at"]).toLocal(),
        updateAt: DateTime.parse(json["update_at"]).toLocal(),
      );

  // Method untuk mengubah instance AssetModel menjadi JSON
  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "image": image,
        "created_at": createdAt.toIso8601String(),
        "update_at": updateAt.toIso8601String(),
      };
}
