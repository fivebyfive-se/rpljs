import './models/index.dart';

class AppState {
  AppState({
    this.history,
    this.snippets,
  });

  AppState copyWith({
    List<InputHistoryModel> history,
    List<SnippetModel>      snippets,
  })
    => AppState(
      history:  history  ?? [...this.history],
      snippets: snippets ?? [...this.snippets],
    );

  /// Input history
  final List<InputHistoryModel> history;

  /// Saved js snippets
  final List<SnippetModel>      snippets; 
}
