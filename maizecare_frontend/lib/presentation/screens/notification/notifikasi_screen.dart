import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/notification_provider.dart';
import '../../../data/models/notification_model.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    // Load notifications saat screen dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    String? filter;
    if (_selectedFilter == 'Belum Dibaca') {
      filter = 'unread';
    } else if (_selectedFilter == 'Sudah Dibaca') {
      filter = 'read';
    }

    await context.read<NotificationProvider>().fetchNotifications(filter: filter);
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
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return _buildErrorState(provider.error!);
          }

          return Column(
            children: [
              _buildFilterChips(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: provider.notifications.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.notifications.length,
                          itemBuilder: (context, index) {
                            return _buildNotificationCard(
                              provider.notifications[index],
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
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
        _loadNotifications();
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

  Widget _buildNotificationCard(NotificationModel notification) {
    Color backgroundColor;
    Color borderColor;
    IconData icon;

    switch (notification.type) {
      case 'success':
        backgroundColor = AppColors.success.withOpacity(0.1);
        borderColor = AppColors.success.withOpacity(0.3);
        icon = Icons.check_circle_outline;
        break;
      case 'warning':
        backgroundColor = AppColors.warning.withOpacity(0.1);
        borderColor = AppColors.warning.withOpacity(0.3);
        icon = Icons.warning_amber_outlined;
        break;
      case 'danger':
        backgroundColor = AppColors.error.withOpacity(0.1);
        borderColor = AppColors.error.withOpacity(0.3);
        icon = Icons.error_outline;
        break;
      case 'info':
      default:
        backgroundColor = AppColors.info.withOpacity(0.1);
        borderColor = AppColors.info.withOpacity(0.3);
        icon = Icons.info_outline;
    }

    return Dismissible(
      key: Key('notification_${notification.id}'),
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
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmDialog();
      },
      onDismissed: (direction) async {
        final success = await context
            .read<NotificationProvider>()
            .deleteNotification(notification.id);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notifikasi dihapus'),
              duration: Duration(seconds: 2),
            ),
          );
        }
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
                            notification.getTimeAgo(),
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

  Widget _buildErrorState(String error) {
    final isAuthError = error.contains('Sesi') || 
                        error.contains('login') || 
                        error.contains('authenticated');
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isAuthError ? Icons.lock_outline : Icons.error_outline,
            size: 80,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            isAuthError ? 'Sesi Berakhir' : 'Terjadi Kesalahan',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (isAuthError)
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to login
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              },
              icon: const Icon(Icons.login),
              label: const Text('Login Kembali'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
            ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Notifikasi'),
        content: const Text('Apakah Anda yakin ingin menghapus notifikasi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (!notification.isRead) {
      await context.read<NotificationProvider>().markAsRead(notification.id);
    }
  }

  Future<void> _markAllAsRead() async {
    final provider = context.read<NotificationProvider>();

    final success = await provider.markAllAsRead();

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua notifikasi ditandai sebagai dibaca'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menandai notifikasi sebagai dibaca'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _clearAllNotifications() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Notifikasi'),
        content: const Text('Apakah Anda yakin ingin menghapus semua notifikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = context.read<NotificationProvider>();
      final success = await provider.deleteAllNotifications();

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Semua notifikasi telah dihapus'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menghapus notifikasi'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }
}