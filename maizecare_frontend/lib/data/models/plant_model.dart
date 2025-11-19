class PlantModel {
	final String? id;
	final String? name;
	final String? location;
	final String? ownerId;

	PlantModel({this.id, this.name, this.location, this.ownerId});

	factory PlantModel.fromJson(Map<String, dynamic> json) => PlantModel(
				id: json['id']?.toString() ?? json['_id']?.toString(),
				name: json['name'],
				location: json['location'],
				ownerId: json['owner']?.toString(),
			);

	Map<String, dynamic> toJson() => {
				'id': id,
				'name': name,
				'location': location,
				'owner': ownerId,
			};
}
