import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:superheroes/resources/superheroes_images.dart';

class MainBloc {
  static const MIN_SYMBOLS = 3;

  final BehaviorSubject<MainPageState> stateSubject = BehaviorSubject();
  final favoritesSuperheroesSubject =
      BehaviorSubject<List<SuperheroInfo>>.seeded(SuperheroInfo.mocked);
  final searchedSuperheroesSubject = BehaviorSubject<List<SuperheroInfo>>();
  final currentTextSubject = BehaviorSubject<String>.seeded("");

  StreamSubscription? textSubscription;
  StreamSubscription? searchSubscription;

  MainBloc() {
    stateSubject.add(MainPageState.noFavorites);

    textSubscription = Rx.combineLatest2<String, List<SuperheroInfo>, MainPageStateInfo>(
      currentTextSubject.distinct().debounceTime(Duration(microseconds: 500)),
      favoritesSuperheroesSubject,
      (searchedText, favorites) => MainPageStateInfo(searchedText, favorites.isNotEmpty),
    ).listen((value) {
      searchSubscription?.cancel();
      if (value.searchedText.isEmpty) {
        if (value.haveFavorites) {
          stateSubject.add(MainPageState.favorites);
        } else {
          stateSubject.add(MainPageState.noFavorites);
        }
      } else if (value.searchedText.length < MIN_SYMBOLS) {
        stateSubject.add(MainPageState.minSymbols);
      } else {
        searchForSuperheroes(value.searchedText);
      }
    });
  }

  void searchForSuperheroes(final String text) {
    stateSubject.add(MainPageState.loading);
    searchSubscription = search(text).asStream().listen(
      (searchResults) {
        if (searchResults.isEmpty) {
          stateSubject.add(MainPageState.nothingFound);
        } else {
          searchedSuperheroesSubject.add(searchResults);
          stateSubject.add(MainPageState.searchResult);
        }
      },
      onError: (error, stackTrace) {
        stateSubject.add(MainPageState.loadingError);
      },
    );
  }

  Stream<List<SuperheroInfo>> observeFavoriteSuperheroes() => favoritesSuperheroesSubject;

  Stream<List<SuperheroInfo>> observeSearchedSuperheroes() => searchedSuperheroesSubject;

  Future<List<SuperheroInfo>> search(final String text) async {
    await Future.delayed(Duration(seconds: 1));

    final List<SuperheroInfo> heroes = [];
    SuperheroInfo.mocked.forEach((hero) {
      if (hero.name.toLowerCase().contains(text.toLowerCase())) {
        heroes.add(hero);
      }
    });
    return heroes;

    // return SuperheroInfo.mocked;
  }

  Stream<MainPageState> observeMainPageState() => stateSubject;

  void nextState() {
    final currentState = stateSubject.value;
    final nextState = MainPageState
        .values[(MainPageState.values.indexOf(currentState) + 1) % MainPageState.values.length];
    stateSubject.sink.add(nextState);
  }

  void updateText(final String? text) {
    /*final String? capitalizedText = text
        ?.split(" ")
        .map((e) => "${e[0].toUpperCase()}${e.substring(1)}")
        .join(" ");
    print(capitalizedText);*/
    currentTextSubject.add(text ?? "");
  }

  void dispose() {
    stateSubject.close();
    favoritesSuperheroesSubject.close();
    searchedSuperheroesSubject.close();
    currentTextSubject.close();

    textSubscription?.cancel();
    searchSubscription?.cancel();
  }
}

enum MainPageState {
  noFavorites,
  minSymbols,
  loading,
  nothingFound,
  loadingError,
  searchResult,
  favorites,
}

class SuperheroInfo {
  final String name;
  final String realName;
  final String imageUrl;

  const SuperheroInfo({
    required this.name,
    required this.realName,
    required this.imageUrl,
  });

  @override
  String toString() {
    return 'SuperheroInfo{name: $name, realName: $realName, imageUrl: $imageUrl}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuperheroInfo &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          realName == other.realName &&
          imageUrl == other.imageUrl;

  @override
  int get hashCode => name.hashCode ^ realName.hashCode ^ imageUrl.hashCode;

  static const mocked = [
    SuperheroInfo(
      name: "Batman",
      realName: "Bruce Wayne",
      imageUrl: SuperheroesImages.batmanImageUrl,
    ),
    SuperheroInfo(
      name: "Ironman",
      realName: "Tony Stark",
      imageUrl: SuperheroesImages.ironmanImageUrl,
    ),
    SuperheroInfo(
      name: "Venom",
      realName: "Eddie Brock",
      imageUrl: SuperheroesImages.venomImageUrl,
    ),
  ];
}

class MainPageStateInfo {
  final String searchedText;
  final bool haveFavorites;

  const MainPageStateInfo(this.searchedText, this.haveFavorites);

  @override
  String toString() {
    return 'MainPageStateInfo{searchedText: $searchedText, haveFavorites: $haveFavorites}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MainPageStateInfo &&
          runtimeType == other.runtimeType &&
          searchedText == other.searchedText &&
          haveFavorites == other.haveFavorites;

  @override
  int get hashCode => searchedText.hashCode ^ haveFavorites.hashCode;
}
