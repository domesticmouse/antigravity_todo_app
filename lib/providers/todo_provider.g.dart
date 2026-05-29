// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TodoFilterState)
final todoFilterStateProvider = TodoFilterStateProvider._();

final class TodoFilterStateProvider
    extends $NotifierProvider<TodoFilterState, TodoFilter> {
  TodoFilterStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todoFilterStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todoFilterStateHash();

  @$internal
  @override
  TodoFilterState create() => TodoFilterState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TodoFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TodoFilter>(value),
    );
  }
}

String _$todoFilterStateHash() => r'94bb2432fdf4c162938066c527a610e9f65c2ed3';

abstract class _$TodoFilterState extends $Notifier<TodoFilter> {
  TodoFilter build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TodoFilter, TodoFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TodoFilter, TodoFilter>,
              TodoFilter,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SelectedTodoId)
final selectedTodoIdProvider = SelectedTodoIdProvider._();

final class SelectedTodoIdProvider
    extends $NotifierProvider<SelectedTodoId, int?> {
  SelectedTodoIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedTodoIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedTodoIdHash();

  @$internal
  @override
  SelectedTodoId create() => SelectedTodoId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$selectedTodoIdHash() => r'3f65faf9adb0821272e40c4750415f670dc974b9';

abstract class _$SelectedTodoId extends $Notifier<int?> {
  int? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int?, int?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int?, int?>,
              int?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TodoList)
final todoListProvider = TodoListProvider._();

final class TodoListProvider
    extends $AsyncNotifierProvider<TodoList, List<Todo>> {
  TodoListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todoListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todoListHash();

  @$internal
  @override
  TodoList create() => TodoList();
}

String _$todoListHash() => r'4afb964ec862fb8fcaef6420ad50605156b4d3c5';

abstract class _$TodoList extends $AsyncNotifier<List<Todo>> {
  FutureOr<List<Todo>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Todo>>, List<Todo>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Todo>>, List<Todo>>,
              AsyncValue<List<Todo>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredTodoList)
final filteredTodoListProvider = FilteredTodoListProvider._();

final class FilteredTodoListProvider
    extends $FunctionalProvider<List<Todo>, List<Todo>, List<Todo>>
    with $Provider<List<Todo>> {
  FilteredTodoListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredTodoListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredTodoListHash();

  @$internal
  @override
  $ProviderElement<List<Todo>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Todo> create(Ref ref) {
    return filteredTodoList(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Todo> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Todo>>(value),
    );
  }
}

String _$filteredTodoListHash() => r'2c5d239537a80fec3a97573f03d014e3e57ae2a8';

@ProviderFor(selectedTodo)
final selectedTodoProvider = SelectedTodoProvider._();

final class SelectedTodoProvider
    extends $FunctionalProvider<Todo?, Todo?, Todo?>
    with $Provider<Todo?> {
  SelectedTodoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedTodoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedTodoHash();

  @$internal
  @override
  $ProviderElement<Todo?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Todo? create(Ref ref) {
    return selectedTodo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Todo? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Todo?>(value),
    );
  }
}

String _$selectedTodoHash() => r'fd0404ee0a313cd4e1133287ffc6659b3601a2cc';
