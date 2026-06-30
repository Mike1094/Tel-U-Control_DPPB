import 'package:flutter/material.dart';
import '../../models/lost_found.dart';
import '../../services/lost_found_service.dart';

class LostFoundFormScreen extends StatefulWidget {
  final LostFound? item;
  final String? initialJenis;

  const LostFoundFormScreen({super.key, this.item, this.initialJenis});

  @override
  State<LostFoundFormScreen> createState() => _LostFoundFormScreenState();
}

class _LostFoundFormScreenState extends State<LostFoundFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaBarangController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _deskripsiController = TextEditingController();
  String _selectedJenis = 'hilang';
  bool _isLoading = false;

  bool get isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _namaBarangController.text = widget.item!.namaBarang;
      _lokasiController.text = widget.item!.lokasi;
      _deskripsiController.text = widget.item!.deskripsi;
      _selectedJenis = widget.item!.jenis;
    } else if (widget.initialJenis != null) {
      _selectedJenis = widget.initialJenis!;
    }
  }

  @override
  void dispose() {
    _namaBarangController.dispose();
    _lokasiController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final item = LostFound(
        id: widget.item?.id,
        jenis: _selectedJenis,
        namaBarang: _namaBarangController.text.trim(),
        lokasi: _lokasiController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
      );

      if (isEdit) {
        await LostFoundService.update(widget.item!.id!, item);
      } else {
        await LostFoundService.create(item);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? 'Data berhasil diperbarui'
                  : 'Data berhasil dibuat',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLost = _selectedJenis == 'hilang';
    final color = isLost ? Colors.red : Colors.green;
    final icon = isLost ? Icons.search_off : Icons.inventory;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Data' : 'Laporan Baru'),
        backgroundColor: const Color(0xFFE4002B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Card(
                elevation: 0,
                color: color.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(icon, color: color, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isLost ? 'Laporan Barang Hilang' : 'Laporan Barang Temuan',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const Text(
                              'Isi form berikut dengan lengkap',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Jenis Selection
              const Text(
                'Jenis Laporan',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildJenisOption(
                      'hilang',
                      'Barang Hilang',
                      Icons.search_off,
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildJenisOption(
                      'ditemukan',
                      'Barang Temuan',
                      Icons.inventory,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Form Fields
              TextFormField(
                controller: _namaBarangController,
                decoration: InputDecoration(
                  labelText: 'Nama Barang',
                  hintText: 'Contoh: Dompet Hitam',
                  prefixIcon: const Icon(Icons.inventory_2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2C2C2C)
                      : Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama barang tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lokasiController,
                decoration: InputDecoration(
                  labelText: isLost ? 'Lokasi Terakhir' : 'Lokasi Ditemukan',
                  hintText: 'Contoh: Kantin Gedung A',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2C2C2C)
                      : Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lokasi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deskripsiController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  hintText: 'Jelaskan ciri-ciri barang...',
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 80),
                    child: Icon(Icons.description),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2C2C2C)
                      : Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE4002B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        isEdit ? 'Simpan Perubahan' : 'Kirim Laporan',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJenisOption(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedJenis == value;

    return InkWell(
      onTap: () => setState(() => _selectedJenis = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2C2C2C)
                  : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey[700],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
