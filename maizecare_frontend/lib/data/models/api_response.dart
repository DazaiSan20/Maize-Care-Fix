class ApiResponse {
	final bool success;
	final String message;
	final dynamic data;

	ApiResponse({required this.success, this.message = '', this.data});

	factory ApiResponse.fromJson(Map<String, dynamic> json) {
		return ApiResponse(
			success: json['success'] == true,
			message: json['message'] ?? '',
			data: json['data'],
		);
	}

	Map<String, dynamic> toJson() => {
				'success': success,
				'message': message,
				'data': data,
			};
}
