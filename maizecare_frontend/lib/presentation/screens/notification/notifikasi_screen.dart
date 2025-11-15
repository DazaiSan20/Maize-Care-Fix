import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../widgets/info_card.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({Key? key}) : super(key: key);

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  String _selectedFilter = 'Semua';
  
  final List<NotificationItem> _notifications = [
    NotificationItem(
      title: 'Kelembaban Terlalu Tinggi',
      content:
          'Kelembaban tanah mencapai 85%. Segera lakukan tindakan untuk mengurangi kelembaban.\n\nTanggal: 08 Nov 2025, 14:30\nSuhu: 28°C, Kelembaban tanah: 85%',
      type: NotificationType.warning,
      time: '2 jam yang lalu',
      isRead: false,
    ),
    NotificationItem(
      title: 'Rekomendasi Remedies',
      content:
          'Tanaman kurang sehat. Disarankan untuk melakukan pemupukan dan penyiraman yang lebih teratur.',
      type: NotificationType.info,
      time: '5 jam yang lalu',
      isRead: false,
    ),
    NotificationItem(
      title: 'Penyakit Terdeteksi!',
      content:
          'Penyakit daun jagung terdeteksi pada pemeriksaan terakhir.\n\nTanggal: 08 Nov 2025, 10:15\nPenyakit: Common Rust\nTingkat: Sedang',
      type: NotificationType.danger,
      time: '1 hari yang lalu',
      isRead: true,
    ),
    NotificationItem(
      title: 'Penanaman Ulang!',
      content:
          'Tanaman terlewatkan untuk ditanam pada masa tanam yang seharusnya. Segera lakukan penanaman ulang.',
      type: NotificationType.info,
      time: '2 hari yang lalu',
      isRead: true,
    ),
    NotificationItem(
      title: 'Pemeriksaan Berhasil',
      content:
          'Pemeriksaan daun jagung telah selesai. Semua tanaman dalam kondisi sehat.',
      type: NotificationType.success,
      time: '3 hari yang lalu',
      isRead: true,
    ),
  ];

  List<NotificationItem> get _filteredNotifications {
    if (_selectedFilter == 'Semua') return _notifications;
    if (_selectedFilter == 'Belum Dibaca') {
      return _notifications.where((n) => !n.isRead).toList();
    }
    return _notifications.where((n) => n.isRead).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Notifikasi',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            color: AppColors.textPrimary,
            onPressed: _markAllAsRead,
            tooltip: 'Tandai semua dibaca',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: AppColors.textPrimary,
            onPressed: _clearAllNotifications,
            tooltip: 'Hapus semua',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredNotifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(
                        _filteredNotifications[index],
                        index,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.white,
      child: Row(
        children: [
          _buildFilterChip('Semua'),
          const SizedBox(width: 8),
          _buildFilterChip('Belum Dibaca'),
          const SizedBox(width: 8),
          _buildFilterChip('Sudah Dibaca'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = label);
      },
      backgroundColor: AppColors.white,
      selectedColor: AppColors.primary.withOpacity(0.2),
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.divider,
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification, int index) {
    Color backgroundColor;
    Color borderColor;
    IconData icon;

    switch (notification.type) {
      case NotificationType.success:
        backgroundColor = AppColors.success.withOpacity(0.1);
        borderColor = AppColors.success.withOpacity(0.3);
        icon = Icons.check_circle_outline;
        break;
      case NotificationType.warning:
        backgroundColor = AppColors.warning.withOpacity(0.1);
        borderColor = AppColors.warning.withOpacity(0.3);
        icon = Icons.warning_amber_outlined;
        break;
      case NotificationType.danger:
        backgroundColor = AppColors.error.withOpacity(0.1);
        borderColor = AppColors.error.withOpacity(0.3);
        icon = Icons.error_outline;
        break;
      case NotificationType.info:
      default:
        backgroundColor = AppColors.info.withOpacity(0.1);
        borderColor = AppColors.info.withOpacity(0.3);
        icon = Icons.info_outline;
    }

    return Dismissible(
      key: Key('notification_$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: AppColors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          _notifications.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notifikasi dihapus'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () => _markAsRead(notification),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: notification.isRead ? AppColors.white : backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: borderColor, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: AppTextStyles.heading4.copyWith(
                                    fontWeight: notification.isRead
                                        ? FontWeight.w600
                                        : FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (!notification.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.time,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  notification.content,
                  style: AppTextStyles.body.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada notifikasi',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Notifikasi akan muncul di sini',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  void _markAsRead(NotificationItem notification) {
    setState(() {
      notification.isRead = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi ditandai sebagai dibaca'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Notifikasi'),
        content: const Text('Apakah Anda yakin ingin menghapus semua notifikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _notifications.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Semua notifikasi telah dihapus'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// Notification Model
class NotificationItem {
  final String title;
  final String content;
  final NotificationType type;
  final String time;
  bool isRead;

  NotificationItem({
    required this.title,
    required this.content,
    required this.type,
    required this.time,
    this.isRead = false,
  });
}

enum NotificationType {
  success,
  warning,
  danger,
  info,
}