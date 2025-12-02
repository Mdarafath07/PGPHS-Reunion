

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


void showProcessingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                  backgroundColor: Color(0xFFEBF4FF),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Processing...",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  decoration: TextDecoration.none,
                  fontFamily: 'Arial',
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Sending SMS & Updating DB",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  decoration: TextDecoration.none,
                  fontFamily: 'Arial',
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


void showResultDialog({
  required BuildContext context,
  required bool isSuccess,
  required String message,
  String? errorDetails,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              SizedBox(
                height: 120,
                width: 120,
                child: Lottie.asset(

                  isSuccess
                      ? 'assets/lottie/success.json'
                      : 'assets/lottie/failed.json',
                  repeat: false,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 15),


              Text(
                isSuccess ? "Success!" : "Failed!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? Colors.green.shade600 : Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 10),

              // Message
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),


              if (!isSuccess || (isSuccess && errorDetails != null && errorDetails.contains('failed'))) ...[
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isSuccess && errorDetails != null) ? Colors.orange.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: (isSuccess && errorDetails != null) ? Colors.orange.shade100 : Colors.red.shade100),
                  ),
                  child: Text(
                    "Details: $errorDetails",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: (isSuccess && errorDetails != null) ? Colors.orange.shade800 : Colors.red.shade800,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 25),


              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSuccess ? Colors.green : Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}