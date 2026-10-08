import 'package:flutter/material.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/responsive.dart';
import 'features/dashboard/presentation/dashboard_screen.dart';
import 'features/history/presentation/history_screen.dart';
import 'features/ocr/models/parsed_receipt.dart';

/*
 * Widget gốc của ứng dụng OCR Expense Tracker.
 * Cấu hình MaterialApp với theme sáng/tối (Material 3),
 * định tuyến tên (named routes via AppRoutes) và khung điều hướng chính.
 *
 */
class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCR Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}

/*
 * Khung điều hướng chính của ứng dụng với BottomNavigationBar & FAB Quét biên lai.
 * Bao gồm:
 * - Tab 0: Dashboard (thống kê & biểu đồ)
 * - FAB trung tâm: Mở Camera quét biên lai
 * - Tab 1: Lịch sử (danh sách & tìm kiếm giao dịch)
 * Đồng thời hỗ trợ Responsive UI trên màn hình Tablet & Landscape.
 *
 */
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    HistoryScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _openCamera() async {
    final result = await Navigator.of(context).pushNamed<ParsedReceipt>(
      AppRoutes.camera,
    );

    if (result != null && mounted) {
      Navigator.of(context).pushNamed(
        AppRoutes.review,
        arguments: result,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsiveCenter(
          child: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCamera,
        tooltip: 'Quét biên lai',
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'Lịch sử',
          ),
        ],
      ),
    );
  }
}

