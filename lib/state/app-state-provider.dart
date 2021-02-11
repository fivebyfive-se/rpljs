import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:rpljs/extensions/iterable-extensions.dart';

import 'package:rpljs/state/app-state-model.dart';
import 'package:rpljs/state/models/_base-model.dart';
import 'package:rpljs/state/models/input-history-model.dart';
import 'package:rpljs/state/models/snippet-model.dart';

class AppStateProvider {
  /// Snapshot of last state update
  AppState get snapshot => _currentState ?? (_currentState = _loadState());

  /// Listenable stream of app states
  Stream<AppState> get stream => _ctrl.stream;

  /// Add a new snippet
  void addSnippet()
    => add<SnippetModel>(
      SnippetModel(
        label: DateTime.now().toIso8601String(),
        content: "console.log(Date());"
      ));

  /// Modify a snippet
  void editSnippet(SnippetModel snippet)
    => update<SnippetModel>(snippet);

  /// Delete a snippet
  void deleteSnippet(SnippetModel snippet)
    => remove<SnippetModel>(snippet);

  /// Add new item to input log
  void pushHistory(String content)
    => add<InputHistoryModel>(InputHistoryModel(content: content));

  /// Delete item from input log
  void deleteHistory(InputHistoryModel model)
    => remove<InputHistoryModel>(model);

  /// Add an item to storage
  void add<T extends BaseModel>(T item)
    => _edit<T>(item);

  /// Remove an item from storage
  void remove<T extends BaseModel>(T item)
    => _delete<T>(item);

  /// Edit an item in storage
  void update<T extends BaseModel>(T item)
    => _edit<T>(item);

  /// Call from main to init storage
  static Future<void> init() async {
    Hive.registerAdapter(SnippetAdapter());
    Hive.registerAdapter(InputHistoryAdapter());

    await Hive.initFlutter();
    await Hive.openBox<InputHistoryModel>(_historyBox);
    await Hive.openBox<SnippetModel>(_snippetsBox);
  }

  @protected
  final StreamController<AppState> _ctrl = StreamController.broadcast();

  @protected
  AppState _currentState;

  AppState _loadState() => AppState(
    history: Hive.box<InputHistoryModel>(_historyBox)
            .values
            .order((a,b) => b.compareTo(a))
            .map((h) => h as InputHistoryModel)
            .toList(),
    snippets: Hive.box<SnippetModel>(_snippetsBox)
            .values
            .order((a,b) => a.compareTo(b))
            .map((s) => s as SnippetModel)
            .toList()
  );

  @protected 
  void _update()
    => _ctrl.add(_currentState = _loadState());

  @protected
  void _boxy<T extends BaseModel>(T item, void Function(Box<T>) func)
    => func.call(Hive.box<T>(item.boxName));

  @protected
  void _edit<T extends BaseModel>(T item)
    => _boxy<T>(item, (box) {
      box.put(item.uuid, item);
      _update();
    });
  
  @protected
  void _delete<T extends BaseModel>(T item)
    => _boxy<T>(item, (box) {
      box.delete(item.uuid);
      _update();
    });


  @protected
  static String _snippetsBox = SnippetModel().boxName;

  @protected
  static String _historyBox  = InputHistoryModel().boxName;

  @protected
  static AppStateProvider _instance;

  static AppStateProvider getInstance()
    => _instance ?? (_instance = AppStateProvider());
}