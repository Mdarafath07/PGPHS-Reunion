

class UserModel {
  final String fullName;
  final String phone;
  final String image;
  final String status;
  final String tShirtSize;
  final bool isCancelled;

  UserModel({
    required this.fullName,
    required this.phone,
    required this.image,
    required this.status,
    required this.tShirtSize,
    required this.isCancelled,
  });

  factory UserModel.fromDoc(Map<String, dynamic> data) {
    return UserModel(
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      image: data['photo'] ?? '',
      status: data['payment']['status'] ?? '',
      tShirtSize: data['tShirtSize'] ?? 'N/A',
      isCancelled: data['isCancelled'] ?? false,
    );
  }
}