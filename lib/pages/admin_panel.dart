import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pgphs_reunion/widgets/confirmation_dialog.dart';
import '../services/firebase_service.dart';
import '../widgets/user_card.dart';
import '../widgets/user_details_popup.dart';
import '../widgets/long_press_animation.dart';
import '../widgets/action_dialogs.dart';
import 'qr_scanner_page.dart';
import 'tshirt_report_page.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final FirebaseService fs = FirebaseService();
  String _selectedFilter = "All";
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _isSearching = false;
  List<QueryDocumentSnapshot> _allUsers = [];

  Future<Map<String, dynamic>?> _fetchUserByRegId(String regId) async {
    try {
      final currentDocs = await fs.getUsers().first;
      for (var doc in currentDocs.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['reg_id']?.toUpperCase() == regId.toUpperCase()) {
          data['userId'] = doc.id;
          return data;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void _scanQRCode() async {
    final regId = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const QrScannerPage()),
    );

    if (regId != null && regId.isNotEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Searching for User ID: $regId")));

      final userData = await _fetchUserByRegId(regId);

      if (mounted) {
        if (userData != null) {
          showUserDetailsPopup(context, userData);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: User with ID $regId not found."),
              backgroundColor: Colors.red.shade400,
            ),
          );
        }
      }
    }
  }

  void _navigateToTShirtReport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TShirtReportPage()),
    );
  }

  // Search function
  List<QueryDocumentSnapshot> _searchUsers(List<QueryDocumentSnapshot> users) {
    if (_searchQuery.isEmpty) return users;

    final query = _searchQuery.toLowerCase();
    return users.where((doc) {
      final data = doc.data() as Map<String, dynamic>;

      // Search in multiple fields
      final name = data['fullName']?.toString().toLowerCase() ?? '';
      final phone = data['phone']?.toString().toLowerCase() ?? '';
      final regId = data['reg_id']?.toString().toLowerCase() ?? '';
      final email = data['email']?.toString().toLowerCase() ?? '';

      return name.contains(query) ||
          phone.contains(query) ||
          regId.contains(query) ||
          email.contains(query);
    }).toList();
  }

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
            colors: [Color(0xFFEBF4FF), Color(0xFFF8F9FD)],
          ),
        ),
        child: Column(
          children: [
            _buildCustomHeader(),
            _buildSearchBar(),
            _buildFilterBar(),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                stream: fs.getUsers(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Store all users
                  _allUsers = snapshot.data!.docs.toList();

                  // Apply sorting
                  _allUsers.sort((a, b) {
                    final dataA = a?.data() as Map<String, dynamic>;
                    final dataB = b?.data() as Map<String, dynamic>;
                    final timeA =
                        dataA['regAt'] ?? dataA['payment']?['paidAt'] ?? '';
                    final timeB =
                        dataB['regAt'] ?? dataB['payment']?['paidAt'] ?? '';
                    return timeB.compareTo(timeA);
                  });

                  // Apply search filter first
                  List<QueryDocumentSnapshot> searchedUsers = _searchUsers(
                    _allUsers,
                  );

                  // Apply status filter
                  final filteredDocs = searchedUsers.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final payment = data['payment'] ?? {};
                    final status = payment['status'] ?? 'unpaid';
                    final isCancelled = payment['isCancelled'] ?? false;
                    final lowerStatus = status.toLowerCase();

                    if (_selectedFilter == "All") return true;
                    if (_selectedFilter == "Verifying")
                      return lowerStatus == "verifying";
                    if (_selectedFilter == "Paid") return lowerStatus == "paid";
                    if (_selectedFilter == "Cancelled")
                      return isCancelled == true;
                    if (_selectedFilter == "Unpaid") {
                      return lowerStatus == "unpaid" && isCancelled == false;
                    }
                    return false;
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20, top: 10),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      var data =
                          filteredDocs[index].data() as Map<String, dynamic>;
                      final payment = data['payment'] ?? {};
                      final userId = filteredDocs[index].id;
                      final isCancelledFromPayment =
                          payment['isCancelled'] ?? false;
                      final timestamp = payment['paidAt'] ?? data['regAt'];
                      String displayStatus = payment['status'] ?? 'unpaid';
                      String cardStatus = displayStatus.toLowerCase();

                      return InkWell(
                        onTap: () => showUserDetailsPopup(context, data),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: UserCard(
                          name: data['fullName'] ?? 'No Name',
                          phone: data['phone'] ?? 'No Phone',
                          image: data['photo'] ?? '',
                          status: cardStatus,
                          isCancelled: isCancelledFromPayment,
                          time: timestamp,

                          // ON ACCEPT LOGIC
                          onAccept: () {
                            _handleUserAccept(userId);
                          },

                          // ON REJECT LOGIC
                          onReject: () async {
                            _handleUserReject(userId);
                          },
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

  // Search Bar Widget
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _isSearching = value.isNotEmpty;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search by name, phone, email or Reg ID...",
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.blueGrey.shade400,
                  ),
                  suffixIcon: _isSearching
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.blueGrey.shade400,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = "";
                              _isSearching = false;
                            });
                          },
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // User Accept Handler
  void _handleUserAccept(String userId) {
    showLongPressAnimation(context, () async {
      _processUserAccept(userId);
    });
  }

  // User Reject Handler
  Future<void> _handleUserReject(String userId) async {
    final confirm = await showConfirmDialog(
      context,
      "Reject?",
      "Mark as Unpaid (Cancelled)?",
    );

    if (confirm == true) {
      await fs.updateStatus(userId, "unpaid");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User marked as Unpaid/Cancelled")),
        );
      }
    }
  }

  // Process User Accept
  Future<void> _processUserAccept(String userId) async {
    // Show Processing Dialog
    showProcessingDialog(context);

    try {
      // Call Firebase Service
      final result = await fs.updateStatus(userId, "paid");

      // Close Processing Dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // Show Result Dialog
      if (mounted) {
        final bool success = result['success'] ?? false;
        final bool hasWarning = result['warning'] ?? false;

        if (success && hasWarning) {
          showResultDialog(
            context: context,
            isSuccess: true,
            message: "Payment Verified!",
            errorDetails: result['message'],
          );
        } else {
          showResultDialog(
            context: context,
            isSuccess: success,
            message: success
                ? (result['message'] ?? "Verification Successful!")
                : "Verification Failed",
            errorDetails: success ? null : result['message'],
          );
        }
      }
    } catch (e) {
      // Close Processing Dialog on error
      if (mounted) {
        Navigator.pop(context);
        showResultDialog(
          context: context,
          isSuccess: false,
          message: "Error occurred",
          errorDetails: e.toString(),
        );
      }
    }
  }

  // Header Widget
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
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.blueGrey.shade900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Manage all user verifications",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.blueGrey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _buildHeaderIcon(
                  Icons.assessment_outlined,
                  Colors.purple.shade600,
                  _navigateToTShirtReport,
                ),
                const SizedBox(width: 15),
                _buildHeaderIcon(
                  Icons.qr_code_2_outlined,
                  Colors.blueAccent,
                  _scanQRCode,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, Color color, VoidCallback onTap) {
    return Container(
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
      child: IconButton(icon: Icon(icon), color: color, onPressed: onTap),
    );
  }

  // Filter Bar Widget
  Widget _buildFilterBar() {
    final filters = ["All", "Verifying", "Paid", "Unpaid", "Cancelled"];

    return SizedBox(
      height: 65,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: filters.length,
        separatorBuilder: (c, i) => const SizedBox(width: 12),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF4481EB), Color(0xFF04BEFE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF4481EB).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: Text(
                  filterName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontWeight: FontWeight.w700,
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

  // Empty State Widget
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
            child: Icon(
              _isSearching ? Icons.search_off : Icons.filter_alt_off_outlined,
              size: 50,
              color: Colors.blue.shade300,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _isSearching ? "No results found" : "No users found",
            style: TextStyle(
              color: Colors.blueGrey.shade800,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _isSearching
                ? "Try searching with different keywords"
                : "There are no users in '$_selectedFilter' list.",
            style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
