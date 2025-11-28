// user_model.dart

class UserModel {
  final String fullName;
  final String phone;
  final String image;
  final String status;
  final String tShirtSize;

  UserModel({
    required this.fullName,
    required this.phone,
    required this.image,
    required this.status,
    required this.tShirtSize,
  });

  factory UserModel.fromDoc(Map<String, dynamic> data) {
    return UserModel(
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      image: data['photo'] ?? '',
      status: data['payment']['status'] ?? '',
      tShirtSize: data['tShirtSize'] ?? 'N/A',
    );
  }
}