class UserModel {
  final int    id;
  final String name;
  final String email;
  final String token;
  final String companyName;
  final String avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    required this.companyName,
    required this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id:          j['id'],
    name:        j['name'] ?? '',
    email:       j['email'] ?? '',
    token:       j['token'] ?? '',
    companyName: j['company_name'] ?? '',
    avatarUrl:   j['avatar_url'] ?? '',
  );
}
