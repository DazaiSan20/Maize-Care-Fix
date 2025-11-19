import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../data/services/api_service.dart';
import '../../widgets/custom_button.dart';

class MonitoringDaunScreen extends StatefulWidget {
  const MonitoringDaunScreen({super.key});

  @override
  State<MonitoringDaunScreen> createState() => _MonitoringDaunScreenState();
}

class _MonitoringDaunScreenState extends State<MonitoringDaunScreen> {
  File? _selectedImage;
  bool _isPredicting = false;
  Map<String, dynamic>? _predictionResult;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _predictionResult = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gambar berhasil diambil'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Auto predict setelah gambar dipilih
        await _handlePredict();
      }
    } catch (e) {
      debugPrint('Camera error: $e');
      _showErrorSnackBar('Gagal mengambil gambar: ${e.toString()}');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _predictionResult = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gambar berhasil dipilih'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Auto predict setelah gambar dipilih
        await _handlePredict();
      }
    } catch (e) {
      debugPrint('Gallery error: $e');
      _showErrorSnackBar('Gagal memilih gambar: ${e.toString()}');
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Sumber Gambar',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePredict() async {
    if (_selectedImage == null) {
      _showErrorSnackBar('Silakan pilih gambar terlebih dahulu');
      return;
    }

    setState(() {
      _isPredicting = true;
      _predictionResult = null;
    });

    try {
      debugPrint('Predicting image...');
      debugPrint('Image path: ${_selectedImage!.path}');

      // ✅ GET TOKEN dari ApiService
      final token = ApiService.getAuthToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login terlebih dahulu.');
      }

      debugPrint('Token obtained: ${token.substring(0, 20)}...');

      final uri = Uri.parse('${ApiService.instance.baseUrl}/diseases/predict');
      final request = http.MultipartRequest('POST', uri);

      // ✅ ADD AUTHORIZATION HEADER
      request.headers['Authorization'] = 'Bearer $token';

      // ✅ Add fallback header untuk development
      // request.headers['x-user-id'] = 'dev-user-id'; // uncomment jika perlu

      // Tambahkan file image dengan field name 'file'
      final file = await http.MultipartFile.fromPath(
        'file',
        _selectedImage!.path,
      );
      request.files.add(file);

      debugPrint('Sending request to: $uri');
      debugPrint('File size: ${await _selectedImage!.length()} bytes');

      // Kirim request dengan timeout
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timeout - server tidak merespon dalam 30 detik');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          setState(() {
            _predictionResult = data['data'];
            _isPredicting = false;
          });

          debugPrint('Prediction success: ${_predictionResult!['disease']}');

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Prediksi berhasil: ${_predictionResult!['disease']}'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } else {
          throw Exception(data['message'] ?? 'Prediksi gagal - response tidak valid');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Token expired atau tidak valid. Silakan login ulang.');
      } else if (response.statusCode == 404) {
        throw Exception('Endpoint tidak ditemukan - pastikan backend running');
      } else if (response.statusCode == 500) {
        throw Exception('Server error - cek log backend');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Server error (${response.statusCode})');
      }
    } on SocketException {
      debugPrint('Network error: No connection');
      setState(() => _isPredicting = false);
      _showErrorSnackBar('Tidak dapat terhubung ke server. Pastikan backend sedang berjalan.');
    } on TimeoutException {
      debugPrint('Timeout error');
      setState(() => _isPredicting = false);
      _showErrorSnackBar('Request timeout. Server terlalu lama merespon.');
    } catch (e) {
      debugPrint('Prediction error: $e');
      setState(() => _isPredicting = false);
      _showErrorSnackBar('Prediksi gagal: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _predictionResult = null;
    });
  }

  void _reloadPrediction() {
    _clearImage();
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur riwayat akan segera hadir'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Riwayat Pemeriksaan',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildUploadCard(),
            if (_predictionResult != null) ...[
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
          InkWell(
            onTap: _showImageSourceDialog,
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedImage != null
                      ? AppColors.primary
                      : AppColors.divider,
                  width: 2,
                ),
              ),
              child: _selectedImage != null
                  ? Stack(
                      children: [
                        Image.file(
                          _selectedImage!,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: AppColors.error,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Gagal memuat gambar',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        if (_isPredicting)
                          Container(
                            color: Colors.black.withValues(alpha: 0.3),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(
                                    color: AppColors.white,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Memprediksi...',
                                    style: AppTextStyles.body.copyWith(
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (!_isPredicting)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _clearImage,
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: AppColors.white,
                                    size: 20,
                                  ),
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
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    if (_predictionResult == null) return const SizedBox();

    final disease = _predictionResult!['disease'] ?? 'Unknown';
    final confidence = ((_predictionResult!['confidence'] ?? 0.0) is int 
        ? (_predictionResult!['confidence'] as int).toDouble() 
        : _predictionResult!['confidence'] as double) * 100;
    final isHealthy = disease.toLowerCase().contains('healthy');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isHealthy
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHealthy
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.3),
        ),
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
                isHealthy ? Icons.check_circle : Icons.warning,
                color: isHealthy ? AppColors.success : AppColors.error,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hasil Prediksi',
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      disease,
                      style: AppTextStyles.heading3.copyWith(
                        color: isHealthy ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tingkat Keyakinan:',
                style: AppTextStyles.body,
              ),
              Text(
                '${confidence.toStringAsFixed(1)}%',
                style: AppTextStyles.heading4.copyWith(
                  color: isHealthy ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: confidence / 100,
              backgroundColor: AppColors.inputFill,
              color: isHealthy ? AppColors.success : AppColors.error,
              minHeight: 10,
            ),
          ),
          if (_predictionResult!['description'] != null) ...[
            const SizedBox(height: 16),
            Text(
              _predictionResult!['description'],
              style: AppTextStyles.body.copyWith(height: 1.5),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendationCard() {
    if (_predictionResult == null) return const SizedBox();

    final recommendations = _predictionResult!['recommendations'] as List<dynamic>? ?? [];
    final isHealthy = (_predictionResult!['disease'] ?? '').toLowerCase().contains('healthy');

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
                'Rekomendasi Perawatan',
                style: AppTextStyles.heading4,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recommendations.isNotEmpty) ...[
            ...recommendations.map((rec) => _buildRecommendationItem(rec.toString())),
          ] else ...[
            Text(
              isHealthy
                  ? 'Jagung dalam kondisi sehat. Lanjutkan perawatan rutin seperti:\n\n• Perhatikan nutrisi tanah secara berkala\n• Pastikan penyiraman dilakukan dengan tepat\n• Monitor kelembaban udara dan tanah\n• Lakukan pemeriksaan rutin setiap minggu'
                  : 'Segera konsultasikan dengan ahli pertanian untuk penanganan lebih lanjut.',
              style: AppTextStyles.body.copyWith(height: 1.5),
            ),
          ],
          const SizedBox(height: 16),
          CustomButton(
            text: 'Periksa Ulang',
            onPressed: _reloadPrediction,
            backgroundColor: AppColors.primary,
          ),
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