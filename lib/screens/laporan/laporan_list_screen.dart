import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/laporan.dart';
import '../../services/laporan_service.dart';
import 'laporan_form_screen.dart';
import 'laporan_detail_screen.dart';

class LaporanListScreen extends StatefulWidget {
  const LaporanListScreen({super.key});

  @override
  State<LaporanListScreen> createState() => _LaporanListScreenState();
}

class _LaporanListScreenState extends State<LaporanListScreen> {
  List<Laporan> _laporanList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await LaporanService.getAll();
      setState(() {
        _laporanList = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteLaporan(Laporan laporan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Hapus laporan "${laporan.judul}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && laporan.id != null) {
      try {
        await LaporanService.delete(laporan.id!);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Laporan berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Kerusakan'),
        backgroundColor: const Color(0xFFE4002B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _laporanList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada laporan kerusakan',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _laporanList.length,
                        itemBuilder: (context, index) {
                          final laporan = _laporanList[index];
                          return _buildLaporanCard(laporan);
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LaporanFormScreen()),
          );
          if (result == true) {
            _loadData();
          }
        },
        backgroundColor: const Color(0xFFE4002B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildLaporanCard(Laporan laporan) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LaporanDetailScreen(laporan: laporan),
            ),
          );
          if (result == true) {
            _loadData();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.build_circle,
                      color: Colors.orange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          laporan.judul,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                laporan.lokasi,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LaporanFormScreen(laporan: laporan),
                          ),
                        );
                        if (result == true) {
                          _loadData();
                        }
                      } else if (value == 'delete') {
                        _deleteLaporan(laporan);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Hapus', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (laporan.deskripsi.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  laporan.deskripsi,
                  style: TextStyle(color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (laporan.createdAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  dateFormat.format(laporan.createdAt!),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
              if (laporan.status != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(laporan.status!).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    laporan.status!,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(laporan.status!),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'menunggu':
        return Colors.orange;
      case 'proses':
      case 'diproses':
        return Colors.blue;
      case 'selesai':
      case 'done':
        return Colors.green;
      case 'ditolak':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
