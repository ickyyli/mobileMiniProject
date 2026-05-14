import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Payments & Invoices"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Outstanding"),
              Tab(text: "Invoices"),
              Tab(text: "Receipts"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOutstandingList(),
            _buildGenericList("Invoice"),
            _buildGenericList("Receipt"),
          ],
        ),
      ),
    );
  }

  Widget _buildOutstandingList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total Outstanding:", style: TextStyle(fontSize: 16)),
                Text("RM 350.00", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _paymentItem("May Fees", "RM 300.00", "Overdue"),
                _paymentItem("Activity Fee", "RM 50.00", "Pending"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentItem(String title, String amount, String status) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(status, style: const TextStyle(color: Colors.red)),
        trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildGenericList(String type) {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: 3,
      itemBuilder: (context, index) => Card(
        child: ListTile(
          leading: Icon(type == "Invoice" ? Icons.description : Icons.receipt_long, color: Colors.blue),
          title: Text("$type #KS-00${index + 1}"),
          subtitle: const Text("Date: 01/05/2026"),
          trailing: const Icon(Icons.download_rounded),
        ),
      ),
    );
  }
}