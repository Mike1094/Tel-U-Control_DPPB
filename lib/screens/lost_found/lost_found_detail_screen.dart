import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/lost_found.dart';
import '../../services/lost_found_service.dart';
import 'lost_found_form_screen.dart';

class LostFoundDetailScreen extends StatelessWidget {
  final LostFound item;

  const LostFoundDetailScreen({super.key, required this.item});

  Future<void> _deleteItem(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Hapus "${item.namaBarang}"?'),
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

    if (confirmed == true && item.id != null && context.mounted) {
      try {
        await LostFoundService.delete(item.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (context.mounted) {
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
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');
    final isLost = item.jenis == 'hilang';
    final color = isLost ? Colors.red : Colors.green;
    final icon = isLost ? Icons.search_off : Icons.inventory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
        backgroundColor: const Color(0xFFE4002B),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LostFoundFormScreen(item: item),
                ),
              );
              if (result == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteItem(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFE4002B),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isLost ? 'BARANG HILANG' : 'BARANG TEMUAN',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item.namaBarang,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.lokasi,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    title: 'Deskripsi',
                    icon: Icons.description,
                    child: Text(
                      item.deskripsi,
                      style: const TextStyle(fontSize: 15, height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSection(
                    title: 'Waktu Pelaporan',
                    icon: Icons.access_time,
                    child: Text(
                      item.createdAt != null
                          ? dateFormat.format(item.createdAt!)
                          : '-',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  if (item.status != null) ...[
                    const SizedBox(height: 20),
                    _buildSection(
                      title: 'Status',
                      icon: Icons.info_outline,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(item.status!).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.status!,
                          style: TextStyle(
                            color: _getStatusColor(item.status!),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (item.foto != null && item.foto!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _buildSection(
                      title: 'Foto',
                      icon: Icons.photo,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          item.foto!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 150,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
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
      case 'dikembalikan':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
