class UserModel {
	final String? id;
	final String? name;
	final String? email;
	final String? phone;

	UserModel({this.id, this.name, this.email, this.phone});

	factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
				id: json['id']?.toString() ?? json['_id']?.toString(),
				name: json['name'] ?? json['displayName'],
				email: json['email'],
				phone: json['phone'],
			);

	Map<String, dynamic> toJson() => {
				'id': id,
				'name': name,
				'email': email,
				'phone': phone,
			};
}
