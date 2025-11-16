import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/info_card.dart';

class MonitoringDaunScreen extends StatefulWidget {
  const MonitoringDaunScreen({super.key});

  @override
  State<MonitoringDaunScreen> createState() => _MonitoringDaunScreenState();
}

class _MonitoringDaunScreenState extends State<MonitoringDaunScreen> {
  bool _isImageSelected = false;
  bool _isPredicting = false;
  bool _showResults = false;

  void _handleImagePicker() async {
    // Simulate image picker
    setState(() => _isImageSelected = true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gambar berhasil dipilih'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handlePredict() async {
    setState(() {
      _isPredicting = true;
      _showResults = false;
    });

    // Simulate prediction API call
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _isPredicting = false;
        _showResults = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Monitoring Daun',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            color: AppColors.textPrimary,
            onPressed: () {},
            tooltip: 'Riwayat Pemeriksaan',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Upload Card
            _buildUploadCard(),
            
            if (_showResults) ...[
              const SizedBox(height: 16),
              _buildResultCard(),
              const SizedBox(height: 12),
              _buildRecommendationCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard() {
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
                Icons.camera_alt,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Monitoring Daun Jagung',
                style: AppTextStyles.heading3,
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Upload Button
          InkWell(
            onTap: _handleImagePicker,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_photo_alternate,
                    color: AppColors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Ambil Foto Daun Jagung',
                    style: AppTextStyles.button,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Image Preview
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isImageSelected ? AppColors.primary : AppColors.divider,
                  width: 2,
                ),
              ),
              child: _isImageSelected
                  ? Stack(
                      children: [
                        Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image,
                                  size: 80,
                                  color: AppColors.textHint,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Preview Gambar',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            onPressed: () {
                              setState(() => _isImageSelected = false);
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: AppColors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 64,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada gambar',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ambil foto untuk memulai deteksi',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Predict Button
          CustomButton(
            text: _isPredicting ? 'Memprediksi...' : 'Prediksi Penyakit',
            onPressed: _isImageSelected && !_isPredicting ? _handlePredict : () {},
            backgroundColor: _isImageSelected ? AppColors.primary : AppColors.textHint,
            isLoading: _isPredicting,
          ),
          
          if (!_isImageSelected) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Silakan ambil foto daun terlebih dahulu',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    return InfoCard(
      title: 'Hasil Kondisi Daun - Healthy',
      content:
          'Tidak ada masalah atau penyakit yang terdeteksi pada daun jagung. Tanaman dalam kondisi sehat dan tumbuh dengan baik.',
      backgroundColor: AppColors.success.withOpacity(0.1),
      icon: Icons.check_circle,
    );
  }

  Widget _buildRecommendationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
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
                Icons.lightbulb_outline,
                color: AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Rekomendasi Remedies',
                style: AppTextStyles.heading4,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Jagung sehat berarti jika ada yang sakit tidak banyak. Maka dari itu perhatikan hal-hal berikut:',
            style: AppTextStyles.body.copyWith(height: 1.5),
          ),
          const SizedBox(height: 12),
          _buildRecommendationItem('Perhatikan nutrisi tanah secara berkala'),
          _buildRecommendationItem('Pastikan penyiraman dilakukan dengan tepat'),
          _buildRecommendationItem('Monitor kelembaban udara dan tanah'),
          _buildRecommendationItem('Lakukan pemeriksaan rutin setiap minggu'),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body,
            ),
          ),
        ],
      ),
    );
  }
}