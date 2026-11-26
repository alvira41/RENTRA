import 'package:flutter/material.dart';
import '../../controllers/order_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/controllers/app_controllers.dart';
import '../../core/utils/formatter.dart';
import '../widgets/add_options_dialog.dart';
import '../widgets/admin_bottom_bar.dart';

class _ReturnItem {
  const _ReturnItem({
    required this.idOrder,
    required this.idOrderDetail,
    required this.transactionCode,
    required this.carName,
    required this.customer,
    required this.phone,
    required this.startDate,
    required this.endDate,
    required this.price,
    required this.image,
    required this.status,
  });

  final int idOrder;
  final int idOrderDetail;
  final String transactionCode;
  final String carName;
  final String customer;
  final String phone;
  final String startDate;
  final String endDate;
  final String price;
  final String image;
  final String status;
}

class ReturnView extends StatefulWidget {
  const ReturnView({super.key, this.idOrder});

  final int? idOrder;

  @override
  State<ReturnView> createState() => _ReturnViewState();
}

class _ReturnViewState extends State<ReturnView> {
  late final OrderController _order;
  late final TextEditingController _dendaController;
  int? _idOrder;
  DateTime _tanggal = DateTime.now();
  List<_ReturnItem> _items = [];
  final Set<int> _selected = {};
  bool _dimuat = false;

  @override
  void initState() {
    super.initState();
    _order = AppControllers.of(context).order;
    _dendaController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_dimuat) return;
    _dimuat = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (widget.idOrder != null) {
      _idOrder = widget.idOrder;
    } else if (args is int) {
      _idOrder = args;
    } else if (args is Map) {
      final rawId = args['idOrder'];
      _idOrder = rawId is int ? rawId : null;
      final rawDenda = args['dendaPerHari'];
      if (rawDenda != null) _dendaController.text = rawDenda.toString();
    }

