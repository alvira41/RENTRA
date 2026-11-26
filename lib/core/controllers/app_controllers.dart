import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/katalog_controller.dart';
import '../../controllers/order_controller.dart';
import '../../controllers/supply_controller.dart';

class AppControllers extends StatefulWidget {
  const AppControllers({super.key, required this.child});

  final Widget child;

  static AppControllersData of(BuildContext context) {
    final scope = context.findAncestorWidgetOfExactType<AppControllersScope>();
    assert(scope != null, 'AppControllers belum dipasang di atas MaterialApp');
    return scope!.data;
  }

  @override
  State<AppControllers> createState() => _AppControllersState();
}

class _AppControllersState extends State<AppControllers> {
  late final AppControllersData _data;

  @override
  void initState() {
    super.initState();
    _data = AppControllersData();
  }

  @override
  void dispose() {
    _data.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppControllersScope(data: _data, child: widget.child);
  }
}

class AppControllersScope extends InheritedWidget {
  const AppControllersScope({
    super.key,
    required this.data,
    required super.child,
  });

  final AppControllersData data;

  @override
  bool updateShouldNotify(covariant AppControllersScope oldWidget) => false;
}

class AppControllersData {
  AppControllersData() {
    katalog = KatalogController(auth: auth);
  }

  final AuthController auth = AuthController();
  late final KatalogController katalog;
  final OrderController order = OrderController();
  final SupplyController supply = SupplyController();

  void dispose() {
    auth.dispose();
    katalog.dispose();
    order.dispose();
    supply.dispose();
  }
}
