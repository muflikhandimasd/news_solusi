part of 'news_cubit.dart';

@immutable
abstract class NewsState extends Equatable {
  @override
  List<Object?> get props => [];
  Map<String, dynamic>? toJson() {
    return null;
  }
}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final List<Article> articles;
  final int pageSize;
  final int page;
  final int totalResults;

  NewsLoaded._({
    required this.articles,
    this.pageSize = 10,
    this.page = 1,
    this.totalResults = 0,
  });

  NewsLoaded loaded(
          {required List<Article> articles,
          int? pageSize,
          int? page,
          int? totalResults}) =>
      NewsLoaded._(
          articles: articles,
          pageSize: pageSize ?? this.pageSize,
          page: page ?? this.page,
          totalResults: totalResults ?? this.totalResults);

  @override
  List<Object?> get props => [articles, pageSize, page, totalResults];

  @override
  Map<String, dynamic>? toJson() {
    return {'article': articles};
  }
}

class NewsError extends NewsState {
  final String msg;
  NewsError(this.msg);

  @override
  List<Object?> get props => [msg];
}
