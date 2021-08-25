import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:superheroes/blocs/main_bloc.dart';
import 'package:superheroes/resources/superheroes_colors.dart';
import 'package:superheroes/resources/superheroes_images.dart';
import 'package:superheroes/widgets/action_button.dart';
import 'package:superheroes/widgets/info_with_button.dart';
import 'package:superheroes/widgets/superhero_card.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final MainBloc bloc = MainBloc();

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
        backgroundColor: SuperheroesColors.background,
        body: SafeArea(
          child: MainPageContent(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }
}

class MainPageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context);
    return Stack(
      children: [
        MainPageStateWidget(),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: ActionButton(
              onTap: () => bloc.nextState(),
              text: "Next state",
            ),
          ),
        ),
      ],
    );
  }
}

class MainPageStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MainBloc bloc = Provider.of<MainBloc>(context);
    return StreamBuilder<MainPageState>(
      stream: bloc.observeMainPageState(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return SizedBox();
        }
        final MainPageState state = snapshot.data!;
        switch (state) {
          case MainPageState.noFavorites:
            return InfoWithButton(
              title: "No favorites yet",
              subtitle: "Search and add",
              buttonText: "Search",
              assetImage: SuperheroesImages.ironman,
              imageHeight: 119,
              imageWidth: 108,
              imageTopPadding: 9.0,
            );
          case MainPageState.minSymbols:
            return MinSymbolsText();
          case MainPageState.loading:
            return LoadingIndicator();
          case MainPageState.nothingFound:
            return InfoWithButton(
              title: "Nothing found",
              subtitle: "Search for something else",
              buttonText: "Search",
              assetImage: SuperheroesImages.hulk,
              imageHeight: 112,
              imageWidth: 84,
              imageTopPadding: 16.0,
            );
          case MainPageState.loadingError:
            return InfoWithButton(
              title: "Error happened",
              subtitle: "Please, try again",
              buttonText: "Retry",
              assetImage: SuperheroesImages.superman,
              imageHeight: 106,
              imageWidth: 126,
              imageTopPadding: 22.0,
            );
          case MainPageState.searchResult:
            return SearchResultPage();
          case MainPageState.favorites:
            return FavoritesPage();
          default:
            return DefaultWidget(state: state);
        }
      },
    );
  }
}

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 110),
        child: CircularProgressIndicator(
          color: SuperheroesColors.loadingIndicator,
          strokeWidth: 4,
        ),
      ),
    );
  }
}

class MinSymbolsText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 110),
        child: Text(
          "Enter at least 3 symbols",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class SearchResultPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 114),
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Search results",
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SuperheroCard(
            name: "Batman",
            realName: "Bruce Wane",
            imageUrl: SuperheroesImages.batmanImageUrl,
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SuperheroCard(
            name: "Venom",
            realName: "Eddi Brock",
            imageUrl: SuperheroesImages.venomImageUrl,
          ),
        ),
      ],
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 114),
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Your favorites",
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SuperheroCard(
            name: "Batman",
            realName: "Bruce Wane",
            imageUrl: SuperheroesImages.batmanImageUrl,
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SuperheroCard(
            name: "Ironman",
            realName: "Tony Stark",
            imageUrl: SuperheroesImages.ironmanImageUrl,
          ),
        ),
      ],
    );
  }
}

class DefaultWidget extends StatelessWidget {
  final MainPageState state;

  DefaultWidget({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        state.toString(),
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }
}
