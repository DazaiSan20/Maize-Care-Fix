class DiseaseModel {
	final String? id;
	final String? name;
	final String? description;
	final String? severity;

	DiseaseModel({this.id, this.name, this.description, this.severity});

	factory DiseaseModel.fromJson(Map<String, dynamic> json) => DiseaseModel(
				id: json['id']?.toString() ?? json['_id']?.toString(),
				name: json['name'],
				description: json['description'],
				severity: json['severity'],
			);

	Map<String, dynamic> toJson() => {
				'id': id,
				'name': name,
				'description': description,
				'severity': severity,
			};
}
