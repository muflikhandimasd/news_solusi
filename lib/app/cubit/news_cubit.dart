import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:news_solusi/app/helpers/api_config.dart';
import 'package:news_solusi/app/models/news_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';
part 'news_state.dart';

class NewsCubit extends Cubit<NewsState> with HydratedMixin {
  NewsCubit() : super(NewsLoading());

  static final RefreshController refreshController = RefreshController();
  static final PageController pageController =
      PageController(viewportFraction: 0.8);

  void init() {
    getAllNews();
  }

  void getAllNews() async {
    try {
      emit(NewsLoading());
      var res = await http.get(Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.pageSize}10${ApiConfig.page}1${ApiConfig.qApiKey}${ApiConfig.apiKey}'));

      var json = jsonDecode(res.body);
      if (res.statusCode == 200 && json['status'] == 'ok') {
        List resSuccess = json['articles'];
        List<Article> articles = [];
        await Future.forEach(resSuccess,
            (dynamic article) => articles.add(Article.fromJson(article)));

        emit(NewsLoaded._(
            articles: articles,
            page: 1,
            pageSize: 10,
            totalResults: json['totalResults']));
      }
    } catch (e) {
      log('Error $e');
      emit(NewsError('$e'));
    } finally {
      refreshController.loadComplete();
    }
  }

  void onLoadMoreNews() async {
    if (state is NewsLoaded) {
      var st = state as NewsLoaded;
      try {
        int page = 1 + st.page;
        var res = await http.get(Uri.parse(
            '${ApiConfig.baseUrl}${ApiConfig.pageSize}10${ApiConfig.page}$page${ApiConfig.qApiKey}${ApiConfig.apiKey}'));
        var json = jsonDecode(res.body);
        List listData = json['articles'];
        List<Article> articles = [];
        await Future.forEach(listData,
            (dynamic article) => articles.add(Article.fromJson(article)));

        List oldData = st.articles;
        articles = [...oldData, ...articles];
        emit(st.loaded(
            articles: articles,
            page: page,
            pageSize: 10,
            totalResults: json['totalResults']));
      } catch (e) {
        log('Error $e');
        emit(NewsError('$e'));
      } finally {
        refreshController.loadComplete();
      }
    }
  }

  void onRefresh() {
    getAllNews();
  }

  @override
  NewsState? fromJson(Map<String, dynamic> json) {
    try {
      List<Article> articles = [];
      final listArticle = (json['article'] as List)
          .map((e) => Article.fromJson(e as Map<String, dynamic>))
          .toList();
      articles = listArticle;
      return NewsLoaded._(articles: articles);
    } catch (e) {
      log('Error Hydrated $e');
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(NewsState state) {
    if (state is NewsLoaded) {
      return state.toJson();
    }
    return null;
  }
}
