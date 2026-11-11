# myportofolio_mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### Tugas 7

1. Jelaskan apa yang dimaksud dengan widget tree pada Flutter dan bagaimana hubungan induk-anak (parent-child) bekerja antar-widget!
---------------------------------------------------------------------------------------------------
Widget tree pada flutter adalah sebuah struktur hierarki bertingkat untuk widgets (teks, gambar, tata letak, hingga tombol, hampir semua elemen pada flutter adalah widget). Widget tree ini menghubungkan elemen-elemen tersebut secara bertingkat untuk membentuk tampilan aplikasi yang utuh.

Hubungan induk-anak itu ada 3 aturan, yaitu:
- Constraint diwarisi anak: Induk mengirimkan batas ukuran (minimal & maximal lebar dan tinggi) kepada anak
- Ukuran dikirim dari anak ke induk sesuai constraint tersebut
- Induk menentukan posisi koordinat (x,y) dari anak berdasarkan ukuran anaknya.




2. Sebutkan semua widget yang kamu gunakan dalam proyek ini dan jelaskan fungsinya masing-masing!
---------------------------------------------------------------------------------------------------
Custom widgets:
MyApp: Widget root aplikasi (StatelessWidget) yang menyiapkan MaterialApp, judul, dan tema.

MyHomePage: Halaman utama portofolio (StatelessWidget) yang menyusun seluruh tampilan.

InfoCard: Kartu informasi yang menampilkan title dan content (NPM, nama, kelas).

ItemCard: Kartu tombol aksi berisi ikon dan teks, berwarna sesuai item.color, dan memunculkan SnackBar saat ditekan.

Widget bawaan Flutter:

MaterialApp: Widget dasar aplikasi bergaya Material Design: mengatur tema, judul, dan halaman awal (home).

Scaffold: Kerangka halaman: menyediakan tempat untuk AppBar, body, dan menjadi tempat SnackBar muncul.

AppBar: Bar di bagian atas halaman, berisi judul “MyPortfolio”.

SingleChildScrollView: Membuat isi halaman bisa di-scroll, sehingga tidak terjadi overflow.

Padding: Memberi jarak di sekeliling widget anaknya.

Column: Menyusun widget anak secara vertikal.

Row: Menyusun widget anak secara horizontal (dipakai untuk tiga InfoCard).

Center: Menempatkan widget anak di tengah.

SizedBox: Memberi ruang kosong dengan ukuran tertentu (jarak antar widget).

GridView.count: Menampilkan ItemCard dalam kisi dengan jumlah kolom tetap (3 kolom).

Card: Kontainer bergaya kartu dengan bayangan, dasar dari InfoCard.

Container: Kotak serbaguna untuk mengatur ukuran dan padding (lebar InfoCard, isi ItemCard).

Material: Menyediakan permukaan Material dengan warna dan sudut membulat untuk ItemCard.

InkWell: Membuat area bisa ditekan dan memberi efek riak (ripple), serta menangani onTap.

Icon: Menampilkan ikon pada tiap tombol (folder, add, logout, dan lainnya).

Text: Menampilkan teks: judul, isi kartu, pesan sambutan, dan nama tombol.

SnackBar: Pesan singkat di bagian bawah layar: “Kamu telah menekan tombol [Nama]!”.

ScaffoldMessenger: Mengelola dan menampilkan SnackBar (showSnackBar, hideCurrentSnackBar).

CircleAvatar: Foto profil berbentuk lingkaran 


3. Apa fungsi dari widget MaterialApp? Jelaskan mengapa widget ini umumnya digunakan sebagai root widget pada aplikasi Flutter!
---------------------------------------------------------------------------------------------------
MaterialApp itu ibarat pondasi utama aplikasi Flutter yang bertugas menyiapkan semua aturan dasar,mulai dari gaya desain khas Google (Material Design), tema warna, sistem navigasi antar-halaman, sampai pengaturan bahasa dan ukuran layar. Widget ini ditempatkan di posisi paling atas (root) karena dia menyediakan berbagai layanan penting dari balik layar yang sangat dibutuhkan oleh widget-widget di bawahnya; tanpa MaterialApp di bagian paling luar, fitur-fitur penting seperti tombol navigasi berpindah halaman, pop-up dialog, hingga widget tata letak seperti Scaffold tidak akan bisa berjalan atau malah bikin aplikasi error.


4. Jelaskan perbedaan antara StatelessWidget dan StatefulWidget! Kapan kita sebaiknya memilih StatelessWidget dan kapan harus menggunakan StatefulWidget?
---------------------------------------------------------------------------------------------------
Bedanya simpel: StatelessWidget itu UI-nya statis (gak punya state yang bisa berubah setelah dibuat), sedangkan StatefulWidget punya state internal yang dinamis dan bisa berubah-ubah saat aplikasi jalan. Kamu pakai StatelessWidget waktu tampilannya cuma buat mejang data doang dan gak bakal berubah pas di-klik, contohnya kaya teks judul, logo, icon, atau tombol statis. Tapi kalau tampilannya butuh respon langsung dari interaksi pengguna—misalnya centang checkbox, ngetik di kolom formulir, nambah angka counter, atau ngambil data dari API, di situlah kamu wajib pakai StatefulWidget karena butuh fungsi setState() buat ngerender ulang UI-nya.


5. Apa itu BuildContext dan mengapa penting di Flutter? Bagaimana penggunaannya di dalam metode build?
---------------------------------------------------------------------------------------------------
BuildContext itu ibaratnya alamat atau peta lokasi sebuah widget di dalam struktur Widget Tree. Di Flutter, ini penting banget karena widget anak butuh tahu dia lagi berdiri di mana supaya bisa "minta tolong" atau ngambil data dari widget induk di atasnya—seperti mau cek warna tema aplikasi, tau ukuran layar HP, atau mau pindah halaman lewat Navigator. Di dalam method build(BuildContext context), parameter context ini dipassing supaya Flutter tahu persis bagian UI mana yang sedang dibangun dan di mana posisi widget tersebut berada di dalam hierarki pohonnya.


6. Jelaskan konsep hot reload di Flutter dan apa perbedaannya dengan hot restart! Kapan kita tidak bisa hanya mengandalkan hot reload dan harus melakukan hot restart atau full restart?
---------------------------------------------------------------------------------------------------
Hot reload itu fitur super cepat Flutter buat nyuntik kode baru langsung ke dalam mesin Dart tanpa mematikan aplikasi dan tanpa mereset data (state) yang lagi jalan, jadi apa yang lagi kamu ketik langsung kelihatan di layar dalam hitungan detik. Bedanya sama hot restart, kalau hot restart dia bakal ngebersihin semua state dari awal (aplikasi di-refresh total kaya pencet tombol F5 di browser) walau booting-nya masih lumayan cepat. Nah, kamu gak bisa cuma ngandalin hot reload dan wajib hukumnya buat hot restart atau full restart waktu kamu mengubah nilai variabel initState(), ngubah variabel global, ngubah struktur konstruktor, nambah aset/gambar baru di pubspec.yaml, atau pas nyambungin plugin/package native (seperti edit kode Android/iOS).


AI Disclosure: Saya menggunakan Claude untuk membantu mengerjakan tugas ini. Saya menggunakannya untuk membantu menjawab pertanyaan refleksi dan troubleshooting jika ada eror.

Claude: https://claude.ai/share/ff5adae8-e1a4-40c4-91cc-73907d251e51