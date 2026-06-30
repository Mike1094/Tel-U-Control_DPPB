import 'package:flutter/material.dart';
import '../../models/gate.dart';
import '../../models/traffic_update.dart';
import '../../services/gate_service.dart';
import '../../services/traffic_service.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<Gate> _gates = [];
  List<TrafficUpdate> _trafficUpdates = [];
  Map<String, dynamic> _gateSummary = {};
  Map<String, dynamic> _trafficSummary = {};
  
  bool _isLoadingGates = true;
  bool _isLoadingTraffic = true;
  String? _gatesError;
  String? _trafficError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _loadGates();
    _loadTraffic();
  }

  Future<void> _loadGates() async {
    setState(() {
      _isLoadingGates = true;
      _gatesError = null;
    });

    try {
      final result = await GateService.getSummary();
      setState(() {
        _gates = result['gates'] as List<Gate>;
        _gateSummary = result['summary'] as Map<String, dynamic>;
        _isLoadingGates = false;
      });
    } catch (e) {
      setState(() {
        _gatesError = e.toString().replaceFirst('Exception: ', '');
        _isLoadingGates = false;
      });
    }
  }

  Future<void> _loadTraffic() async {
    setState(() {
      _isLoadingTraffic = true;
      _trafficError = null;
    });

    try {
      final result = await TrafficService.getLatestSummary();
      setState(() {
        _trafficUpdates = result['latest'] as List<TrafficUpdate>;
        _trafficSummary = result['summary'] as Map<String, dynamic>;
        _isLoadingTraffic = false;
      });
    } catch (e) {
      setState(() {
        _trafficError = e.toString().replaceFirst('Exception: ', '');
        _isLoadingTraffic = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'lancar':
      case 'open':
        return Colors.green;
      case 'padat':
        return Colors.orange;
      case 'macet':
        return Colors.red;
      case 'tutup':
      case 'closed':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'lancar':
        return Icons.check_circle;
      case 'padat':
        return Icons.warning;
      case 'macet':
        return Icons.error;
      case 'tutup':
      case 'closed':
        return Icons.block;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status Kampus'),
        backgroundColor: const Color(0xFFE4002B),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.door_front_door), text: 'Gate'),
            Tab(icon: Icon(Icons.traffic), text: 'Kemacetan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGatesTab(),
          _buildTrafficTab(),
        ],
      ),
    );
  }

  Widget _buildGatesTab() {
    if (_isLoadingGates) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_gatesError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(_gatesError!, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadGates,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGates,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Cards
          _buildGateSummaryCards(),
          const SizedBox(height: 24),
          // Gate List
          const Text(
            'Daftar Pintu Gerbang',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_gates.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Tidak ada data gate'),
              ),
            )
          else
            ..._gates.map((gate) => _buildGateCard(gate)),
        ],
      ),
    );
  }

  Widget _buildGateSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Lancar',
            _gateSummary['lancar']?.toString() ?? '0',
            Colors.green,
            Icons.check_circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            'Padat',
            _gateSummary['padat']?.toString() ?? '0',
            Colors.orange,
            Icons.warning,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            'Macet',
            _gateSummary['macet']?.toString() ?? '0',
            Colors.red,
            Icons.error,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            'Tutup',
            _gateSummary['tutup']?.toString() ?? '0',
            Colors.grey,
            Icons.block,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGateCard(Gate gate) {
    final statusColor = _getStatusColor(gate.displayStatus);
    final statusIcon = _getStatusIcon(gate.displayStatus.toLowerCase());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.door_front_door, color: statusColor, size: 28),
        ),
        title: Text(
          gate.namaGerbang,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          gate.isOpen ? 'Buka' : 'Tutup',
          style: TextStyle(color: Colors.grey[600]),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, color: statusColor, size: 16),
              const SizedBox(width: 4),
              Text(
                gate.displayStatus,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrafficTab() {
    if (_isLoadingTraffic) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_trafficError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(_trafficError!, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadTraffic,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTraffic,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Traffic Summary
          _buildTrafficSummaryCards(),
          const SizedBox(height: 24),
          // Traffic Updates
          const Text(
            'Update Terbaru (24 Jam)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_trafficUpdates.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('Tidak ada update kemacetan'),
              ),
            )
          else
            ..._trafficUpdates.map((update) => _buildTrafficCard(update)),
        ],
      ),
    );
  }

  Widget _buildTrafficSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Lancar',
            _trafficSummary['lancar']?.toString() ?? '0',
            Colors.green,
            Icons.check_circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Padat',
            _trafficSummary['padat']?.toString() ?? '0',
            Colors.orange,
            Icons.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Macet',
            _trafficSummary['macet']?.toString() ?? '0',
            Colors.red,
            Icons.error,
          ),
        ),
      ],
    );
  }

  Widget _buildTrafficCard(TrafficUpdate update) {
    final statusColor = _getStatusColor(update.status);
    final statusIcon = _getStatusIcon(update.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.location_on, color: statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        update.location,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        update.timeAgo,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        update.displayStatus,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (update.description != null && update.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                update.description!,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
