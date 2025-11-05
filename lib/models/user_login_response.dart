import 'dart:convert';

// Helper function to decode the response body
UserLoginResponse userLoginResponseFromJson(String str) => UserLoginResponse.fromJson(json.decode(str));

// Represents the entire JSON response from the login API
class UserLoginResponse {
    final String status;
    final String message;
    final UserData? data;

    UserLoginResponse({
        required this.status,
        required this.message,
        this.data,
    });

    factory UserLoginResponse.fromJson(Map<String, dynamic> json) => UserLoginResponse(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : UserData.fromJson(json["data"]),
    );
}

// Represents the user data nested within the response
class UserData {
    final int userId;
    final String username;
    final String email;
    final String role;
    final String createdAt;
    // NOTE: A real-world app would include a JWT token here
    // final String token; 

    UserData({
        required this.userId,
        required this.username,
        required this.email,
        required this.role,
        required this.createdAt,
    });

    factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        userId: json["user_id"],
        username: json["username"],
        email: json["email"],
        role: json["role"],
        createdAt: json["created_at"],
    );
}