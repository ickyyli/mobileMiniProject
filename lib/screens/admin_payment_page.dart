import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPaymentPage extends StatelessWidget {
  const AdminPaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        title: const Text("Manage Payments", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3142),
        elevation: 0.5,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Ditukar ke koleksi 'payment'
        stream: FirebaseFirestore.instance
            .collection('payment')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No invoice records found."));
          }

          final paymentDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: paymentDocs.length,
            itemBuilder: (context, index) {
              final data = paymentDocs[index].data() as Map<String, dynamic>;
              final docId = paymentDocs[index].id;
              
              String status = data['status'] ?? 'Pending';
              Color statusColor = Colors.orange;
              if (status == 'Paid' || status == 'paid') statusColor = Colors.green;
              if (status == 'Overdue' || status == 'overdue') statusColor = Colors.red;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(data['title'] ?? 'Fee Payment', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text("Parent: ${data['parentEmail'] ?? 'N/A'}"),
                      Text("ID: $docId", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "RM ${double.parse(data['amount'].toString()).toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  onLongPress: () => _showStatusUpdateDialog(context, docId, status),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateInvoiceDialog(context),
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Create Invoice", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showCreateInvoiceDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final parentEmailController = TextEditingController(); 
    String selectedStatus = 'Pending';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("New Invoice", style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: parentEmailController,
                  decoration: const InputDecoration(labelText: "Parent Registered Email", hintText: "parent@example.com"),
                ),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Invoice Title", hintText: "e.g., May Fees"),
                ),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: "Amount (RM)", hintText: "0.00"),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(labelText: "Initial Status"),
                  items: ['Pending', 'Overdue']
                      .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) selectedStatus = val;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                final String targetEmail = parentEmailController.text.trim();
                final String invoiceTitle = titleController.text.trim();
                final String amountText = amountController.text.trim();

                if (invoiceTitle.isNotEmpty && amountText.isNotEmpty && targetEmail.isNotEmpty) {
                  final double? parsedAmount = double.tryParse(amountText);
                  if (parsedAmount == null) return;

                  try {
                    final batch = FirebaseFirestore.instance.batch();

                    // Ditukar ke koleksi 'payment' (Tunggal)
                    final paymentRef = FirebaseFirestore.instance.collection('payment').doc();
                    batch.set(paymentRef, {
                      'parentEmail': targetEmail,
                      'title': invoiceTitle,
                      'amount': parsedAmount,
                      'status': selectedStatus,
                      'date': Timestamp.now(),
                    });

                    final notificationRef = FirebaseFirestore.instance.collection('notifications').doc();
                    batch.set(notificationRef, {
                      'parentEmail': targetEmail,
                      'title': "New Invoice Issued 💰",
                      'body': "A new invoice '$invoiceTitle' of RM ${parsedAmount.toStringAsFixed(2)} has been generated for your child.",
                      'timestamp': Timestamp.now(),
                      'isRead': false,
                      'type': 'payment',
                    });

                    await batch.commit();

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Invoice created and notification sent successfully!")),
                      );
                    }
                  } catch (e) {
                    debugPrint("Error: $e");
                  }
                }
              },
              child: const Text("Send Invoice", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showStatusUpdateDialog(BuildContext context, String docId, String currentStatus) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update Status"),
          content: const Text("Change payment status for this invoice?"),
          actions: [
            TextButton(
              onPressed: () async {
                // Ditukar ke koleksi 'payment'
                await FirebaseFirestore.instance.collection('payment').doc(docId).update({'status': 'Paid'});
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Mark as Paid", style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () async {
                // Ditukar ke koleksi 'payment'
                await FirebaseFirestore.instance.collection('payment').doc(docId).update({'status': 'Overdue'});
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Mark as Overdue", style: TextStyle(color: Colors.red)),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ],
        );
      },
    );
  }
}