/// Tanggal kalender tanpa jam dan zona waktu.
///
/// Engine bekerja dengan hari, bukan detik: "gajian 25 Nov", "jatuh tempo
/// 20 Nov". Memakai `DateTime` langsung rawan salah karena jam dan zona waktu
/// ikut terbandingkan. Di dalam, tanggal disimpan sebagai `DateTime.utc` tengah
/// malam, sehingga selisih hari selalu bilangan bulat.
final class LocalDate implements Comparable<LocalDate> {
  /// Tanggal di luar rentang dinormalisasi, mis. `LocalDate(2026, 2, 30)`
  /// menjadi 2 Maret 2026, seperti `DateTime`.
  factory LocalDate(int year, int month, int day) => LocalDate._(DateTime.utc(year, month, day));

  /// Ambil tanggal kalender dari [dateTime] menurut waktu lokalnya.
  factory LocalDate.fromDateTime(DateTime dateTime) =>
      LocalDate(dateTime.year, dateTime.month, dateTime.day);

  /// Hari terakhir di bulan [month] tahun [year].
  factory LocalDate.endOfMonth(int year, int month) => LocalDate(year, month + 1, 0);

  LocalDate._(this._utc);

  final DateTime _utc;

  int get year => _utc.year;
  int get month => _utc.month;
  int get day => _utc.day;

  /// 1 = Senin … 7 = Minggu, sama dengan [DateTime.weekday].
  int get weekday => _utc.weekday;

  bool get isWeekend => weekday == DateTime.saturday || weekday == DateTime.sunday;

  static int daysInMonth(int year, int month) => LocalDate.endOfMonth(year, month).day;

  LocalDate addDays(int days) => LocalDate(year, month, day + days);

  /// Jumlah hari dari [other] ke tanggal ini. Positif kalau tanggal ini lebih akhir.
  int differenceInDays(LocalDate other) => _utc.difference(other._utc).inDays;

  bool operator <(LocalDate other) => _utc.isBefore(other._utc);
  bool operator <=(LocalDate other) => !_utc.isAfter(other._utc);
  bool operator >(LocalDate other) => _utc.isAfter(other._utc);
  bool operator >=(LocalDate other) => !_utc.isBefore(other._utc);

  /// Tengah malam waktu lokal, untuk ditampilkan atau dibandingkan dengan
  /// waktu transaksi.
  DateTime toDateTime() => DateTime(year, month, day);

  /// Tengah malam UTC, untuk kolom database yang hanya berisi tanggal
  /// (jatuh tempo, mulai mencatat). Drift menyimpannya sebagai
  /// `YYYY-MM-DDT00:00:00.000Z`, sehingga tanggalnya tidak bergeser walau zona
  /// waktu HP berubah. Baca kembali dengan [LocalDate.fromDateTime].
  DateTime toUtcMidnight() => _utc;

  @override
  int compareTo(LocalDate other) => _utc.compareTo(other._utc);

  @override
  bool operator ==(Object other) => other is LocalDate && other._utc == _utc;

  @override
  int get hashCode => _utc.hashCode;

  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}
