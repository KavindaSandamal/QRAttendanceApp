enum UserRole {
  student,
  lecturer,
}

class UserModel {
  final String? id;
  final String regNo;
  final String fullname;
  final String email;
  final String password;
  final String role;
  final String? profilePhotoUrl;

  const UserModel({
    this.id,
    required this.regNo,
    required this.fullname,
    required this.email,
    required this.password,
    required this.role,
    this.profilePhotoUrl,
  });

  UserModel copyWith({
    String? id,
    String? regNo,
    String? fullname,
    String? email,
    String? password,
    String? role,
    String? profilePhotoUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      regNo: regNo ?? this.regNo,
      fullname: fullname ?? this.fullname,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }

  // Add fromJson factory method to convert JSON to UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      regNo: json['RegNo'],
      fullname: json['FullName'],
      email: json['Email'],
      password: json['Password'],
      role: json['Role'],
      profilePhotoUrl: json['ProfilePhotoUrl'],
    );
  }

  // Add toJson method to convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'RegNo': regNo,
      'FullName': fullname,
      'Email': email,
      'Password': password,
      'Role': role,
      'ProfilePhotoUrl': profilePhotoUrl,
    };
  }
}
