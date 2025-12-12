enum Language {
  english("ENGLISH"),
  russian("RUSSIAN"),
  german("GERMAN"),
  french("FRENCH"),
  spanish("SPANISH"),
  italian("ITALIAN"),
  turkish("TURKISH"),
  azerbaijani("AZERBAIJANI"),
  other("OTHER");

  final String value;
  const Language(this.value);

  static Language fromString(String value) {
    return Language.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => Language.other,
    );
  }
}
