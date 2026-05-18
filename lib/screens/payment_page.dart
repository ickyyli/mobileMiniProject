import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  String get parentEmail => FirebaseAuth.instance.currentUser?.email ?? '';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text("Payments & Invoices", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.deepPurple[100],
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.deepPurple,
            labelColor: Colors.deepPurple,
            unselectedLabelColor: Colors.black54,
            tabs: [
              Tab(text: "Outstanding"),
              Tab(text: "Invoices"),
              Tab(text: "Receipts"),
            ],
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          // Ditukar ke koleksi 'payment' (Tunggal)
          stream: FirebaseFirestore.instance
              .collection('payment')
              .where('parentEmail', isEqualTo: parentEmail)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No payment dashboard information available."));
            }

            final docs = snapshot.data!.docs;

            // Logik saringan selamat mengira huruf besar/kecil (case-insensitive checking)
            final outstandingDocs = docs.where((doc) {
              String stat = (doc['status'] ?? '').toString().toLowerCase();
              return stat != 'paid';
            }).toList();

            final invoiceDocs = docs.where((doc) {
              String stat = (doc['status'] ?? '').toString().toLowerCase();
              return stat == 'pending' || stat == 'overdue';
            }).toList();

            final receiptDocs = docs.where((doc) {
              String stat = (doc['status'] ?? '').toString().toLowerCase();
              return stat == 'paid';
            }).toList();

            double totalOutstanding = 0.0;
            for (var doc in outstandingDocs) {
              totalOutstanding += double.parse(doc['amount'].toString());
            }

            return TabBarView(
              children: [
                _buildOutstandingList(outstandingDocs, totalOutstanding),
                _buildDynamicList(invoiceDocs, "Invoice"),
                _buildDynamicList(receiptDocs, "Receipt"),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOutstandingList(List<QueryDocumentSnapshot> docs, double total) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: total > 0 ? Colors.red[50] : Colors.green[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: total > 0 ? Colors.red.shade200 : Colors.green.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Outstanding:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text(
                  "RM ${total.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: total > 0 ? Colors.red : Colors.green),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: docs.isEmpty
                ? const Center(child: Text("Great! No outstanding payments."))
                : ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      String status = data['status'] ?? 'Pending';
                      bool isOverdue = status.toLowerCase() == 'overdue';
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          title: Text(data['title'] ?? 'Fee Summary', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            status,
                            style: TextStyle(color: isOverdue ? Colors.red : Colors.orange, fontWeight: FontWeight.w500),
                          ),
                          trailing: Text(
                            "RM ${double.parse(data['amount'].toString()).toStringAsFixed(2)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicList(List<QueryDocumentSnapshot> docs, String type) {
    if (docs.isEmpty) {
      return Center(child: Text("No active ${type.toLowerCase()} records."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final data = docs[index].data() as Map<String, dynamic>;
        final docId = docs[index].id;
        
        String formattedDate = "01/05/2026";
        if (data['date'] != null) {
          DateTime dateTime = (data['date'] as Timestamp).toDate();
          formattedDate = DateFormat('dd/MM/yyyy').format(dateTime);
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: type == "Invoice" ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              child: Icon(
                type == "Invoice" ? Icons.description_rounded : Icons.receipt_long_rounded, 
                color: type == "Invoice" ? Colors.blue : Colors.green
              ),
            ),
            title: Text("$type #${docId.substring(0, docId.length < 6 ? docId.length : 6).toUpperCase()}"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['title'] ?? ''),
                Text("Date: $formattedDate", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "RM ${double.parse(data['amount'].toString()).toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.download_rounded, size: 20, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }
}