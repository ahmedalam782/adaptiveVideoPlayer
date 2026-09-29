/// A lightweight, decoupled Dependency Injection / Service Locator container (DIP).
///
/// Enables inversion of control without forcing heavy external dependencies onto consumers.
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  final Map<Type, dynamic Function()> _factories = {};
  final Map<Type, dynamic> _singletons = {};

  ServiceLocator._internal();

  /// Global singleton instance
  factory ServiceLocator() => _instance;

  /// Register a factory that generates a new instance each time [get] is called
  void registerFactory<T>(T Function() factory) {
    _factories[T] = factory;
  }

  /// Register an eager or lazy singleton
  void registerSingleton<T>(T instance) {
    _singletons[T] = instance;
  }

  /// Register a lazy singleton resolved on first request
  void registerLazySingleton<T>(T Function() factory) {
    _factories[T] = () {
      if (!_singletons.containsKey(T)) {
        _singletons[T] = factory();
      }
      return _singletons[T];
    };
  }

  /// Retrieve an instance of type [T]
  T get<T>() {
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }
    if (_factories.containsKey(T)) {
      return _factories[T]!() as T;
    }
    throw StateError('ServiceLocator: No registration found for type $T');
  }

  /// Check if a type [T] is registered
  bool isRegistered<T>() =>
      _singletons.containsKey(T) || _factories.containsKey(T);

  /// Unregister a type
  void unregister<T>() {
    _singletons.remove(T);
    _factories.remove(T);
  }

  /// Clear all registered services
  void reset() {
    _singletons.clear();
    _factories.clear();
  }
}
