import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong2.dart';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';

class ComplaintsHeatmap extends StatelessWidget {
  const ComplaintsHeatmap({super.key});

  // 1. Apni MapTiler Key yahan paste karein
  final String maptilerKey = "YOUR_MAPTILER_API_KEY";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("City Complaint Heatmap"),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Column(
        children: [
          // Map View Section
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.redAccent, width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: FlutterMap(
                options: const MapOptions(
                  // Agra, India ki location example ke liye
                  initialCenter: LatLng(27.1751, 78.0421),
                  initialZoom: 13,
                ),
                children: [
                  // Maptiler Tiles Layer
                  TileLayer(
                    urlTemplate: "https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=$maptilerKey",
                    additionalOptions: {'key': maptilerKey},
                    userAgentPackageName: 'com.example.urban_flutter',
                  ),

                  // Heatmap/Complaint Zones Layer
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: const LatLng(27.1850, 78.0500),
                        radius: 800, // meters mein
                        useRadiusInMeter: true,
                        color: Colors.red.withOpacity(0.5),
                        borderStrokeWidth: 0,
                      ),
                      CircleMarker(
                        point: const LatLng(27.1700, 78.0400),
                        radius: 500,
                        useRadiusInMeter: true,
                        color: Colors.orange.withOpacity(0.5),
                        borderStrokeWidth: 0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Live Data List Section
          Expanded(
            flex: 1,
            child: FutureBuilder(
              future: http.get(Uri.parse(AppConstants.heatmapEndpoint)),
              builder: (context, snapshot) {
                // Connection checking
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Agar error aaye toh fallback data dikhayega
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text("High Intensity Zones",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    _buildZoneTile("Ward 12 (Fatehpur)", "85% Issues", Colors.red),
                    _buildZoneTile("Sector 4 (Industrial)", "42% Issues", Colors.orange),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper function for ListTiles
  Widget _buildZoneTile(String title, String subtitle, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(Icons.location_on, color: color, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }
}