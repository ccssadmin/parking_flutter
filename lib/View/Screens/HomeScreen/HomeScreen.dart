import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Controller/UserController.dart';
import '../../../Model/TicketModel.dart';
import '../../../Service/GraphqlService/Graphql_Service.dart';
import 'SubScreens/TicketScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late UserController userController;
  late GraphQLClient _client;
  bool _isInitialized = false;
  List<UserTicketItem> tickets = [];
  bool isLoading = true;

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
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEAF4FF),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.03),

                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Color(0xFFA4A4A4),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Hi, 👋",
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => Ticketscreen()),
                          );
                        },
                        child: Image.asset(
                          'assets/Png/Ticket.png',
                          width: 80,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: height * 0.03),

                  // Active Ticket Card
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : tickets.isNotEmpty
                      ? _buildActiveTicketCard(tickets.first)
                      : Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: const Text("No active tickets found."),
                      ),

                  SizedBox(height: height * 0.04),

                  // Past Tickets Header
                  Text(
                    "Past Tickets",
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (!isLoading && tickets.isNotEmpty)
                    ...tickets
                        .skip(tickets.length > 1 ? 1 : 0)
                        .map((t) => _buildPastTicket(t)),

                  const SizedBox(height: 25),

                  // View All + Bottom Image
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => Ticketscreen()),
                            );
                          },
                          child: Text(
                            "View All >>>",
                            style: GoogleFonts.montserrat(
                              color: const Color(0xFF00448C),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        Image.asset(
                          'assets/Png/BottomParking.png',
                          width: width,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeColumn(String label, String date, String time) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: const Color(0xFF606060),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF575656),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.access_time, size: 20, color: const Color(0xFF130101)),
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
        ],
      ),
    );
  }

  Widget _buildAmountOrDuration(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: const Color(0xFF606060),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActiveTicketCard(UserTicketItem ticket) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/Png/Train.png',
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.parkingLotName ?? "Parking Lot",
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  Text(
                    "Railway Station",
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF777777),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeColumn(
                "In time",
                ticket.inDate ?? "",
                ticket.inTime ?? "",
              ),
              _buildTimeColumn(
                "Out time",
                ticket.outDate ?? "",
                ticket.outTime ?? "",
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAmountOrDuration(
                "Total Amount",
                "₹ ${ticket.totalAmount ?? 0}",
              ),
              _buildAmountOrDuration(
                "Total Hours",
                ticket.totalHours ?? "0 hours",
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
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
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatTicketDateTime(String? date, String? time) {
    if (date == null || time == null) return '';

    try {
      DateTime input;

      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
        // Format: yyyy-MM-dd
        input = DateFormat("yyyy-MM-dd HH:mm").parse("$date $time");
      } else {
        // Default to dd-MM-yyyy
        input = DateFormat("dd-MM-yyyy HH:mm").parse("$date $time");
      }

      final formattedTime = DateFormat("hh:mm a").format(input); // 11:33 PM
      final formattedDate = DateFormat(
        "dd-MM-yyyy",
      ).format(input); // 11-07-2025

      return "$formattedTime • $formattedDate";
    } catch (e) {
      return '';
    }
  }

  Widget _buildPastTicket(UserTicketItem ticket) {
    final location = ticket.parkingLotName ?? 'Unknown';
    final isPaid = ticket.paymentStatus?.toLowerCase() == 'paid';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/Png/Train2.png',
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location,
                  style: GoogleFonts.poppins(
                    color: Color(0xFF151414),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Railway Station",
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF777777),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatTicketDateTime(ticket.inDate, ticket.inTime),
                  style: GoogleFonts.montserrat(
                    color: Color(0xFF0A0000),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              isPaid ? "Paid" : "Unpaid",
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color:
                    isPaid ? const Color(0xFF1FC16B) : const Color(0xFFFB3748),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
