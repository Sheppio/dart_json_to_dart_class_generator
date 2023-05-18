class Root {
  String id;
  String title;
  String screenLayout;
  bool isAdult;
  List<RootItem> items;

  Root({
    required this.id,
    required this.title,
    required this.screenLayout,
    required this.isAdult,
    required this.items,
  });
}

class RootItem {
  String id;
  String image;
  String screenLayout;
  String contentType;
  bool isAdult;
  RootItemGridLink gridLink;

  RootItem({
    required this.id,
    required this.image,
    required this.screenLayout,
    required this.contentType,
    required this.isAdult,
    required this.gridLink,
  });
}

class RootItemGridLink {
  String id;
  String type;
  String title;
  RootItemGridLinkTheme theme;

  RootItemGridLink(
      {required this.id,
      required this.type,
      required this.title,
      required this.theme});
}

class RootItemGridLinkTheme {
  String? background;
  String logoFocused;
  String? logoNonfocused;
  String? brandLogoImage;
  String? channelLogoUrl;

  RootItemGridLinkTheme({
    this.background,
    required this.logoFocused,
    this.logoNonfocused,
    this.brandLogoImage,
    this.channelLogoUrl,
  });
}
