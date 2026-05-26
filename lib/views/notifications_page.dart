import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../database/database_helper.dart';
import '../widgets/system_overlay_wrapper.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  final String mobileNo;
  const NotificationsPage({super.key, required this.mobileNo});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    
    // 1. Load from cache first
    final cached = await _dbHelper.getNotifications();
    if (mounted) {
      setState(() {
        _notifications = cached;
        if (cached.isNotEmpty) _isLoading = false; // Show cached data immediately
      });
    }

    // 2. Sync from API
    try {
      final apiData = await _apiService.getNotifications(widget.mobileNo);
      if (apiData.isNotEmpty) {
        for (var n in apiData) {
          await _dbHelper.insertNotification(n);
        }
        
        // Reload from DB to get updated list
        final updated = await _dbHelper.getNotifications();
        if (mounted) {
          setState(() {
            _notifications = updated;
            _isLoading = false;
          });
          
          // Mark as read on server
          await _apiService.markNotificationsAsRead(widget.mobileNo);
          // Mark as read locally
          await _dbHelper.markNotificationsRead();
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Sync Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SystemOverlayWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          title: const Text(
            'NOTIFICATIONS',
            style: TextStyle(
              fontWeight: FontWeight.w900, 
              fontSize: 16, 
              letterSpacing: 1,
              color: Colors.black,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () async {
                await NotificationService().requestPermissions(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Permission request triggered')),
                  );
                }
              },
              icon: const Icon(Icons.security, size: 20, color: Colors.black),
            ),
            IconButton(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh, size: 20, color: Colors.black),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.black))
            : _notifications.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadNotifications,
                    color: Colors.black,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _notifications.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _notifications[index];
                        return _buildNotificationCard(item);
                      },
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
          Icon(Icons.notifications_none, size: 64, color: Colors.black.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(
            'NO NOTIFICATIONS YET',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1,
              color: Colors.black.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> item) {
    final DateTime date = DateTime.parse(item['created_at']);
    final String formattedDate = DateFormat('MMM dd, hh:mm a').format(date);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (item['is_read'] == 0)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Expanded(
                      child: Text(
                        item['title'].toString().toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900, 
                          fontSize: 14, 
                          letterSpacing: 0.5,
                          color: Colors.black, // Explicitly black
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 10, 
                  color: Colors.black.withValues(alpha: 0.4), 
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item['message'].toString(),
            style: TextStyle(
              fontSize: 13, 
              color: Colors.black.withValues(alpha: 0.8), // Dark grey
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
