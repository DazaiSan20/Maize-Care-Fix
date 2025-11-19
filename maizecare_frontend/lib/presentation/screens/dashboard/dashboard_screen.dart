import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/soil_sensor_provider.dart';
import '../../widgets/custom_button.dart';
import '../../../data/services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _dashboardData;
  String _userName = 'Owner';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // Fungsi untuk load data dari backend
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('🔍 Fetching dashboard from: ${ApiService.instance.baseUrl}/dashboard');
      
      // Fetch data dashboard dari backend
      final response = await ApiService.instance.get('/dashboard');

      print('📦 Response success: ${response.success}');
      print('📦 Response data: ${response.data}');

      if (response.success && response.data != null) {
        // Simpan seluruh response data
        setState(() {
          _dashboardData = response.data;
          _userName = response.data?['user_name'] ?? 'Owner';
          _isLoading = false;
        });

        print('✅ Dashboard loaded: $_dashboardData');

        // Fetch soil sensor data jika ada
        if (mounted) {
          context.read<SoilSensorProvider>().fetchLatestSensorData();
        }
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Gagal memuat data dashboard';
          _isLoading = false;
        });
        
        print('⚠️ Backend response error: ${response.message}');
        
        // Tetap fetch soil sensor data meskipun dashboard error
        if (mounted) {
          context.read<SoilSensorProvider>().fetchLatestSensorData();
        }
      }
    } catch (e) {
      print('💥 Exception: $e');
      
      setState(() {
        _errorMessage = 'Koneksi gagal: ${e.toString()}';
        _isLoading = false;
      });
      
      // Tetap coba fetch soil sensor data
      if (mounted) {
        context.read<SoilSensorProvider>().fetchLatestSensorData();
      }
    }
  }

  // Test koneksi backend
  Future<void> _testBackendConnection() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await ApiService.instance.get('/health');
      Navigator.pop(context);

      if (response.success) {
        _showSnackBar('✅ Backend tersambung!', Colors.green);
      } else {
        _showSnackBar('❌ Backend error: ${response.message}', Colors.red);
      }
    } catch (e) {
      Navigator.pop(context);
      _showSnackBar('💥 Koneksi gagal: ${e.toString()}', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          // Button test koneksi
          IconButton(
            icon: const Icon(Icons.wifi_outlined),
            color: AppColors.primary,
            onPressed: _testBackendConnection,
            tooltip: 'Test Koneksi Backend',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: AppColors.textPrimary,
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildErrorView()
              : RefreshIndicator(
                  onRefresh: _loadDashboardData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Card
                        _buildWelcomeCard(),
                        const SizedBox(height: 16),

                        // Chart Card
                        _buildChartCard(context),
                        const SizedBox(height: 16),

                        // Disease Detection Card
                        _buildDiseaseDetectionCard(),
                        
                        const SizedBox(height: 16),
                        
                        // Backend Info Card (Debug)
                        _buildBackendInfoCard(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 80,
              color: AppColors.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Gagal Terhubung ke Server',
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadDashboardData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _testBackendConnection,
                  icon: const Icon(Icons.network_check),
                  label: const Text('Test Koneksi'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackendInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info, size: 20),
              const SizedBox(width: 8),
              Text(
                'Backend Status',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'URL: ${ApiService.instance.baseUrl}',
            style: AppTextStyles.bodySmall.copyWith(
              fontFamily: 'monospace',
            ),
          ),
          if (_dashboardData != null) ...[
            const SizedBox(height: 4),
            Text(
              'Status: Connected ✓',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    // Ambil humidity dari backend (lebih prioritas daripada provider)
    final humidity = _dashboardData?['humidity'] ?? 0;
    final humidityPercent = humidity / 100.0;
    
    // Gunakan data dari backend jika ada
    final totalPlants = _dashboardData?['total_plants'] ?? 0;
    final healthyPlants = _dashboardData?['healthy_plants'] ?? 0;
    
    // Ambil timestamp dari latestHumidity
    final latestHumidity = _dashboardData?['latestHumidity'];
    String updateTime = 'Update terkini';
    if (latestHumidity != null && latestHumidity['recordedAt'] != null) {
      try {
        final recordedAt = DateTime.parse(latestHumidity['recordedAt']);
        updateTime = 'Update: ${recordedAt.hour}:${recordedAt.minute.toString().padLeft(2, '0')}';
      } catch (e) {
        updateTime = 'Update terkini';
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.waving_hand,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, $_userName!',
                      style: AppTextStyles.heading3,
                    ),
                    Text(
                      'Selamat datang kembali',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Tampilkan statistik dari backend jika ada
          if (totalPlants > 0) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Tanaman',
                    totalPlants.toString(),
                    Icons.eco,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Tanaman Sehat',
                    healthyPlants.toString(),
                    Icons.check_circle,
                    AppColors.success,
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          
          Text(
            'Monitoring Kelembaban Tanah',
            style: AppTextStyles.label.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.water_drop,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Kelembaban Tanah',
                  style: AppTextStyles.body,
                ),
              ),
              Text(
                '$humidity%',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.primary,
                  fontSize: 36,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Data Soil Sensor',
                    style: AppTextStyles.bodySmall,
                  ),
                  Text(
                    updateTime,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: humidityPercent,
                  backgroundColor: AppColors.inputFill,
                  color: AppColors.primary,
                  minHeight: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.heading3.copyWith(color: color),
                ),
                Text(
                  label,
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.show_chart,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Grafik Kelembaban 7 Hari',
                style: AppTextStyles.heading4,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.insert_chart_outlined,
                    size: 48,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Grafik akan ditampilkan di sini',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          CustomButton(
            text: 'Lihat Detail Grafik',
            onPressed: () {},
            backgroundColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseDetectionCard() {
    // Ambil data dari backend jika ada
    final healthyCount = _dashboardData?['healthy_plants'] ?? 8;
    final sickCount = _dashboardData?['sick_plants'] ?? 1;
    final total = healthyCount + sickCount;
    final healthyPercent = total > 0 ? ((healthyCount / total) * 100).round() : 88;
    final sickPercent = 100 - healthyPercent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.energy_savings_leaf,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Pengecekan Deteksi Daun',
                style: AppTextStyles.heading4,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: AppColors.success,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Identifikasi Penyakit',
                      style: AppTextStyles.heading4,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Status terakhir pemeriksaan',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildStatusItem(
                  'Sehat',
                  '$healthyPercent%',
                  AppColors.success,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusItem(
                  'Sakit',
                  '$sickPercent%',
                  AppColors.error,
                  Icons.cancel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.success,
                      width: 15,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$healthyPercent%',
                      style: AppTextStyles.heading4.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'NOTE: $healthyCount daun sehat, $sickCount sakit. (Hubungan penyakit jagung: -)',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading3.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}