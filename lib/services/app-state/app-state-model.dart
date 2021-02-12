import './models/index.dart';
import './models/config-model.dart';

class AppState {
  AppState({
    this.history,
    this.snippets,
    this.config
  });

  AppState copyWith({
    List<InputHistoryModel> history,
    List<SnippetModel>      snippets,
    ConfigModel             config
  })
    => AppState(
      history:  history  ?? [...this.history],
      snippets: snippets ?? [...this.snippets],
      config:   config ?? this.config
    );

  /// Input history
  final List<InputHistoryModel> history;

  /// Saved js snippets
  final List<SnippetModel>      snippets; 

  /// Settings
  final ConfigModel             config;
}
