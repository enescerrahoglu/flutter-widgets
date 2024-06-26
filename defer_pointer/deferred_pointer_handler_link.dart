part of 'defer_pointer.dart';

class DeferredPointerHandlerLink extends ChangeNotifier with EquatableMixin {
  DeferredPointerHandlerLink();
  final List<DeferPointerRenderObject> _painters = [];

  void descendantNeedsPaint() => notifyListeners();

  List<DeferPointerRenderObject> get painters => UnmodifiableListView(_painters);

  void add(DeferPointerRenderObject value) {
    if (!_painters.contains(value)) {
      _painters.add(value);
      notifyListeners();
    }
  }

  void remove(DeferPointerRenderObject value) {
    if (_painters.contains(value)) {
      _painters.remove(value);
      notifyListeners();
    }
  }


  void removeAll() {
    _painters.clear();
    notifyListeners();
  }

  @override
  List<Object?> get props => _painters;
}
