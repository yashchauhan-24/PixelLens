enum UserRole { admin, user }

extension UserRoleLabel on UserRole {
  String get value => name;

  String get displayName => switch (this) {
        UserRole.admin => 'Admin',
        UserRole.user => 'User',
      };
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.address,
    this.profileImage,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? address;
  final String? profileImage;

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? phone,
    String? address,
    String? profileImage,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role.value,
        'phone': phone,
        'address': address,
        'profileImage': profileImage,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      role: UserRole.values.firstWhere((element) => element.name == map['role']),
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      profileImage: map['profileImage'] as String?,
    );
  }
}
