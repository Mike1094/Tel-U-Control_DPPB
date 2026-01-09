import 'package:flutter/material.dart';
import '../../models/laporan.dart';
import '../../services/laporan_service.dart';

class LaporanFormScreen extends StatefulWidget {
  final Laporan? laporan;

  const LaporanFormScreen({super.key, this.laporan});

  @override
  State<LaporanFormScreen> createState() => _LaporanFormScreenState();
}

class _LaporanFormScreenState extends State<LaporanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _deskripsiController = TextEditingController();
  bool _isLoading = false;

  bool get isEdit => widget.laporan != null;

  @override
  void initState() {
    super.initState();
    if (widget.laporan != null) {
      _judulController.text = widget.laporan!.judul;
      _lokasiController.text = widget.laporan!.lokasi;
      _deskripsiController.text = widget.laporan!.deskripsi;
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _lokasiController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final laporan = Laporan(
        id: widget.laporan?.id,
        judul: _judulController.text.trim(),
        lokasi: _lokasiController.text.trim(),
        deskripsi: _deskripsiController.text.trim(),
      );

      if (isEdit) {
        await LaporanService.update(widget.laporan!.id!, laporan);
      } else {
        await LaporanService.create(laporan);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? 'Laporan berhasil diperbarui'
                  : 'Laporan berhasil dibuat',
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
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Laporan' : 'Laporan Baru'),
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
                color: Colors.orange.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.build_circle, color: Colors.orange, size: 32),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Laporan Kerusakan Fasilitas',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
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
              // Form Fields
              TextFormField(
                controller: _judulController,
                decoration: InputDecoration(
                  labelText: 'Judul Laporan',
                  hintText: 'Contoh: AC Ruang 301 Rusak',
                  prefixIcon: const Icon(Icons.title),
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
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lokasiController,
                decoration: InputDecoration(
                  labelText: 'Lokasi',
                  hintText: 'Contoh: Gedung A Lantai 3',
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
                  hintText: 'Jelaskan detail kerusakan...',
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
}
