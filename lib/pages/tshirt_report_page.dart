

import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
class TShirtReportPage extends StatelessWidget {
  const TShirtReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseService fs = FirebaseService();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,



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
        child: SafeArea(
          child: FutureBuilder<Map<String, int>>(

            future: fs.getTShirtSizeCounts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
              }

              if (snapshot.hasError) {
                return Center(child: Text("Error fetching report: ${snapshot.error}"));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    "No completed registrations found yet.",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              final sizeCounts = snapshot.data!;
              final totalCount = sizeCounts.values.fold(0, (sum, count) => sum + count);
              final sortedSizes = sizeCounts.keys.toList()..sort();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _buildCustomHeader(context),



                  _buildTotalCountCard(totalCount),

                  const Padding(
                    padding: EdgeInsets.fromLTRB(25, 15, 20, 10),
                    child: Text(
                      "Size Breakdown",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.blueGrey
                      ),
                    ),
                  ),


                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      itemCount: sortedSizes.length,
                      itemBuilder: (context, index) {
                        final size = sortedSizes[index];
                        final count = sizeCounts[size]!;
                        return _buildSizeTile(size, count);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 10, 25, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.blueGrey, size: 20),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(height: 10),
          // বড় টাইটেল
          const Text(
            "T-Shirt Stock Report",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E3A8A),
            ),
          ),
        ],
      ),
    );
  }




  Widget _buildTotalCountCard(int totalCount) {
    return Container(
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.fromLTRB(25, 10, 25, 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4481EB), Color(0xFF04BEFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total T-Shirts Required",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Completed Registrations",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          Text(
            totalCount.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSizeTile(String size, int count) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.checkroom, color: Colors.blueAccent),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    size,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const Text("T-Shirt Size", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),

          // Count Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: Colors.green.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}