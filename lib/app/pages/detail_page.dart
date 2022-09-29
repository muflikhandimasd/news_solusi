import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:news_solusi/app/cubit/news_cubit.dart';
import 'package:news_solusi/app/helpers/theme_config.dart';
import 'package:news_solusi/app/models/news_model.dart';
import 'package:shimmer/shimmer.dart';

class DetailPage extends StatelessWidget {
  final Article model;
  const DetailPage({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Berita',
          style: whiteTextStyle.copyWith(fontSize: 20, fontWeight: medium),
        ),
      ),
      body: BlocBuilder<NewsCubit, NewsState>(
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
            String date = DateFormat('EEEE, d MMM yyy HH:mm').format(
                DateTime.parse(
                    model.publishedAt ?? DateTime.now().toIso8601String()));
            return Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Container(
                  alignment: Alignment.center, //need this
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  child: CachedNetworkImage(
                    height: 152,
                    imageUrl: model.urlToImage ??
                        'https://upload.wikimedia.org/wikipedia/commons/d/d1/Image_not_available.png',
                    imageBuilder: (context, imageProvider) => Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => const SizedBox(
                        width: 50,
                        height: 50,
                        child: Center(child: CircularProgressIndicator())),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      model.title ?? 'Judul tidak diketahui',
                      style: GoogleFonts.rubik(
                          fontSize: 18, fontWeight: medium, color: greyColor),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Sumber : ${model.source?.name}',
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
                  padding: const EdgeInsets.symmetric(horizontal: 12),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        model.content ?? 'Content tidak diketahui',
                        textAlign: TextAlign.justify,
                        style: GoogleFonts.rubik(
                            fontSize: 10,
                            fontWeight: regular,
                            color: greyColor),
                      )),
                ),
              ],
            );
          }

          if (state is NewsError) {
            return Center(
              child: Text(
                'Error ${state.msg}',
                style: GoogleFonts.rubik(
                    fontSize: 12, fontWeight: regular, color: Colors.red),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
