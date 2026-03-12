import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user_parking/Controller/UserController.dart';
import 'package:user_parking/Model/TicketModel.dart';
import 'package:user_parking/Service/GraphqlService/Graphql_Service.dart';

import '../HomeScreen.dart';

class Ticketscreen extends StatefulWidget {
  const Ticketscreen({super.key});

  @override
  State<Ticketscreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<Ticketscreen> {
  List<UserTicketItem> tickets = [];
  bool isLoading = true;
  late UserController userController;
  late GraphQLClient _client;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  void _startUPIPayment(double amount) async {
    final upiUrl = Uri.parse(
      "upi://pay?pa=9597341979@okaxis&pn=${Uri.encodeComponent('Gokulakrishnan')}&am=$amount&cu=INR",
    );

    try {
      await launchUrl(upiUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to launch UPI payment")),
      );
    }
  }

  // void _startUPIPayment(double amount) async {
  //   final upiUrl = Uri.parse(
  //     "upi://pay?pa=9597341979@naviaxis&pn=Gokulakrishnan=$amount&cu=INR",
  //   );
  //
  //   if (await canLaunchUrl(upiUrl)) {
  //     await launchUrl(upiUrl, mode: LaunchMode.externalApplication);
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("No UPI app found on this device")),
  //     );
  //   }
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      _client = GraphQLProvider.of(context).value;
      final graphqlService = GraphQLService(_client);

      if (!Get.isRegistered<UserController>()) {
        userController = Get.put(UserController(graphqlService));
      } else {
        userController = Get.find<UserController>();
      }

      fetchTickets();
      _isInitialized = true;
    }
  }

  void fetchTickets() async {
    final prefs = await SharedPreferences.getInstance();
    final userMobile = prefs.getString('userMobile') ?? '';

    final fetchedTickets = await userController.getUserTickets(userMobile);

    setState(() {
      tickets = fetchedTickets;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
        return false;
      },

      child: Scaffold(
        backgroundColor: const Color(0xFFEAF4FF),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          elevation: 0.5,
          title: Text(
            "Tickets",
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen()),
              );
            },
          ),
        ),
        body:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : tickets.isEmpty
                ? const Center(child: Text("No tickets found"))
                : Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),

                      /// Last Ticket Title Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Last Ticket",
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const Icon(Icons.expand_less),
                        ],
                      ),
                      const SizedBox(height: 12),

                      /// Last Ticket Card
                      buildLastTicketCard(tickets[0]),

                      const SizedBox(height: 20),

                      /// Ticket History
                      Expanded(
                        child: ListView.builder(
                          itemCount: tickets.length,
                          padding: const EdgeInsets.only(top: 0),
                          itemBuilder: (context, index) {
                            final ticket = tickets[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.train,
                                    color: Colors.black87,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ticket.inDate ?? '',
                                          style: GoogleFonts.montserrat(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          ticket.parkingLotName ?? '',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "View Ticket",
                                    style: GoogleFonts.montserrat(
                                      color: const Color(0xFF0052B0),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day.toString().padLeft(2, '0')}."
          "${date.month.toString().padLeft(2, '0')}."
          "${date.year}";
    } catch (e) {
      return dateStr;
    }
  }

  Widget buildLastTicketCard(UserTicketItem ticket) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Row(
            children: [
              /// QR Code
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/Png/QR.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// Train Icon + Station Info
                    Row(
                      children: [
                        Image.asset(
                          'assets/Png/Train.png',
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(width: 6),
                        Expanded(
                          // ✅ Prevents overflow
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket.parkingLotName ?? 'Station',
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 1.0,
                                ),
                                overflow:
                                    TextOverflow.ellipsis, // Optional safety
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Railway Station',
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                                overflow:
                                    TextOverflow.ellipsis, // Optional safety
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    /// Slot Number Below Station Info
                    Column(
                      children: [
                        Text(
                          "Slot No.",
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'A0055',
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          /// In & Out Times
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn(
                "In time",
                formatDate(ticket.inDate ?? ''),
                ticket.inTime ?? '',
              ),
              _buildInfoColumn(
                "Out time",
                formatDate(ticket.outDate ?? ''),
                ticket.outTime ?? '',
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),

          /// Total Hours & Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabelValue("Total Hours", ticket.totalHours ?? ''),
              _buildLabelValue(
                "Total Amount",
                "₹ ${ticket.totalAmount ?? '0'}",
                align: TextAlign.right,
              ),
            ],
          ),

          const SizedBox(height: 26),

          /// Pay Now Button
          SizedBox(
            width: 200,
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                if (ticket.totalAmount != null) {
                  _startUPIPayment(ticket.totalAmount!.toDouble());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00448C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                "Pay Now",
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String date, String time) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label and Date in same row
          Row(
            children: [
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: const Color(0xFF484646),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                date,
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF575656),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Clock icon and time
          Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 20,
                  color: Color(0xFF130101),
                ),
                const SizedBox(width: 4),
                Text(
                  time,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0C0101),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelValue(
    String label,
    String value, {
    TextAlign align = TextAlign.left,
  }) {
    return Column(
      crossAxisAlignment:
          align == TextAlign.right
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: const Color(0xFF3A3A3A),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(right: 24.0),
          child: Text(
            value,
            textAlign: align,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              color: const Color(0xFF100101),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
