import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:rpljs/extensions/index.dart';
import 'package:rpljs/services/app-state/models/input-history-model.dart';
import 'package:rpljs/services/app-state/models/snippet-model.dart';

import './models/index.dart';
import './app-state-model.dart';


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
  void pushHistory(String content) {
    final box = Hive.box<InputHistoryModel>(historyBox);
    if (box.values.any((v) => v.content == content)) {
      final existing = box.values.firstWhere((h) => h.content == content);
      existing.timestamp = DateTime.now();
      _edit<InputHistoryModel>(existing);
    } else {
      add<InputHistoryModel>(InputHistoryModel(content: content));
    }
  }

  /// Edit history item
  void editHistory(InputHistoryModel model)
    => _edit<InputHistoryModel>(model);

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
    await Hive.openBox<InputHistoryModel>(historyBox);
    await Hive.openBox<SnippetModel>(snippetsBox);
  }

  @protected
  final StreamController<AppState> _ctrl = StreamController.broadcast();

  @protected
  AppState _currentState;

  AppState _loadState() => AppState(
    history: Hive.box<InputHistoryModel>(historyBox)
            .values
            .order((a,b) => b.compareTo(a))
            .map((h) => h as InputHistoryModel)
            .toList(),
    snippets: Hive.box<SnippetModel>(snippetsBox)
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

  @protected static AppStateProvider _instance;

  static String get snippetsBox => SnippetModel.hiveBoxName;

  static String get historyBox => InputHistoryModel.hiveBoxName;

  static AppStateProvider getInstance()
    => _instance ?? (_instance = AppStateProvider());
}