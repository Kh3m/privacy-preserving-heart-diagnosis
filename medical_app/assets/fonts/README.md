# Fonts

`CustomIcons.ttf` is a generated icon font and ships with this repository.

The app was originally designed with **SF Pro Display**. Those files are not
included here: Apple licenses SF Pro for designing and developing apps for
Apple platforms, but does not permit redistributing the font files, so they
cannot live in a public repository.

The app builds and runs without them and falls back to the platform default
font (Roboto on Android, San Francisco on iOS).

To restore the intended typography, either:

1. Download SF Pro from https://developer.apple.com/fonts/ and drop
   `SFProDisplay-{Bold,Semibold,Regular,Light}.otf` into this directory, or
2. Substitute a metrically similar open font such as Inter (SIL Open Font
   License) from https://fonts.google.com/specimen/Inter.

Then re-add the family to `pubspec.yaml`:

```yaml
  fonts:
    - family: CustomIcons
      fonts:
        - asset: assets/fonts/CustomIcons.ttf
    - family: SFProDisplay
      fonts:
        - asset: assets/fonts/SFProDisplay-Bold.otf
          weight: 700
        - asset: assets/fonts/SFProDisplay-Semibold.otf
          weight: 600
        - asset: assets/fonts/SFProDisplay-Regular.otf
          weight: 400
        - asset: assets/fonts/SFProDisplay-Light.otf
          weight: 300
```

and set `fontFamily: 'SFProDisplay'` in the `ThemeData` in `lib/main.dart`.
