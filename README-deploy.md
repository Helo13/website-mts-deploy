# Deploy MTs Muhammadiyah 06 Purbalingga ke Hostinger

## 1. Upload
Upload **seluruh isi folder `upload/`** langsung ke `public_html/`.
Jangan upload folder `upload` sebagai subfolder.

Hasil akhir harus seperti ini:

```text
public_html/index.html
public_html/assets/
public_html/api/
public_html/config/
public_html/skl/
public_html/.htaccess
```

## 2. Buat database
1. Hostinger hPanel > Databases > MySQL.
2. Buat database, user, password.
3. Buka phpMyAdmin.
4. Pilih database baru.
5. Import `schema.sql`.
6. Edit `public_html/config/config.php`. Isi `DB_NAME` dan `DB_USER` sesuai hPanel. `DB_PASS` sudah diisi sesuai kredensial yang diberikan:

```php
define('DB_NAME', 'nama_database_hostinger');
define('DB_USER', 'user_database_hostinger');
define('DB_PASS', 'Musixga123');
define('BASE_URL', 'https://testing.mtsmusixga.sch.id');
define('SECRET_KEY', 'ganti-dengan-random-secret-minimal-64-karakter');
```

Jangan ubah `DB_HOST` kecuali Hostinger memberi host database berbeda.

Jangan pakai kredensial contoh. Jangan commit file config berisi password.

## 3. Buat akun admin
Schema tidak membuat admin default. Buat hash password dengan PHP:

```bash
php -r "echo password_hash('PASSWORD_ADMIN_KUAT', PASSWORD_DEFAULT), PHP_EOL;"
```

Lalu jalankan SQL di phpMyAdmin. Ganti nilai hash:

```sql
INSERT INTO users (nisn,name,email,password_hash,role,status)
VALUES ('admin','Administrator','email-anda@example.com','HASH_DARI_PHP','admin','active');
```

## 4. Tes
- `https://domain-anda.tld/`
- `https://domain-anda.tld/api/public.php`
- Login admin.
- Tes form PMB.
- Tes halaman kelulusan.

## 4a. Hapus data dummy / development

Ada **dua cara** (pilih salah satu):

**Cara A — Lewat Dashboard Admin (disarankan)**
1. Login admin di `/login`.
2. Masuk tab **Dashboard**.
3. Panel kanan bawah "Status sistem" > bagian **Zona Berbahaya**.
4. Klik **"🗑 Hapus Semua Data Dummy"** > konfirmasi.

Endpoint: `POST /api/delete_dummy_data.php` dengan header `Authorization: Bearer <token admin>`.
Script menghapus: `announcements`, `student_works`, `graduation`, dan seluruh user non-admin.
Akun admin utama (`admin@mtsmuh6pbg.sch.id`) **dipertahankan**.

**Cara B — Lewat phpMyAdmin**
Import file `cleanup_dummy_data.sql` (pilih database target, tanpa `USE`).

## 4b. Fitur baru di versi ini

| Fitur | Detail |
| --- | --- |
| Multi-file karya | Maks. **5 file**, **10MB per file**. Format JPG, PNG, WEBP, PDF. Path disimpan sebagai JSON array di kolom `student_works.media_url`. |
| Tombol Logout | Tombol **"Keluar"** di Navbar (desktop + mobile) dan di dalam form Area Siswa. Menghapus `auth_token`/`auth_role` dari localStorage lalu kembali ke Beranda. |
| Animasi scroll | Framer Motion fade-in-up + stagger pada Beranda, Profil, Berita, dan Karya Siswa. Menghormati preferensi "reduce motion" sistem. |
| URL gambar absolut | API kini mengembalikan URL absolut (`https://domain/uploads/...`). Frontend juga menormalkan path relatif lewat `fixImageUrl()` sehingga gambar tetap tampil di sub-route seperti `/berita/detail/1`. |
| Editor B / I / H | Tombol format memakai komponen `FormatToolbar` dan menyisipkan Markdown ke bagian textarea yang tersorot (`setRangeText`), bukan sekadar menambahkan di akhir. |
| Render Markdown | Halaman pembaca memakai `RichContent` yang merender `**tebal**`, `*miring*`, `### Subjudul`, `> kutipan`, daftar, dan kode menjadi HTML aman. Sintaks Markdown tidak lagi bocor ke layar. |
| Card berita | Deskripsi dipotong `line-clamp-3` dan tautan "Baca Selengkapnya" tidak lagi terdorong jauh ke bawah (tanpa `justify-between` + `margin-top:auto`). |
| Kolom `class_name` | Tabel `users` kini punya kolom `class_name` (7A-9C). Form **Daftar Akun Siswa** mewajibkan pilihan kelas, dan nama penulis tampil sebagai `Bajang - 9A`. |

> **Catatan kompatibilitas:** kolom `student_works.media_url` kini berisi JSON array untuk karya baru.
> Data lama (string biasa) tetap bisa dibaca — frontend otomatis mendeteksi formatnya.
> Untuk lebih aman, jalankan `cleanup_dummy_data.sql` bila tidak ada data lama yang perlu dipertahankan.

## 4c. Migrasi kolom `class_name` (penting)

Jika database **sudah ada** sebelum fitur kelas diperbarui, jalankan **satu** dari berikut:

**Cara A — Otomatis (disarankan)**
Kolom `class_name` dibuat otomatis oleh `ensure_class_column()` di `config/helpers.php` saat API diakses.
Cukup buka salah satu halaman (mis. `https://domain-anda.tld/api/public.php?type=announcements`) satu kali.
Lalu klik **Dashboard > Sinkronkan Data Kelas** di Admin CMS untuk mengisi kelas siswa lama dan memperbarui format nama penulis.

**Cara B — Manual via phpMyAdmin**
Import file `migration_class_name.sql` (pilih database target, tanpa `USE`).

> **Penting:** database Hostinger saat ini **belum** punya kolom `class_name`.
> Tanpa migrasi ini, form pendaftaran siswa akan gagal dan nama penulis tidak menampilkan kelas.

## 4d. Sinkronisasi nama penulis

Tersedia endpoint `POST /api/sync_class_name.php` (butuh token admin/guru) yang:
1. Menambah kolom `class_name` bila belum ada.
2. Mengisi kelasdefault `9A` untuk siswa lama yang belum punya kelas.
3. Memperbarui `announcements.author_name` menjadi format `Nama - Kelas`.

## 5. Catatan keamanan
- Aktifkan SSL Hostinger.
- Pastikan URL `BASE_URL` sama dengan domain aktif.
- Folder `config/` dan file `.sql` sudah diblokir `.htaccess`.
- Simpan PDF SKL di `public_html/skl/`; akses PDF hanya lewat endpoint token.
- Hapus file SQL dari `public_html` setelah import jika tidak diperlukan.
- Password PIN kelulusan harus diimpor sebagai hash melalui admin.

## Build ulang frontend
Build sudah tersedia dalam paket ini. Jika source perlu diubah:

```bash
cd frontend
npm install
npm run build
```

Salin isi `frontend/dist/` ke `upload/`, lalu upload ulang isi `upload/` ke `public_html/`.

<!-- trigger -->
