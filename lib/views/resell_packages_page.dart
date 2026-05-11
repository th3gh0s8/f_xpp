import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/resell_package.dart';
import '../services/api_service.dart';
import '../widgets/system_overlay_wrapper.dart';

class ResellPackagesPage extends StatefulWidget {
  const ResellPackagesPage({super.key});

  @override
  State<ResellPackagesPage> createState() => _ResellPackagesPageState();
}

class _ResellPackagesPageState extends State<ResellPackagesPage> {
  final ApiService _apiService = ApiService();
  List<ResellPackage> _packages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  Future<void> _fetchPackages() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final packages = await _apiService.getPackages();
      if (mounted) {
        setState(() {
          _packages = packages;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SystemOverlayWrapper(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          title: const Text('PRODUCT CATALOG', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _fetchPackages,
          color: Colors.black,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.black))
              : _packages.isEmpty
                  ? _buildEmptyState()
                  : _buildPackageList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height - 200,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.black.withOpacity(0.1)),
            const SizedBox(height: 16),
            const Text('NO PACKAGES AVAILABLE', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black38)),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageList() {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: _packages.length,
      separatorBuilder: (context, index) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        final package = _packages[index];
        return _buildPackageCard(package);
      },
    );
  }

  Widget _buildPackageCard(ResellPackage package) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  package.packageName.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  package.packageCode,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            package.description,
            style: TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.6), height: 1.5),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('BASE PRICE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.black38, letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(
                    '${package.currencyName} ${package.packageAmount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -1),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('BILLING', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.black38, letterSpacing: 0.5)),
                  const SizedBox(height: 4),
                  Text(
                    package.billingType.toUpperCase(),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ],
          ),
          if (package.additionalRemarks.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      package.additionalRemarks,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (package.modules.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildModulesSection(package.modules),
          ],
        ],
      ),
    );
  }

  Widget _buildModulesSection(List<ResellPackageModule> modules) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AVAILABLE ADD-ONS',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, color: Colors.black38),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: modules.map((m) => _buildModuleChip(m)).toList(),
        ),
      ],
    );
  }

  Widget _buildModuleChip(ResellPackageModule module) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            module.moduleName,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            '${module.currencyName} ${module.modulePrice.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.black.withOpacity(0.4)),
          ),
        ],
      ),
    );
  }
}
