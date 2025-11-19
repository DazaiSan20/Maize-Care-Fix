class NotificationModel {
	final String? id;
	final String? title;
	final String? body;
	final String? type;
	final bool? isRead;

	NotificationModel({this.id, this.title, this.body, this.type, this.isRead});

	factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
				id: json['id']?.toString() ?? json['_id']?.toString(),
				title: json['title'],
				body: json['body'],
				type: json['type'],
				isRead: json['isRead'] ?? json['is_read'] ?? false,
			);

	Map<String, dynamic> toJson() => {
				'id': id,
				'title': title,
				'body': body,
				'type': type,
				'isRead': isRead,
			};
}
