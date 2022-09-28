// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart';
import 'package:news_solusi/app/cubit/news_cubit.dart';
import 'package:news_solusi/app/helpers/theme_config.dart';
import 'package:news_solusi/app/models/news_model.dart';
import 'package:news_solusi/app/ui/pages/detail_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: whiteColor,
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(top: 33, left: 17, right: 17),
          child: Column(
            children: [
              fixedSection(),
              const SizedBox(
                height: 10,
              ),
              BlocBuilder<NewsCubit, NewsState>(
                builder: (context, state) {
                  if (state is NewsLoading) {
                    return Expanded(
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: ListView.builder(
                          itemCount: 6,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 1.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const SizedBox(height: 80),
                            );
                          },
                        ),
                      ),
                    );
                  }
                  if (state is NewsLoaded) {
                    return scrollSection(context, state: state);
                  }
                  if (state is NewsError) {
                    return Center(
                      child: Text(state.msg),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ));
  }

  Column fixedSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Hi, Bagus',
              style: mainTextStyle.copyWith(
                fontSize: sizeFontProfile,
                fontWeight: medium,
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Container(
              width: 21,
              height: 21,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/icons/ic_profile.png'))),
            )
          ],
        ),
        const SizedBox(
          height: 18,
        ),
        TextFormField(
          decoration: InputDecoration(
            hintText: 'Cari Klinik/Rumah Sakit',
            hintStyle: GoogleFonts.rubik(
                fontSize: 12, fontWeight: regular, color: greySearchColor),
            contentPadding:
                const EdgeInsets.only(top: 12, bottom: 12, left: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget scrollSection(BuildContext context, {required NewsLoaded state}) {
    return Expanded(
      child: SmartRefresher(
        controller: NewsCubit.refreshController,
        enablePullDown: false,
        enablePullUp: (((state.page * state.pageSize) != state.totalResults) &&
            (state.page * state.pageSize) < state.totalResults),
        onLoading: () {
          context.read<NewsCubit>().onLoadMoreNews();
        },
        onRefresh: context.read<NewsCubit>().onRefresh,
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildInfoAntrian(context),
              const SizedBox(
                height: 23,
              ),
              buildIconsFav1(),
              const SizedBox(
                height: 13,
              ),
              buildIconsFav2(),
              const SizedBox(
                height: 13,
              ),
              CarouselSlider.builder(
                itemCount: urlImages.length,
                itemBuilder: (context, index, realIndex) {
                  final urlImage = urlImages[index];

                  return buildImage(urlImage, index);
                },
                options: CarouselOptions(),
              ),
              BlocBuilder<NewsCubit, NewsState>(
                builder: (context, state) {
                  if (state is NewsLoading) {
                    return SizedBox(
                      width: 200.0,
                      height: 100.0,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: ListView.builder(
                          itemCount: 6,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 1.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const SizedBox(height: 80),
                            );
                          },
                        ),
                      ),
                    );
                  }
                  if (state is NewsLoaded) {
                    final List<Article> articles = state.articles;

                    return ListView.separated(
                        separatorBuilder: (_, _i) {
                          return const SizedBox(
                            height: 10,
                          );
                        },
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        itemCount: articles.length,
                        itemBuilder: (context, index) {
                          String date = DateFormat('EEEE, d MMM yyy HH:mm')
                              .format(DateTime.parse(
                                  articles[index].publishedAt ??
                                      DateTime.now().toIso8601String()));

                          return Column(
                            children: [
                              Container(
                                alignment: Alignment.center, //need this
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: CachedNetworkImage(
                                    height: 152,
                                    imageUrl: articles[index].urlToImage ??
                                        'https://upload.wikimedia.org/wikipedia/commons/d/d1/Image_not_available.png',
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover),
                                          ),
                                        ),
                                    placeholder: (context, url) => const SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: Center(
                                            child:
                                                CircularProgressIndicator())),
                                    errorWidget: (context, url, error) {
                                      print('ERROR url $url');
                                      return Image.asset(
                                          'assets/images/Image_not_available.png');
                                    }),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Center(
                                child: Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Text(
                                    articles[index].title ??
                                        'Judul tidak ditemukan',
                                    style: GoogleFonts.rubik(
                                        fontSize: 18,
                                        fontWeight: medium,
                                        color: greyColor),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      'Sumber : ${articles[index].source?.name}',
                                      style: GoogleFonts.rubik(
                                          fontSize: 10,
                                          fontWeight: regular,
                                          color: greyTextSoftColor),
                                    )),
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      '$date WIB',
                                      style: GoogleFonts.rubik(
                                          fontSize: 10,
                                          fontWeight: regular,
                                          color: greyTextSoftColor),
                                    )),
                              ),
                              const SizedBox(
                                height: 3,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      articles[index].description ??
                                          'Deskripsi tidak ditemukan',
                                      textAlign: TextAlign.justify,
                                      style: GoogleFonts.rubik(
                                          fontSize: 10,
                                          fontWeight: regular,
                                          color: greyColor),
                                    )),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DetailPage(model: articles[index]),
                                      ));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Text(
                                        'Baca Selengkapnya...',
                                        style: GoogleFonts.rubik(
                                            fontSize: 10,
                                            fontWeight: regular,
                                            color: primaryBlue),
                                      )),
                                ),
                              ),
                            ],
                          );
                        });
                  }
                  if (state is NewsError) {
                    return Center(
                      child: Text(state.msg),
                    );
                  }
                  return const SizedBox.shrink();
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildImage(String urlImage, int index) {
    return Container(
      alignment: Alignment.center, //need this
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: CachedNetworkImage(
        height: 106,
        imageUrl: urlImage,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
                colorFilter:
                    const ColorFilter.mode(Colors.red, BlendMode.colorBurn)),
          ),
        ),
        placeholder: (context, url) => const SizedBox(
            width: 50,
            height: 50,
            child: Center(child: CircularProgressIndicator())),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }

  Row buildIconsFav2() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildIcon(
            asset: 'assets/icons/ic_notif.png',
            color: primaryBlue,
            desc: 'NOTIFIKASI'),
        buildIcon(
            asset: 'assets/icons/ic_nilai.png',
            color: purpleColor,
            desc: 'BERI NILAI'),
        buildIcon(
            asset: 'assets/icons/ic_pengaturan.png',
            color: pinkColor,
            desc: 'PENGATURAN'),
      ],
    );
  }

  Row buildIconsFav1() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildIcon(
            asset: 'assets/icons/ic_klinik.png',
            color: primaryBlue,
            desc: 'KLINIK\nTERDEKAT'),
        buildIcon(
            asset: 'assets/icons/ic_riwayat.png',
            color: primaryBlue,
            desc: 'RIWAYAT'),
        buildIcon(
            asset: 'assets/icons/ic_scan.png',
            color: purpleColor,
            desc: 'DATA SCAN'),
      ],
    );
  }

  Widget buildIcon(
      {required String asset, required String desc, required Color color}) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center, //this is needed
          width: 55,
          height: 55,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(20)),
          child: Image.asset(
            asset,
            width: 35,
            height: 25,
          ),
        ),
        const SizedBox(
          height: 11,
        ),
        Text(
          desc,
          textAlign: TextAlign.center,
          style: GoogleFonts.rubik(
              color: greyColor, fontSize: 10, fontWeight: medium),
        )
      ],
    );
  }

  Container buildInfoAntrian(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.21,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryBlue, purpleColor]),
        borderRadius: BorderRadius.circular(defaultBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 21, bottom: 8),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'INFO ANTRIAN',
                style: whiteTextStyle.copyWith(fontSize: 12, fontWeight: bold),
              ),
            ),
          ),
          const Divider(
            height: 1,
            color: whiteColor,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15, top: 13, left: 23),
            child: Row(
              children: [
                buildAntrian(
                    nomor: '21',
                    desc: 'Nomor antrian',
                    asset: 'assets/icons/ic_nomor.png'),
                const SizedBox(
                  width: 10,
                ),
                buildAntrian(
                    nomor: '5',
                    desc: 'Sisa antrian',
                    asset: 'assets/icons/ic_sisa.png'),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dokter anda',
                          style: GoogleFonts.rubik(
                              color: Color(
                                0xffFFF9AA,
                              ),
                              fontSize: 9,
                              fontWeight: medium),
                        ),
                        Text(
                          'dr. Rina Agustina',
                          style: whiteTextStyle.copyWith(
                              fontSize: 9, fontWeight: medium),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Klinik / RS anda',
                          style: GoogleFonts.rubik(
                              color: Color(
                                0xffFFF9AA,
                              ),
                              fontSize: 9,
                              fontWeight: medium),
                        ),
                        Text(
                          'RS. National Hospital',
                          style: whiteTextStyle.copyWith(
                              fontSize: 9, fontWeight: medium),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildAntrian(
      {required String nomor, required String desc, required String asset}) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration:
              BoxDecoration(image: DecorationImage(image: AssetImage(asset))),
          child: Center(
            child: Text(
              nomor,
              style: whiteTextStyle.copyWith(fontSize: 25, fontWeight: medium),
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          desc,
          style: whiteTextStyle.copyWith(fontSize: 9, fontWeight: bold),
        ),
      ],
    );
  }
}

List<Widget> _itemNews = [];

List<String> urlImages = [
  'https://images.unsplash.com/photo-1554734867-bf3c00a49371?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=870&q=80',
  'https://images.unsplash.com/photo-1485848395967-65dff62dc35b?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=869&q=80',
  'https://images.unsplash.com/photo-1581360742512-021d5b2157d8?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=579&q=80',
  'https://images.unsplash.com/photo-1519494140681-8b17d830a3e9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=874&q=80',
  'https://images.unsplash.com/photo-1533042789716-e9a9c97cf4ee?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=869&q=80'
];


/**
 * 
 */