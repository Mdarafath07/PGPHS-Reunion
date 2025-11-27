import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../widgets/user_card.dart';
import '../widgets/user_details_popup.dart';
import 'qr_scanner_page.dart'; // <--- নতুন ইমপোর্ট

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final FirebaseService fs = FirebaseService();
  String _selectedFilter = "All";

  // --- New Methods for QR Scan ---
  Future<Map<String, dynamic>?> _fetchUserByRegId(String regId) async {
    // এখানে আপনার FirebaseService ব্যবহার করে reg_id দিয়ে ইউজার ডেটা Fetch করতে হবে

    // আমি এখানে ধরে নিচ্ছি fs.getUsers() সমস্ত ইউজারের ডেটা আনছে, যা reg_id
    // চেক করার জন্য যথেষ্ট (যদিও এটি স্কেলিং-এর জন্য সেরা উপায় নয়, Firestore query সেরা)
    try {
      final currentDocs = await fs.getUsers().first;

      for (var doc in currentDocs.docs) {
        final data = doc.data() as Map<String, dynamic>;
        // Case-insensitive/consistent check
        if (data['reg_id']?.toUpperCase() == regId.toUpperCase()) {
          // For UserCard actions
          data['userId'] = doc.id;
          return data;
        }
      }
      return null;
    } catch (e) {
      // Error handling
      return null;
    }
  }

  void _scanQRCode() async {
    final regId = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerPage()),
    );

    if (regId != null && regId.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Searching for User ID: $regId")),
      );

      final userData = await _fetchUserByRegId(regId);

      if (userData != null) {
        // User ID পেলে পপআপ দেখাও
        showUserDetailsPopup(context, userData);
      } else {
        // User না পেলে
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: User with ID $regId not found."),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    }
  }
  // --- End of New Methods ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xffF8F9FD),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFEBF4FF),
              Color(0xFFF8F9FD),
            ],
          ),
        ),
        child: Column(
          children: [
            // Custom Header with QR Button
            _buildCustomHeader(),

            _buildFilterBar(),

            const SizedBox(height: 10),

            // User List StreamBuilder (Existing Logic)
            Expanded(
              child: StreamBuilder(
                stream: fs.getUsers(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  final filteredDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data['payment']?['status'] ?? 'pending';
                    if (_selectedFilter == "All") return true;
                    return status.toLowerCase() == _selectedFilter.toLowerCase();
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20, top: 10),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      var data = filteredDocs[index].data() as Map<String, dynamic>;
                      final userId = filteredDocs[index].id;

                      return InkWell(
                        onTap: () => showUserDetailsPopup(context, data),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: UserCard(
                          name: data['fullName'] ?? 'No Name',
                          phone: data['phone'] ?? 'No Phone',
                          image: data['photo'] ?? '',
                          status: data['payment']?['status'] ?? 'pending',
                          onAccept: () => fs.updateStatus(userId, "completed"),
                          onReject: () => fs.updateStatus(userId, "failed"),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildCustomHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 10, 25, 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Admin Dashboard",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.blueGrey.shade900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Manage user verifications",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.blueGrey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.qr_code_2_rounded),
                color: Colors.blueAccent,
                onPressed: _scanQRCode, // <--- QR Scan Function Call
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ["All", "Verifying", "Completed", "Pending", "Failed"];

    return SizedBox(
      height: 65,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: filters.length,
        separatorBuilder: (c, i) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          final filterName = filters[index];
          final isSelected = _selectedFilter == filterName;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filterName;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                  colors: [Color(0xFF4481EB), Color(0xFF04BEFE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: const Color(0xFF4481EB).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ]
                    : [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Center(
                child: Text(
                  filterName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.filter_alt_off_outlined, size: 50, color: Colors.blue.shade300),
          ),
          const SizedBox(height: 20),
          Text(
            "No users found",
            style: TextStyle(
                color: Colors.blueGrey.shade800,
                fontSize: 18,
                fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "There are no users in '$_selectedFilter' list.",
            style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 14),
          ),
        ],
      ),
    );
  }
}