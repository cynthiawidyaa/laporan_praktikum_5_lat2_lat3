import 'package:flutter/material.dart'; // Import paket flutter untuk membangun UI
import 'package:http/http.dart' as http; // Import paket http untuk melakukan permintaan HTTP
import 'dart:convert'; // Import pustaka dart:convert untuk mengonversi JSON

//Membuat kumpulan kelas untuk universitas
class University {
  final String name; // Atribut untuk menampung nama universitas
  final String website; // Atribut untuk menampung situs web universitas

  University({required this.name, required this.website}); // Konstruktor untuk kelas University

// Metode untuk mengonversi JSON menjadi instance dari kelas University
  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'] ?? '', // Mengambil nilai 'name' dari JSON
      website: json['web_pages'] != null && json['web_pages'].length > 0
          ? json['web_pages'][0] // Mengambil situs web dari JSON, jika ada
          : '', // Jika tidak ada situs web, atur nilai kosong
    );
  }
}

void main() {
  runApp(MyApp()); // Memulai aplikasi Flutter
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState(); // Membuat instance dari _MyAppState
}

class _MyAppState extends State<MyApp> {
  late Future<List<University>> futureUniversities; // Variabel untuk menyimpan hasil dari permintaan API

// Fungsi untuk mengambil data universitas dari API
  Future<List<University>> fetchUniversities() async {
    final response = await http.get(Uri.parse(
        'http://universities.hipolabs.com/search?country=Indonesia')); // Melakukan permintaan HTTP ke API

    if (response.statusCode == 200) { // Jika permintaan berhasil
      List<dynamic> data = json.decode(response.body); // Mendekode respons JSON
      return data.map((json) => University.fromJson(json)).toList(); // Mengonversi setiap objek JSON menjadi instance University
    } else { // Jika permintaan gagal
      throw Exception('Failed to load universities'); // Lemparkan exception
    }
  }

  @override
  void initState() {
    super.initState(); // Panggil metode initState() dari superclass
    futureUniversities = fetchUniversities(); // Memuat data universitas saat widget pertama kali dibuat
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menampilkan Universitas dan situs', // Judul aplikasi atau website
      home: Scaffold(
        appBar: AppBar( //appbar
          title: Text('Menampilkan Universitas dan situs'), //judul appbar
        ),
        body: Center( //menempatkan pada posisi tengah atau center
          child: FutureBuilder<List<University>>( 
            future: futureUniversities, //menggunakan fututebuilder untuk list university
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {  // Jika masih dalam proses pengambilan data
                return CircularProgressIndicator(); // Tampilkan indikator loading
              } else if (snapshot.hasError) { // Jika terjadi error saat mengambil data
                return Text('Error: ${snapshot.error}'); // Tampilkan pesan error
              } else if (snapshot.hasData) {  // Jika data sudah tersedia
                return ListView.builder( //memunculkan dengan list view
                  itemCount: snapshot.data!.length, // Jumlah item dalam ListView
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(border: Border.all()), //untuk border container
                      padding: const EdgeInsets.all(14), //padding didalam containernya
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, //atur kolom untuk tetap berada di tengah
                        children: [
                          Text(snapshot.data![index].name), //tampilkan nama universitas pada API
                          Text(snapshot.data![index].website), //tampilkan situs web universitas juga
                        ],
                      ),
                    );
                  },
                );
              } else { // Jika tidak ada data yang tersedia
                return Text('No data available'); // Tampilkan pesan bahwa tidak ada data
              }
            },
          ),
        ),
      ),
    );
  }
}