    _muat();
  }

  @override
  void dispose() {
    _dendaController.dispose();
    super.dispose();
  }

  Future<void> _muat() async {
    if (_idOrder != null) {
      final ok = await _order.loadOrderDetail(_idOrder!);
      final row = _order.selectedOrder;
      if (!mounted) return;
      if (!ok || row == null || (row['id_order'] as num?)?.toInt() != _idOrder) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_order.errorMessage ?? 'Detail pesanan tidak ditemukan'),
          ),
        );
        return;
      }
      setState(() => _items = _dariOrder(row));
      return;
    }

    final ongoingOk = await _order.loadAllOrders(status: 'ongoing');
    final ongoing = List<Map<String, dynamic>>.from(_order.orders);
    final confirmedOk = await _order.loadAllOrders(status: 'confirmed');
    if (!mounted) return;
    final semua = [...ongoing, ..._order.orders];
    setState(() {
      _items = semua.expand(_dariOrder).toList();
    });
    if (!ongoingOk || !confirmedOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_order.errorMessage ?? 'Gagal memuat pesanan aktif'),
        ),
      );
    }
  }

  List<_ReturnItem> _dariOrder(Map<String, dynamic> row) {
    final status = row['status']?.toString() ?? '';
    if (status != 'confirmed' && status != 'ongoing') return [];

    final user = (row['user'] as Map?)?.cast<String, dynamic>();
    final details = List<Map<String, dynamic>>.from(
      (row['order_details'] as List?) ?? const [],
    );

    return details.map((detail) {
      final katalog = (detail['katalog'] as Map?)?.cast<String, dynamic>();
      final mulai = DateTime.tryParse(detail['tanggal_pinjam']?.toString() ?? '');
      final kembali = DateTime.tryParse(detail['tanggal_kembali']?.toString() ?? '');
      return _ReturnItem(
        idOrder: (row['id_order'] as num?)?.toInt() ?? 0,
        idOrderDetail: (detail['id_order_details'] as num?)?.toInt() ?? 0,
        transactionCode: row['transaction_code']?.toString() ?? '-',
        carName: katalog?['nama_mobil']?.toString() ?? '-',
        customer: user?['nama_user']?.toString() ?? '-',
        phone: user?['no_telepon_user']?.toString() ?? '-',
        startDate: Formatter.tanggal(mulai),
        endDate: Formatter.tanggal(kembali),
        price: Formatter.rupiah(katalog?['price'] as num?),
        image: katalog?['image']?.toString() ?? '',
        status: status,
      );
    }).toList();
  }

  void _toggle(_ReturnItem item) {
    setState(() {
      if (_selected.contains(item.idOrderDetail)) {
        _selected.remove(item.idOrderDetail);
      } else {
        _selected.add(item.idOrderDetail);
      }
    });
  }

  Future<void> _pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (hasil == null || !mounted) return;
    setState(() => _tanggal = hasil);
  }

  Future<void> _onReturn() async {
    final terpilih = _items.where((e) => _selected.contains(e.idOrderDetail)).toList();
    if (terpilih.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih mobil yang dikembalikan')),
      );
      return;
    }

    final ids = terpilih.map((e) => e.idOrder).toSet();
    final dendaPerHari = num.tryParse(_dendaController.text.trim());
    var sukses = 0;
    String? gagal;
    for (final id in ids) {
      final ok = await _order.completeOrder(
        id,
        tanggalKembaliAktual: _tanggal,
        dendaPerHari: dendaPerHari,
        refreshStatus: 'ongoing',
      );
      if (ok) {
        sukses++;
      } else {
        gagal = _order.errorMessage ?? 'Pengembalian gagal diproses';
        break;
      }
    }

    if (!mounted) return;
    if (sukses > 0) {
      setState(() {
        _items.removeWhere((e) => ids.contains(e.idOrder));
        _selected.clear();
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sukses > 0
              ? '$sukses pengembalian diproses'
              : gagal ?? 'Pengembalian gagal diproses',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final sidePadding = width * 0.06;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: AdminBottomBar(
        currentIndex: 1,
        onAddTap: () => showAddOptionsDialog(context),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/images/background.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(sidePadding, 16, sidePadding, 0),
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: width * 0.3,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(sidePadding, 18, sidePadding, 8),
                  child: const Text(
                    'Pengembalian',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(sidePadding, 0, sidePadding, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _pilihTanggal,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0x26FFFFFF),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0x40FFFFFF)),
                            ),
                            child: Text(
                              'Aktual : ${Formatter.tanggal(_tanggal)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 32,
                          child: TextField(
                            controller: _dendaController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 9,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Denda /hari (opsional)',
                              hintStyle: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 9,
                              ),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 10),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide:
                                    BorderSide(color: Color(0x40FFFFFF)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide:
                                    BorderSide(color: Color(0xFF60A5FA)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListenableBuilder(
                    listenable: _order,
                    builder: (context, _) {
                      if (_order.isLoading && _items.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return _items.isEmpty
                          ? const Center(
                              child: Text(
                                'Tidak ada mobil yang perlu dikembalikan',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.fromLTRB(
                                sidePadding,
                                8,
                                sidePadding,
                                12,
                              ),
                              itemCount: _items.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = _items[index];
                                return _ReturnCard(
                                  item: item,
                                  checked: _selected.contains(item.idOrderDetail),
                                  onToggle: () => _toggle(item),
                                );
                              },
                            );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(sidePadding, 4, sidePadding, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _PillButton(
                        label: 'Cancel',
                        fill: const Color(0x33EF4444),
                        border: const Color(0xFFEF4444),
                        textColor: const Color(0xFFEF4444),
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      _PillButton(
                        label: 'Kembali',
                        fill: const Color(0x333B82F6),
                        border: const Color(0xFF3B82F6),
                        textColor: const Color(0xFF60A5FA),
                        onTap: _onReturn,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReturnCard extends StatelessWidget {
  const _ReturnCard({
    required this.item,
    required this.checked,
    required this.onToggle,
  });

  final _ReturnItem item;
  final bool checked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final imageWidth = MediaQuery.of(context).size.width * 0.28;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0x26FFFFFF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: checked ? const Color(0xFF60A5FA) : const Color(0x40FFFFFF),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: imageWidth,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 1.5,
                  child: item.image.isEmpty
                      ? Image.asset(
                          'assets/images/car1.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: const Color(0xFF1F2937)),
                        )
                      : Image.network(
                          item.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: const Color(0xFF1F2937)),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.carName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _DetailLine(label: 'Kode', value: item.transactionCode),
                  _DetailLine(
                    label: 'Status',
                    value: Formatter.statusOrder(item.status),
                  ),
                  _DetailLine(label: 'Nama', value: item.customer),
                  _DetailLine(label: 'No telepon', value: item.phone),
                  _DetailLine(label: 'Tanggal sewa', value: item.startDate),
                  _DetailLine(label: 'Tanggal kembali', value: item.endDate),
                  const SizedBox(height: 6),
                  Text(
                    item.price,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              checked
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$label : $value',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 9,
        height: 1.5,
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.fill,
    required this.border,
    required this.textColor,
    required this.onTap,
  });

  final String label;
  final Color fill;
  final Color border;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
