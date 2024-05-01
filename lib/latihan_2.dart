import 'package:flutter/material.dart'; // Import paket flutter untuk membangun UI
import 'package:http/http.dart' as http; // Import paket http untuk melakukan permintaan HTTP
import 'dart:convert'; // Import pustaka dart:convert untuk mengonversi JSON

void main() {
  runApp(const MyApp()); // Fungsi utama yang memulai aplikasi Flutter
}

// Digunakan untuk menampung data hasil pemanggilan API
class Activity {
  String aktivitas; // Atribut untuk menampung aktivitas dari API
  String jenis; // Atribut untuk menampung jenis aktivitas dari API

  Activity({required this.aktivitas, required this.jenis}); //constructor

  //map dari json ke atribut
  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      aktivitas: json['activity'], //mengambil activity dari JSON
      jenis: json['type'], // mengambil nilai type dari JSON
    );
  }
}
// kelas turunan dari StatefulWidget
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyAppState(); // membuat instance dari MyAppState
  }
}
// Kelas untuk mengelola state dari widget MyApp
class MyAppState extends State<MyApp> {
  late Future<Activity> futureActivity; //menampung hasil

  //URL API
  String url = "https://www.boredapi.com/api/activity";

// Fungsi untuk menginisialisasi futureActivity
  Future<Activity> init() async {
    return Activity(aktivitas: "", jenis: ""); // Mengembalikan instance Activity dengan nilai awal
  }

  //fetch data, untuk melakukan permintaan HTTP ke API
  Future<Activity> fetchData() async {
    final response = await http.get(Uri.parse(url)); // Melakukan permintaan HTTP dari URL API
    if (response.statusCode == 200) {
      // jika server mengembalikan 200 OK (berhasil),
      // parse json, mengembalikan instance Activity dari JSON
      return Activity.fromJson(jsonDecode(response.body));
    } else {
      // jika gagal (bukan  200 OK),
      // lempar exception
      throw Exception('Gagal load');
    }
  }

  @override
  void initState() { 
    super.initState(); // Panggil initState() dari superclass State
    futureActivity = init(); // Menginisialisasi futureActivity dengan nilai awal
  }

  @override
  Widget build(Object context) { 
    return MaterialApp( //Widget aplikasi material App
        home: Scaffold( // Scaffold sebagai struktur dasar aplikasi
      body: Center( //membuat berada di center atau tengah
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [ // Membuat tata letak vertikal untuk menempatkan daftar widget dalam kolom
          Padding(
            padding: EdgeInsets.only(bottom: 20), // Padding bawah sebesar 20
            child: ElevatedButton( // Tombol yang dapat ditekan
              onPressed: () { // Ketika tombol ditekan
                setState(() { // Memanggil setState untuk memperbarui tampilan
                  futureActivity = fetchData(); //Mengambil data aktivitas baru dari API
                });
              },
              child: Text("Saya bosan ..."), //tesk pada button tombol
            ),
          ),
          FutureBuilder<Activity>( // Membangun UI berdasarkan futureActivity
            future: futureActivity,// Menggunakan futureActivity sebagai data
            builder: (context, snapshot) { // Builder untuk membangun UI
              if (snapshot.hasData) { // Jika data sudah tersedia
                return Center( //menampilkan data di tengah
                    child: Column( // Kolom untuk menampilkan data secara vertikal
                        mainAxisAlignment: MainAxisAlignment.center, // Widget utama diletakkan di tengah vertikal
                        children: [ // Daftar widget dalam kolom
                      Text(snapshot.data!.aktivitas), // Menampilkan aktivitas
                      Text("Jenis: ${snapshot.data!.jenis}") // Menampilkan jenis aktivitas
                    ]));
              } else if (snapshot.hasError) { // Jika terjadi error
                return Text('${snapshot.error}'); // Menampilkan pesan error
              }
              // default: loading spinner.
              return const CircularProgressIndicator(); // Menampilkan indikator loading
            },
          ),
        ]),
      ),
    ));
  }
}