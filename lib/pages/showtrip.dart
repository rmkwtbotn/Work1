import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/config.dart';
import 'package:flutter_application_1/model/response/trip_get_res.dart';
import 'package:flutter_application_1/pages/login.dart';
import 'package:flutter_application_1/pages/profile.dart';
import 'package:flutter_application_1/pages/trip.dart';
import 'package:http/http.dart' as http;

class ShowTripPage extends StatefulWidget {
  final int? cid;
  const ShowTripPage({super.key, required this.cid});

  @override
  State<ShowTripPage> createState() => _ShowTripPageState();
}

class _ShowTripPageState extends State<ShowTripPage> {
  String url = '';
  List<TripGetRes> tripGetResponses = [];
  List<TripGetRes> filteredTrips = [];
  String selectedZone = 'all';
  late Future<void> loadData;

  @override
  void initState() {
    super.initState();
    loadData = loadDataAsync();
  }

  Future<void> loadDataAsync() async {
    var config = await Configuration.getConfig();
    url = config['apiEndpoint'];
    var res = await http.get(Uri.parse('$url/trips'));
    dev.log(res.body);
    tripGetResponses = tripGetResFromJson(res.body);
    filteredTrips = tripGetResponses;
    dev.log(tripGetResponses.length.toString());
  }

  void filterTrips(String zone) {
    setState(() {
      selectedZone = zone;
      if (zone == 'all') {
        filteredTrips = tripGetResponses;
      } else {
        filteredTrips = tripGetResponses
            .where(
              (trip) =>
                  trip.destinationZone.toLowerCase() == zone.toLowerCase(),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการทริป'),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              dev.log(value);
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(idx: widget.cid ?? 0),
                  ),
                );
              } else if (value == 'logout') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const loginPage()),
                  (Route<dynamic> route) => false,
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Text('ข้อมูลส่วนตัว'),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text('ออกจากระบบ'),
              ),
            ],
          ),
        ],
      ),
      body: FutureBuilder(
        future: loadData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 10.0, right: 10, left: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text("ปลายทาง"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilledButton(
                          onPressed: () => filterTrips('all'),
                          child: const Text('ทั้งหมด'),
                        ),
                        FilledButton(
                          onPressed: () => filterTrips('เอเชีย'),
                          child: const Text('เอเชีย'),
                        ),
                        FilledButton(
                          onPressed: () => filterTrips('ยุโรป'),
                          child: const Text('ยุโรป'),
                        ),
                        FilledButton(
                          onPressed: () =>
                              filterTrips('เอเชียตะวันออกเฉียงใต้'),
                          child: const Text('อาเซียน'),
                        ),
                        FilledButton(
                          onPressed: () => filterTrips('ประเทศไทย'),
                          child: const Text('ประเทศไทย'),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredTrips.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 150,
                                    height: 120,
                                    child: Image.network(
                                      filteredTrips[index].coverimage,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return const Icon(Icons.error);
                                          },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      filteredTrips[index].name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      'Country: ${filteredTrips[index].country}',
                                    ),
                                    Text(
                                      'Duration: ${filteredTrips[index].duration}',
                                    ),
                                    Text(
                                      'Price: ${filteredTrips[index].price}',
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: FilledButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => TripPage(
                                                idx: filteredTrips[index].idx,
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'รายละเอียดเพิ่มเติม',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
