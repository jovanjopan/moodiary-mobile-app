class User {
  final int? id;
  final String name;
  final String pin; // Disimpan sebagai String biar mudah
  final String avatarEmoji; // Contoh: "😎", "🐱"
  final String bio;

  User({
    this.id,
    required this.name,
    required this.pin,
    required this.avatarEmoji,
    this.bio = "Writing my story...", // Default bio
  });

  // Convert ke Map untuk disimpan ke SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'pin': pin,
      'avatarEmoji': avatarEmoji,
      'bio': bio,
    };
  }

  // Convert dari Map (SQLite) ke Object User
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      pin: map['pin'],
      avatarEmoji: map['avatarEmoji'] ?? "😊",
      bio: map['bio'] ?? "Writing my story...",
    );
  }
}
