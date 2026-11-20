import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/mitra_mobil_card.dart';
import '../widgets/rentra_scaffold.dart';
import 'payment_view.dart';
import 'pembayaran_berhasil_view.dart';

const _bulanPendek = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

const _bulanPanjang = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

String tanggalPendek(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')} ${_bulanPendek[d.month - 1]} ${d.year}';

String tanggalPanjang(DateTime d) =>
    '${d.day} ${_bulanPanjang[d.month - 1]} ${d.year}';

String jamWib(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} WIB';

class PesananData {
  const PesananData({
    required this.mobil,
    required this.nama,
    required this.telepon,
    required this.alamat,
    required this.ambil,
    required this.kembali,
    required this.hari,
    required this.total,
  });

  final MitraMobilData mobil;
  final String nama;
  final String telepon;
  final String alamat;
  final DateTime ambil;
  final DateTime kembali;
  final int hari;
  final int total;
}

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key, required this.mobil});

  final MitraMobilData mobil;

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _telepon = TextEditingController();
  final _alamat = TextEditingController();

  late DateTime _ambil;
  late DateTime _kembali;
  bool _buktiOk = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _ambil = DateTime(now.year, now.month, now.day, 10);
    _kembali = _ambil.add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _nama.dispose();
    _telepon.dispose();
    _alamat.dispose();
    super.dispose();
  }

  int get _hari {
    final a = DateTime(_ambil.year, _ambil.month, _ambil.day);
    final k = DateTime(_kembali.year, _kembali.month, _kembali.day);
    final d = k.difference(a).inDays;
    return d < 1 ? 1 : d;
  }

  int get _total => widget.mobil.harga * _hari;

  void _pesan(String teks) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(teks)));
  }

  Future<void> _pilihTanggal(bool ambil) async {
    final now = DateTime.now();
    final awal = DateTime(now.year, now.month, now.day);
    final saat = ambil ? _ambil : _kembali;
    final hasil = await showDatePicker(
      context: context,
      initialDate: saat.isBefore(awal) ? awal : saat,
      firstDate: awal,
      lastDate: DateTime(now.year + 1, now.month, now.day),
    );
    if (hasil == null) return;
    setState(() {
      if (ambil) {
        _ambil = DateTime(
            hasil.year, hasil.month, hasil.day, _ambil.hour, _ambil.minute);
      } else {
        _kembali = DateTime(
            hasil.year, hasil.month, hasil.day, _kembali.hour, _kembali.minute);
      }
    });
  }

  Future<void> _pilihJam(bool ambil) async {
    final saat = ambil ? _ambil : _kembali;
    final hasil = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(saat),
    );
    if (hasil == null) return;
    setState(() {
      if (ambil) {
        _ambil = DateTime(
            _ambil.year, _ambil.month, _ambil.day, hasil.hour, hasil.minute);
      } else {
        _kembali = DateTime(_kembali.year, _kembali.month, _kembali.day,
            hasil.hour, hasil.minute);
      }
    });
  }

  Future<void> _bukaPembayaran() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PaymentView()),
    );
    if (ok == true && mounted) setState(() => _buktiOk = true);
  }

  void _confirm() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (!_kembali.isAfter(_ambil)) {
      _pesan('Tanggal kembali harus setelah tanggal ambil');
      return;
    }
    if (!_buktiOk) {
      _pesan('Pilih metode pembayaran dan unggah bukti dulu');
      return;
    }
    final data = PesananData(
      mobil: widget.mobil,
      nama: _nama.text.trim(),
      telepon: _telepon.text.trim(),
      alamat: _alamat.text.trim(),
      ambil: _ambil,
      kembali: _kembali,
      hari: _hari,
      total: _total,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PembayaranBerhasilView(pesanan: data),
      ),
    );
  }

  InputDecoration _dekor(String hint) {
    const garis = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(6)),
      borderSide: BorderSide(color: Color(0x80FFFFFF)),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
      isDense: true,
      filled: true,
      fillColor: const Color(0x26FFFFFF),
      errorStyle: const TextStyle(fontSize: 9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      border: garis,
      enabledBorder: garis,
      focusedBorder: garis.copyWith(
        borderSide: const BorderSide(color: Color(0xFFFFFFFF)),
      ),
    );
  }

  Widget _field(
    String hint,
    TextEditingController c, {
    TextInputType? type,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: c,
        keyboardType: type,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 11),
        decoration: _dekor(hint),
        validator: validator ??
            (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
      ),
    );
  }

  Widget _judul(String teks) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Text(
          teks,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  Widget _kotak(IconData icon, String teks, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0x26FFFFFF),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0x80FFFFFF)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                teks,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 11),
              ),
            ),
            Icon(icon, size: 14, color: AppColors.textPrimary),
          ],
        ),
      ),
    );
  }

  Widget _baris(String label, String isi, {bool tebal = false}) {
    final gaya = TextStyle(
      color: AppColors.textPrimary,
      fontSize: 11,
      fontWeight: tebal ? FontWeight.w700 : FontWeight.w400,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: gaya), Text(isi, style: gaya)],
    );
  }

  Widget _rowTanggal(String label, bool ambil) {
    final saat = ambil ? _ambil : _kembali;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 10),
          ),
        ),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _kotak(Icons.calendar_today_outlined, tanggalPendek(saat),
                  () => _pilihTanggal(ambil)),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _kotak(
                  Icons.schedule, jamWib(saat), () => _pilihJam(ambil)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _ringkasMobil() {
    final m = widget.mobil;
    Widget baris(String t) => Text(
          t,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              color: AppColors.textPrimary, fontSize: 9, height: 1.4),
        );
    return GlassCard(
      radius: 6,
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 80,
              height: 56,
              child: Image.asset(
                'assets/images/car1.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: const Color(0xFF1F2937)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.nama,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                baris('Merk Mobil : ${m.merk}'),
                baris('Nomor Polisi : ${m.nopol}'),
                baris('Spesifikasi : ${m.spesifikasi}'),
                baris('Kapasitas penumpang : ${m.kapasitas}'),
                baris('Jenis BBM : ${m.bbm}'),
                const Text(
                  'Harga tidak termasuk BBM',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 8),
                ),
                Text(
                  '${rupiah(m.harga)} / hari',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RentraScaffold(
      title: 'CHECKOUT PEMESANAN',
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ringkasMobil(),
                    _judul('Data Pemesanan'),
                    _field('Nama Lengkap', _nama),
                    _field(
                      'No. Telepon',
                      _telepon,
                      type: TextInputType.phone,
                      validator: (v) => (v == null || v.trim().length < 10)
                          ? 'Nomor telepon tidak valid'
                          : null,
                    ),
                    _field('Alamat', _alamat),
                    _judul('Tanggal Sewa'),
                    _rowTanggal('Tanggal Ambil:', true),
                    const SizedBox(height: 10),
                    _rowTanggal('Tanggal Kembali:', false),
                    const SizedBox(height: 14),
                    GlassCard(
                      radius: 6,
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          _baris(
                            '${rupiah(widget.mobil.harga)} x $_hari Hari',
                            rupiah(_total),
                          ),
                          const Divider(color: Color(0x40FFFFFF), height: 14),
                          _baris('Total Bayar', rupiah(_total), tebal: true),
                        ],
                      ),
                    ),
                    _judul('Metode Pembayaran'),
                    GestureDetector(
                      onTap: _bukaPembayaran,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0x26FFFFFF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _buktiOk
                                ? const Color(0xFF4ADE80)
                                : const Color(0x80FFFFFF),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.account_balance_outlined,
                                size: 16, color: AppColors.textPrimary),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Transfer Bank',
                                style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 11),
                              ),
                            ),
                            Icon(
                              _buktiOk
                                  ? Icons.check_circle
                                  : Icons.chevron_right,
                              size: 18,
                              color: _buktiOk
                                  ? const Color(0xFF4ADE80)
                                  : AppColors.textPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_buktiOk)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          'Bukti pembayaran sudah diunggah',
                          style: TextStyle(
                              color: Color(0xFF4ADE80), fontSize: 9),
                        ),
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SmallButton(
                label: 'Cancel',
                color: const Color(0xFFEF4444),
                onTap: () => Navigator.pop(context),
              ),
              SmallButton(label: 'Confirm', onTap: _confirm),
            ],
          ),
        ],
      ),
    );
  }
}