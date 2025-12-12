enum Genre {
  fiction("FICTION"),
  scifi("SCIFI"),
  mystery("MYSTERY"),
  romance("ROMANCE"),
  science("SCIENCE"),
  history("HISTORY"),
  fantasy("FANTASY"),
  thriller("THRILLER"),
  biography("BIOGRAPHY"),
  other("OTHER");

  final String value;
  const Genre(this.value);

  static Genre fromString(String value) {
    return Genre.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => Genre.other,
    );
  }
}
