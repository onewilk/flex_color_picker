import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import 'color_indicator.dart';
import 'color_picker_extensions.dart';
import 'color_tools.dart';
import 'color_wheel_picker.dart';
import 'functions/picker_functions.dart';
import 'models/color_picker_action_buttons.dart';
import 'models/color_picker_copy_paste_behavior.dart';
import 'models/color_picker_type.dart';
import 'universal_widgets/if_wrapper.dart';
import 'widgets/color_code_field.dart';
import 'widgets/color_picker_toolbar.dart';
import 'widgets/context_copy_paste_menu.dart';
import 'widgets/main_colors.dart';
import 'widgets/picker_selector.dart';
import 'widgets/recent_colors.dart';
import 'widgets/shade_colors.dart';

const int _minRecentColors = 2;
const int _maxRecentColors = 20;

/// A customizable Material primary color, accent color and custom colors,
/// color picker widget.
///
/// You can configure which material color swatches can be used for color
/// selection, any combination of both primary/accent in same picker or in
/// separate groups. There is an almost black and white shades picker page and
/// it is possible to include a page with custom material and accent swatches
/// using custom names for the custom swatches.
/// It is possible to specify if only the main color in a swatch should be
/// selectable or its shades as well.
///
/// There is also a color wheel picker that allows you to select any
/// color and automatically generate a Material primary swatch for the
/// selected color.
///
/// If a selected color in the wheel picker belongs to any standard Material
/// color, primary or accent, and any of its shades or any of the provided
/// custom color swatches, then the wheel picker will not calculate swatch
/// colors, it will instead show all the shades from the selected color's
/// swatch. Selecting the shades on the wheel picker will then select the shade
/// and show where the color shade is on the HSV wheel. If a selected color is
/// not any of the defined ones, then the wheel picker will always generate a
/// new swatch from the selected color, using the selected color as the new
/// primary swatch 500 index midpoint.
class ColorPicker extends StatefulWidget {
  /// Default constructor for the color picker.
  const ColorPicker({
    Key? key,
    this.color = Colors.blue,
    required this.onColorChanged,
    this.onColorChangeStart,
    this.onColorChangeEnd,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.padding = const EdgeInsets.all(16),
    this.columnSpacing = 8,
    this.enableShadesSelection = true,
    this.includeIndex850 = false,
    // this.hasOpacity = false,
    // this.hasAlpha = false,
    this.actionButtons = const ColorPickerActionButtons(),
    this.copyPasteBehavior = const ColorPickerCopyPasteBehavior(),
    this.selectedColorIcon = Icons.check,
    // Picker item and wheel picker properties.
    this.width = 40.0,
    this.height = 40.0,
    this.spacing = 4,
    this.runSpacing = 4,
    this.elevation = 0,
    this.hasBorder = false,
    this.borderRadius,
    this.borderColor,
    this.wheelDiameter = 190,
    this.wheelWidth = 16,
    this.wheelHasBorder = false,
    // Title, headings and sub headings used by the color picker.
    this.title,
    this.heading,
    this.subheading,
    this.wheelSubheading,
    this.recentColorsSubheading,
    // Toggles to show color names and codes and their text styles.
    this.showMaterialName = false,
    this.materialNameTextStyle,
    this.showColorName = false,
    this.colorNameTextStyle,
    this.showColorCode = false,
    this.colorCodeHasColor = false,
    this.colorCodeTextStyle,
    this.colorCodeIcon,
    this.colorCodePrefixStyle,
    this.colorCodeReadOnly = false,
    this.showColorValue = false,
    // Toggles showing the recent colors selection.
    this.showRecentColors = false,
    this.maxRecentColors = 5,
    this.recentColors = const <Color>[],
    this.onRecentColorsChanged,
    // Enable tooltips
    this.enableTooltips = true,
    // Color picker types shown and used by the color picker.
    this.pickersEnabled = const <ColorPickerType, bool>{
      ColorPickerType.both: false,
      ColorPickerType.primary: true,
      ColorPickerType.accent: true,
      ColorPickerType.bw: false,
      ColorPickerType.custom: false,
      ColorPickerType.wheel: false,
    },
    // Segmented color picker selector control properties.
    this.selectedPickerTypeColor,
    this.pickerTypeTextStyle,
    this.pickerTypeLabels = const <ColorPickerType, String>{
      ColorPickerType.primary: _selectPrimaryLabel,
      ColorPickerType.accent: _selectAccentLabel,
      ColorPickerType.bw: _selectBlackWhiteLabel,
      ColorPickerType.both: _selectBothLabel,
      ColorPickerType.custom: _selectCustomLabel,
      ColorPickerType.wheel: _selectWheelAnyLabel,
    },
    // Custom color swatches and name map for the custom color swatches.
    this.customColorSwatchesAndNames,
    //
  })  : assert(columnSpacing >= 0 && columnSpacing <= 300,
            'The picker item column spacing must be >= 0 and <= 300 dp.'),
        assert(width > 15 && width <= 150,
            'The pick item width must be > 15 and <= 150 dp.'),
        assert(height > 15 && height <= 150,
            'The pick item height must be > 15 and <= 150 dp.'),
        assert(wheelDiameter >= 100 && wheelDiameter <= 500,
            'The wheel diameter must be >= 100 and <= 500.'),
        assert(wheelWidth >= 4 && wheelWidth <= 50,
            'The color wheel width must be >= 4 and <= 50 dp.'),
        assert(
            maxRecentColors >= _minRecentColors &&
                maxRecentColors <= _maxRecentColors,
            'The maxRecentColors must be $_minRecentColors 2 '
            'and <= $_maxRecentColors'),
        super(key: key);

  /// The active color selection when the color picker is created.
  final Color color;

  /// Required [ValueChanged] callback, called when user selects
  /// a new color with new color value.
  ///
  /// Called everytime the color value changes when operating thumbs on the
  /// color wheel or color or transparency sliders
  ///
  /// Changing which picker type is viewed does not trigger this callback, it
  /// is not triggered until a color in the viewed picker is selected.
  final ValueChanged<Color> onColorChanged;

  /// Optional [ValueChanged] callback. Called when user starts color selection
  /// with current color value.
  ///
  /// When clicking a new color in color items, the color value before the
  /// selected new value was clicked is returned. It is also called
  /// with the current start color when user starts the interaction on the
  /// color wheel or on a color or transparency slider.
  final ValueChanged<Color>? onColorChangeStart;

  /// Optional [ValueChanged] callback. Called when user ends color selection
  /// with the new color value.
  ///
  /// When clicking a new color in color items, the clicked color is returned.
  /// It is also called with the resulting color value when user ends the
  /// interaction on the color wheel or on a color or transparency slider.
  final ValueChanged<Color>? onColorChangeEnd;

  /// Cross axis alignment used to layout the main content of the
  /// color picker in a column. Defaults to CrossAxisAlignment.center.
  final CrossAxisAlignment crossAxisAlignment;

  /// Padding around the entire color picker content.
  ///
  /// Defaults to const EdgeInsets.all(16).
  final EdgeInsetsGeometry padding;

  /// Vertical spacing between items in the color picker column.
  ///
  /// Default to 8 dp.
  final double columnSpacing;

  /// Set to true to allow selection of color swatch shades. If false
  /// only the main color from a swatch is shown and can be selected. This
  /// is index [500] for Material primary colors and index [200] for accent
  /// colors.
  ///
  /// Defaults to true.
  final bool enableShadesSelection;

  /// There is an extra index [850] used only by grey Material color in Flutter.
  /// If you want to include it in the grey color shades selection, then set
  /// to true.
  ///
  /// Defaults to false.
  final bool includeIndex850;

  // TODO: Implement opacity control.
  // Enable the opacity control for the color value.
  //
  // Turning it to true allows users to control the opacity value of the
  // selected color. Opacity goes from 0, which is totally transparent,
  // to 1, which if fully opaque. The control can be enabled together with
  // the alpha channel control. Ultimately they control the same alpha
  // color transparency value, they are just different formats.
  // Normally you would select which one you prefer and not enable both styles,
  // but it is possible to show both controls at the same time.
  //
  // Defaults to false.
  // final bool hasOpacity;

  // TODO: Implement alpha control.
  // Enable alpha control for the color value.
  //
  // Turning it to true allows users to control the alpha value of the
  // selected color. Alpha goes from 00 (hex), which is fully transparent,
  // to FF (hex), which if fully opaque. The control can be enabled together
  // with the opacity control. Ultimately they control the same alpha
  // color transparency value, they are just different formats.
  // Normally you would select which one you prefer and not enable both styles,
  // but it is possible to show both controls at the same time.
  //
  // Defaults to false.
  //final bool hasAlpha;

  /// Defines icons for the color picker title bar and its actions.
  ///
  /// Defaults to ColorPickerToolIcons().
  final ColorPickerActionButtons actionButtons;

  /// A class the defined the copy paste of color values from and to the picker.
  ///
  /// Defaults to ColorPickerPasteBehavior().
  final ColorPickerCopyPasteBehavior copyPasteBehavior;

  /// Icon data for the icon used to indicate the selected color.
  ///
  /// The size of the [selectedColorIcon] is 60% of the smaller of color
  /// indicator [width] and [height]. The color of indicator icon is
  /// black or white, based on what contrast best with the selected color.
  ///
  /// Defaults to a check mark ([Icons.check]).
  final IconData selectedColorIcon;

  /// Width of the color indicator items in dp.
  ///
  /// Defaults to 40 dp.
  final double width;

  /// Height of the color indicator items in dp.
  ///
  /// Defaults to 40 dp.
  final double height;

  /// The horizontal spacing between the color picker indicator items.
  ///
  /// Defaults to 4 dp.
  final double spacing;

  /// The space between the color picker color item rows, when they need to
  /// be wrapped to multiple rows.
  ///
  /// Defaults to 4 dp.
  final double runSpacing;

  /// The Material elevation of the color indicator items.
  ///
  /// Defaults to 0 dp.
  final double elevation;

  /// Set to true to show a 1 dp border around the color indicator items.
  ///
  /// This property is useful if the white/near white and black/near black
  /// shades color picker is enabled.
  ///
  /// Defaults to false.
  final bool hasBorder;

  /// Border radius of the color indicator items.
  ///
  /// Defaults to [width]/4.
  final double? borderRadius;

  /// The color of the 1 dp optional border used on [ColorIndicator] and on
  /// [ColorWheelPicker] when their has border toggle is true.
  ///
  /// If no color is given, the border color defaults to
  /// Theme.of(context).dividerColor.
  final Color? borderColor;

  /// Diameter in dp of the HSV based color wheel picker.
  ///
  /// Defaults to 190 dp.
  final double wheelDiameter;

  /// The stroke width of the color wheel circle in dp.
  ///
  /// Defaults to 16 dp.
  final double wheelWidth;

  /// Set to true to show a 1 dp border around the color wheel.
  ///
  /// Defaults to false.
  final bool wheelHasBorder;

  /// Title widget for the color picker.
  ///
  /// Typically a Text widget, e.g. Text('Primary color').
  /// If not provided or null, there is no heading for the color picker.
  ///
  /// This widget can be used instead of [heading] or with it, depends on design
  /// need. The title widget is like an app bar title in the sense that at
  /// the end of it, 1 to 4 actions buttons may also be present for copy, paste,
  /// select-close and cancel-close. These are typically only made available
  /// when the picker is used in a dialog.
  final Widget? title;

  /// Heading widget for the color picker.
  ///
  /// Typically a Text widget, e.g. Text('Select color').
  /// If not provided or null, there is no heading for the color picker.
  final Widget? heading;

  /// Subheading widget for the color shades selection.
  ///
  /// Typically a Text widget, e.g. Text('Select color shade').
  /// If not provided or null, there is no subheading for the color shades.
  final Widget? subheading;

  /// Subheading widget for the HSV color wheel picker.
  ///
  /// Typically a Text widget, e.g.
  /// Text('Selected color and its material like shades').
  ///
  /// The color wheel uses a separate subheading widget so that it may have
  /// another explanation, since its use case differs from the other subheading
  /// cases. If not provided, there is no subheading for the color wheel picker.
  final Widget? wheelSubheading;

  /// Subheading widget for the recently used colors.
  ///
  /// Typically a Text widget, e.g. Text('Recent colors').
  /// If not provided or null, there is no subheading for the recent color.
  final Widget? recentColorsSubheading;

  /// Set to true to show the Material name of the selected [color].
  ///
  /// Defaults to false.
  final bool showMaterialName;

  /// Text style for the displayed material color name in the picker.
  ///
  /// Defaults to Theme.of(context).textTheme.bodyText2, if not defined.
  final TextStyle? materialNameTextStyle;

  /// Set to true to show an English color name of the selected [color].
  ///
  /// Defaults to false.
  final bool showColorName;

  /// Text style for the displayed color name in the picker.
  ///
  /// Defaults to Theme.of(context).textTheme.bodyText2, if not defined.
  final TextStyle? colorNameTextStyle;

  /// Set to true to show the RGB Hex color code of the selected [color].
  ///
  /// The color code can be copied with copy icon button. On the wheel
  /// picker the color code can be edited to enter and select a color of a
  /// known RGB hex value.
  ///
  /// Defaults to false.
  final bool showColorCode;

  /// If true then the background of the color code entry field uses the current
  /// selected color.
  ///
  /// This makes the color code entry field a larger current color indicator
  /// area that changes color as the color value is changed.
  /// The text color of the filed will adjust to for best contrast as will
  /// the opacity indicator text. Enabling this feature will override any
  /// color specified in [colorCodeTextStyle] and [colorCodePrefixStyle] but
  /// their styles will otherwise be kept as specified.
  ///
  /// Defaults to false.
  final bool colorCodeHasColor;

  /// Text style for the displayed generic color name in the picker.
  ///
  /// Defaults to Theme.of(context).textTheme.bodyText2, if not defined.
  final TextStyle? colorCodeTextStyle;

  /// Old property, no longer in use. This property is now set via
  /// property [copyPasteBehavior] and [ColorPickerCopyPasteBehavior.copyIcon]
  @Deprecated('This property is deprecated and no longer has any function. '
      'It was removed in v2.x.x. To modify the copy icon on the color code '
      'entry field, define the `ColorPickerCopyPasteBehavior(copyIcon: myIcon)`'
      ' and provide it to the `copyPasteBehavior` property.')
  final IconData? colorCodeIcon;

  /// The TextStyle of the prefix of the color code.
  ///
  /// Defaults to [colorCodeTextStyle], if not defined.
  final TextStyle? colorCodePrefixStyle;

  /// If true, the color code field is always read only.
  ///
  /// If set to true, the color code field cannot be edited. Normally it can
  /// be edited when used in a picker that can select and show any color.
  /// Setting this to false makes it read only also on such pickers. This
  /// currently only applies to the wheel picker, but will also apply to
  /// future full color range pickers.
  ///
  /// Pickers that only offer a fixed palette that you can select the color from
  /// always have the color code field in read only mode, this setting does
  /// not affect them.
  ///
  /// Regardless of the picker and [colorCodeReadOnly] value, you can change
  /// color value by pasting in a new value, if your copy paste configuration
  /// allows it.
  ///
  /// Defaults to false.
  final bool colorCodeReadOnly;

  /// Set to true to show the int [Color.value] of the selected [color].
  ///
  /// This is a developer feature, showing the int color value can be
  /// useful during software development. If enabled the value is shown after
  /// the color code, if it is enabled too. For text style it uses the same
  /// property as the hex code [colorCodeTextStyle]. There is no copy button
  /// for the shown int value, but the value is using [SelectableText] widget so
  /// it can be select painted and copied if so required.
  ///
  /// Defaults to false.
  final bool showColorValue;

  /// Toggles showing the recent colors selection.
  ///
  /// Defaults to false.
  final bool showRecentColors;

  /// The maximum numbers of recent colors to show in a list.
  final int maxRecentColors;

  /// A list with the recently select colors.
  ///
  /// Defaults to an empty list of colors. You can provide a starting
  /// set from some stored state if so desired.
  final List<Color> recentColors;

  /// Callback that returns the current list of recently selected colors.
  final ValueChanged<List<Color>>? onRecentColorsChanged;

  /// Set to true to enable all tooltips in this widget.
  ///
  /// Currently only applies to 'Copy' tooltip on the copy color code button.
  ///
  /// Defaults to true.
  final bool enableTooltips;

  /// A [ColorPickerType] to bool map.
  ///
  /// Defines which picker types are
  /// enabled in the color picker's sliding segmented selector and
  /// are thus available as color pickers.
  ///
  /// Available options are based on the [ColorPickerType] enum that
  /// includes both, primary, accent, bw, custom and wheel.
  /// Any undefined or missing enum keys in a given map are treated as false.
  ///
  /// By default a map that that sets primary and accent pickers to true is
  /// used if no or a null map is given.
  final Map<ColorPickerType, bool> pickersEnabled;

  /// The color of the thumb on the slider that shows the selected picker.
  ///
  /// If not defined, defaults to Color(0xFFFFFFFF) (white) in light theme and
  /// to Color(0xFF636366) in dark theme, which are defaults for the used
  /// CupertinoSlidingSegmentedControl.
  final Color? selectedPickerTypeColor;

  /// The TextStyle of the labels in segmented control swatch selector.
  ///
  /// Defaults to Theme.of(context).textTheme.caption, if not defined.
  final TextStyle? pickerTypeTextStyle;

  /// A [ColorPickerType] to String map that contains labels for picker types.
  ///
  /// Default label strings are provided in English, if not defined.
  final Map<ColorPickerType, String> pickerTypeLabels;

  /// Color swatch to name map, with custom swatches and their names.
  ///
  /// Use to provide color swatches for the custom color picker, including their
  /// custom names. These colors, their swatch shades and names, are shown
  /// and used when the picker type [ColorPickerType.custom] option is enabled
  /// in the color picker.
  ///
  /// Has no default values and if omitted or null, the custom color picker will
  /// not be shown even if is enabled in [pickersEnabled].
  final Map<ColorSwatch<Object>, String>? customColorSwatchesAndNames;

  /// English default label for picker with both primary and accent colors.
  static const String _selectBothLabel = 'Primary & Accent';

  /// English default label for picker with primary colors.
  static const String _selectPrimaryLabel = 'Primary';

  /// English default label for picker with accent colors.
  static const String _selectAccentLabel = 'Accent';

  /// English default label for picker with black and white shades.
  static const String _selectBlackWhiteLabel = 'Black & White';

  /// English default label for picker with custom defined colors.
  static const String _selectCustomLabel = 'Custom';

  /// English default label for the HSV wheel picker that can select any color.
  static const String _selectWheelAnyLabel = 'Wheel';

  @override
  _ColorPickerState createState() => _ColorPickerState();

  /// Show the defined [ColorPicker] in a custom alert dialog.
  ///
  /// The [showPickerDialog] method is a convenience function to show the
  /// [ColorPicker] widget in a modal dialog. It re-implements the standard
  /// `showDialog` function with opinionated Cancel and Select buttons. It
  /// also by default uses a lighter barrier color. This is useful if the
  /// color picker is used to dynamically change color of a widget or entire
  /// application theme, since we can then better see the impact of the color
  /// choice behind the modal dialog when the barrier is made more transparent.
  ///
  /// Returns a Future bool that resolves to true, if the select color action
  /// was selected, and to false if the cancel action was selected, when the
  /// dialog was closed. Clicking outside the dialog also closes it and returns
  /// false.
  Future<bool> showPickerDialog(
    /// The dialog requires a BuildContext.
    BuildContext context, {

    /// Title of the color picker dialog, often omitted in favor of using
    /// [heading] already defined in the [ColorPicker].
    Widget? title,

    /// Padding around the dialog title, if a title is used.
    /// Defaults to const EdgeInsets.all(0), since the title is normally omitted
    /// and provided via the [heading] property of the [ColorPicker] instead.
    final EdgeInsetsGeometry titlePadding = const EdgeInsets.all(0),

    /// Padding around the Cancel and Select action buttons at the bottom of
    /// the dialog.
    ///
    /// Typically used to provide padding to the button bar between the button
    /// bar and the edges of the dialog.
    ///
    /// Defaults to const EdgeInsets.symmetric(horizontal: 16).
    final EdgeInsetsGeometry actionsPadding =
        const EdgeInsets.symmetric(horizontal: 16),

    /// The padding that surrounds each button in [actions].
    ///
    /// This is different from [actionsPadding], which defines the padding
    /// between the entire button bar and the edges of the dialog.
    ///
    /// Defaults to const EdgeInsets.all(16).
    final EdgeInsetsGeometry buttonPadding = const EdgeInsets.all(16),

    /// Padding around the content in the dialog.
    ///
    /// Defaults to const EdgeInsets.all(0), as the content padding is normally
    /// expected to be a part of the [ColorPicker].
    final EdgeInsetsGeometry contentPadding = const EdgeInsets.all(0),

    /// The amount of padding added to [MediaQueryData.viewInsets] on the
    /// outside of the [ColorPicker] dialog.
    ///
    /// Defines the minimum space between the screen's edges and the dialog.
    /// Defaults to EdgeInsets.symmetric(horizontal: 40, vertical: 24).
    final EdgeInsets insetPadding =
        const EdgeInsets.symmetric(horizontal: 40, vertical: 24),

    /// If true, the dialog can be closed by clicking outside it.
    /// Defaults to true.
    bool barrierDismissible = true,

    /// The background transparency color of the dialog barrier.
    ///
    /// Defaults to [Colors.black12] which is considerably lighter than the
    /// standard [Colors.black54] and allows us to see impact of selected color
    /// on app behind the dialog. If this is not desired, set it back to
    /// [Colors.black54] when you call [showPickerDialog].
    ///
    /// You can also make the barrier completely transparent.
    Color barrierColor = Colors.black12,

    /// The `useSafeArea` argument is used to indicate if the dialog should only
    /// display in 'safe' areas of the screen not used by the operating system
    /// (see [SafeArea] for more details). It is `true` by default, which means
    /// the dialog will not overlap operating system areas. If it is set to
    /// `false` the dialog will only be constrained by the screen size.
    /// It can not be `null`.
    bool useSafeArea = true,

    /// The `useRootNavigator` argument is used to determine whether to push the
    /// dialog to the [Navigator] furthest from or nearest to the given
    /// `context`.
    /// By default, `useRootNavigator` is `true` and the dialog route created
    /// by this method is pushed to the root navigator. It can not be `null`.
    bool useRootNavigator = true,

    /// The `routeSettings` argument is passed to [showGeneralDialog],
    /// see [RouteSettings] for details.
    RouteSettings? routeSettings,

    /// You can provide BoxConstraints to constrain the size of the dialog.
    /// You might want to do this at least for the height, otherwise
    /// the dialog might jump up and down jarringly if its size changes when
    /// user changes the picker type with the selector.¨
    ///
    /// Normally you would not change the picker's content element sizes after
    /// you have determined what works in your implementation. You can usually
    /// figure out a good dialog box size that works well for your use case,
    /// instead of allowing the color picker dialog to auto size itself,
    /// which it will do if no constraints are defined.
    BoxConstraints? constraints,
  }) async {
    assert(debugCheckHasMaterialLocalizations(context),
        'A context with Material localizations is required');
    // Get the Material localizations.
    final MaterialLocalizations translate = MaterialLocalizations.of(context);

    // Make the dialog OK button.
    final String _okButtonLabel =
        actionButtons.dialogOkButtonLabel ?? translate.okButtonLabel;
    final Widget _okButtonContent = Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        if (actionButtons.dialogActionIcons)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 4),
            child: Icon(actionButtons.okIcon),
          ),
        Text(_okButtonLabel),
      ],
    );
    Widget _okButton;
    switch (actionButtons.dialogOkButtonType) {
      case ColorPickerActionButtonType.text:
        _okButton = TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: _okButtonContent,
        );
        break;
      case ColorPickerActionButtonType.outlined:
        _okButton = OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: _okButtonContent,
        );
        break;
      case ColorPickerActionButtonType.elevated:
        _okButton = ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: _okButtonContent,
        );
        break;
    }

    // Make the dialog OK button.
    final String _cancelButtonLabel =
        actionButtons.dialogCancelButtonLabel ?? translate.cancelButtonLabel;
    final Widget _cancelButtonContent = Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        if (actionButtons.dialogActionIcons)
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 4),
            child: Icon(actionButtons.closeIcon),
          ),
        Text(_cancelButtonLabel),
      ],
    );
    Widget _cancelButton;
    switch (actionButtons.dialogCancelButtonType) {
      case ColorPickerActionButtonType.text:
        _cancelButton = TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: _cancelButtonContent,
        );
        break;
      case ColorPickerActionButtonType.outlined:
        _cancelButton = OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: _cancelButtonContent,
        );
        break;
      case ColorPickerActionButtonType.elevated:
        _cancelButton = ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: _cancelButtonContent,
        );
        break;
    }

    // False if dialog cancelled, true if color selected
    bool _colorWasSelected = false;

    await showDialog<bool>(
        context: context,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        useSafeArea: useSafeArea,
        useRootNavigator: useRootNavigator,
        routeSettings: routeSettings,
        builder: (BuildContext context) {
          return AlertDialog(
            titlePadding: titlePadding,
            contentPadding: contentPadding,
            actionsPadding: actionsPadding,
            buttonPadding: buttonPadding,
            insetPadding: insetPadding,
            title: title,
            content: constraints == null
                ? this
                : ConstrainedBox(
                    constraints: constraints,
                    child: this,
                  ),
            scrollable: true,
            actions: actionButtons.closeButton &&
                    actionButtons.okButton &&
                    !actionButtons.dialogActionButtons
                ? null
                : <Widget>[
                    if (actionButtons.dialogActionButtons ||
                        !actionButtons.closeButton)
                      _cancelButton,
                    if (actionButtons.dialogActionButtons ||
                        !actionButtons.okButton)
                      _okButton,
                  ],
          );
        }).then((bool? value) {
      // If the dialog return value was null, then we got here by a
      // barrier dismiss, then we set the return value to false.
      _colorWasSelected = value ?? false;
    });
    return _colorWasSelected;
  }
}

class _ColorPickerState extends State<ColorPicker> {
  // Focus node the entire color picker.
  late FocusNode _focusNode;
  // Focus node of the picker selector.
  late FocusNode _pickerFocusNode;

  // The currently active used list of color swatches we select
  // the active color from
  late List<ColorSwatch<Object>> _activeColorSwatchList;

  // The active Swatch in the active Color swatch List. Can be null temporarily
  // when we searched for a color in a swatched but did not find it anywhere.
  ColorSwatch<Object>? _activeSwatch;

  // Which picker are we using now.
  late ColorPickerType _activePicker;

  // Current selected color
  late Color _selectedColor;

  // Color picker indicator selected item should request focus.
  bool _selectedShouldFocus = true;

  // The edit code field has focus. When it does, double tap
  // for the gesture detector will not be used, nor will paste entries
  // use the parse and paste logic if `codeEntryParsedPaste` is false.
  bool _editCodeFocused = false;

  // Edit color code field should update? Whenever the edit code field is
  // updated outside the edit field, we need to send a signal back that it
  // should update.
  bool _editShouldUpdate = true;

  // Set to true if wheel picker should update. Whenever the wheel picker is
  // updated outside the wheel picker, we need to send a signal back that it
  // should update.
  bool _wheelShouldUpdate = true;

  // Color wheel picker should request focus.
  bool _wheelShouldFocus = false;

  // Set to true when a drag cancel occurs in the wheel.
  bool _wheelDragCancel = false;

  // Becomes true when we have more than one ColorPickerType available in
  // the `widget.pickersEnabled` property. If there is just one picker enabled
  // then that picker will be used, but we will not use the picker type
  // selector at all. If no picker is enabled, the material picker will be
  // used anyway, but there is no picker selector in that case either.
  bool _usePickerSelector = false;

  // We need a map we can guarantee has no gaps, so we make a local
  // version of it that is always complete,
  // gets initialized in the initSelectedValue() function.
  late Map<ColorPickerType, bool> _pickers;

  // The current state of list with recent color selections.
  late List<Color> _recentColors;

  // Map of swatch names in corresponding list of color swatches,
  // gets initialized in the initSelectedValue() function.
  late Map<ColorPickerType, List<ColorSwatch<Object>>> _typeToSwatchMap;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    _pickerFocusNode = FocusNode();

    // Always update the wheel and edit when ColorPicker is initialized, but
    // not in didUpdateWidget.
    _wheelShouldUpdate = true;
    _editShouldUpdate = true;

    // If there are no shade color widgets display, the wheel must focus
    // on init.
    _wheelShouldFocus = !widget.enableShadesSelection;

    // Set the selected color to the widget constructor provided start color
    _selectedColor = widget.color;

    // Update the list of the recent color to their initial value.
    _recentColors = <Color>[...widget.recentColors];

    // Initialize other values and find the best color picker to show
    // the current selectedColor value.
    _initSelectedValue(findPicker: true);
  }

  // A helper to initialize local state, called by:
  // * initState()
  // * didUpdateWidget()
  // * _getClipboard()
  // Called to initialize all the values and conditionally to again find the
  // first picker where the current color is located.
  void _initSelectedValue({bool findPicker = false}) {
    // The selected color(s) should request focus on init.
    if (findPicker) _selectedShouldFocus = true;

    // If no custom color map is provided (null) we use an empty map.
    final Map<ColorSwatch<Object>, String> colorsNameMap =
        widget.customColorSwatchesAndNames ?? <ColorSwatch<Object>, String>{};

    // A map with the picker type enum as key to color swatch lists.
    _typeToSwatchMap = <ColorPickerType, List<ColorSwatch<Object>>>{
      ColorPickerType.both: ColorTools.primaryAndAccentColors,
      ColorPickerType.primary: ColorTools.primaryColors,
      ColorPickerType.accent: ColorTools.accentColors,
      ColorPickerType.bw: ColorTools.blackAndWhite,
      ColorPickerType.custom: colorsNameMap.keys.toList(),
      ColorPickerType.wheel: <ColorSwatch<Object>>[
        // TODO: Redesign when enable opacity/alpha.
        // Make a swatch of the selected color in the wheel.
        ColorTools.primarySwatch(_selectedColor.withAlpha(0xFF))
      ],
    };

    // Set useCustomPicker to false if no custom data for it was provided,
    // even if using custom picker might have been true, we have to have some
    // custom color swatches as well to be able to use them.
    bool useCustomPicker =
        widget.pickersEnabled[ColorPickerType.custom] ?? false;
    if (widget.customColorSwatchesAndNames == null) useCustomPicker = false;

    // Color picker type to boolean for each enabled case.
    // This local map of the widget provided version always contains defaults
    // or 'false' if no value was provided in via the widget constructor.
    // This makes it possible and convenient in the constructor to only
    // provide values for any values that we want to deviate from the default
    // and keep the other values at default, a simple version of a
    // 'CopyWith' method.
    _pickers = <ColorPickerType, bool>{
      ColorPickerType.both:
          widget.pickersEnabled[ColorPickerType.both] ?? false,
      ColorPickerType.primary:
          widget.pickersEnabled[ColorPickerType.primary] ?? true,
      ColorPickerType.accent:
          widget.pickersEnabled[ColorPickerType.accent] ?? true,
      ColorPickerType.bw: widget.pickersEnabled[ColorPickerType.bw] ?? false,
      ColorPickerType.custom: useCustomPicker,
      ColorPickerType.wheel:
          widget.pickersEnabled[ColorPickerType.wheel] ?? false,
    };

    // We use the picker selector segment control only if more than one picker
    // is enabled in the color picker. If anybody ever reads this comment
    // I admit, this kind of logic is a bit tricky. Imo looping over the items
    // and counting the ones that are true and returning true if count is > 1,
    // is imo more understandable, but this was interesting to try.
    // Trust me it does the same thing! :)
    _usePickerSelector =
        _pickers.values.fold<int>(0, (int t, bool e) => t + (e ? 1 : 0)) > 1;

    // If we have a picker selector, we will build with selected picker and
    // select the segment as active where we found the given active color.
    if (_usePickerSelector) {
      if (findPicker) {
        _activePicker = findColorInSelector(
          // TODO: Redesign when alpha support is implemented.
          // Disregard any opacity/alpha on current color value to find it
          // in a color picker.
          color: _selectedColor.withAlpha(0xFF),
          typeToSwatchMap: _typeToSwatchMap,
          pickersEnabled: _pickers,
          lookInShades: widget.enableShadesSelection,
          include850: widget.includeIndex850,
        );
      }
      // If in a rebuild and the swatch was removed, we use the first one
      // that is still left in the segment control.
      if (!_pickers.containsKey(_activePicker)) {
        _activePicker = _pickers.keys.toList()[0];
      }
    }
    // If we don't have segment control selector, we use the only swatch
    // selection that is still true without showing a segment control.
    else {
      if (_pickers[ColorPickerType.both]!) {
        _activePicker = ColorPickerType.both;
      } else if (_pickers[ColorPickerType.primary]!) {
        _activePicker = ColorPickerType.primary;
      } else if (_pickers[ColorPickerType.accent]!) {
        _activePicker = ColorPickerType.accent;
      } else if (_pickers[ColorPickerType.bw]!) {
        _activePicker = ColorPickerType.bw;
      } else if (_pickers[ColorPickerType.custom]!) {
        _activePicker = ColorPickerType.custom;
      } else if (_pickers[ColorPickerType.wheel]!) {
        _activePicker = ColorPickerType.wheel;
      }
      // If they were all false we show the Material primary swatches picker.
      else {
        _activePicker = ColorPickerType.primary;
      }
    }
    // We need to set focus on the wheel, because it is the selected picker
    // and the shades are not shown that would take the focus otherwise in
    // order for it to not be on the Edit input field. If it is focused by
    // default the virtual keyboard will appear when it displayed. We do not
    // want that to happen until the user clicks on the edit field
    // intentionally.
    if (_activePicker == ColorPickerType.wheel &&
        !widget.enableShadesSelection) {
      _wheelShouldFocus = true;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _pickerFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ColorPicker oldWidget) {
    // Initialize the values again because the underlying widget changed.
    // If the available color picker selection was changed we need to find
    // the picker again and set the findPicker option to true.
    _initSelectedValue(
        findPicker: widget.pickersEnabled != oldWidget.pickersEnabled);

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // Set default text style for the segmented slider control.
    final TextStyle segmentTextStyle = widget.pickerTypeTextStyle ??
        Theme.of(context).textTheme.caption ??
        const TextStyle(fontSize: 12);

    final Color _thumbColor = widget.selectedPickerTypeColor ??
        const CupertinoDynamicColor.withBrightness(
          color: Color(0xFFFFFFFF),
          darkColor: Color(0xFF636366),
        );

    final Color? _thumbOnColor = widget.selectedPickerTypeColor == null
        ? null
        : ThemeData.estimateBrightnessForColor(_thumbColor) == Brightness.light
            ? Colors.black
            : Colors.white;

    // Widget map for the sliding Cupertino segmented control that allows us to
    // switch between the pickers we enabled.
    // We set the labels to default values if none given. The constructor also
    // holds defaults, but that does not prevent them for being overridden
    // with explicit null values, in this case we do not want that, so we still
    // check for nulls here as well and use default labels if null is given.
    final Map<ColorPickerType, Widget> pickerTypes = <ColorPickerType, Widget>{
      if (_pickers[ColorPickerType.both]!)
        ColorPickerType.both: Padding(
          padding: const EdgeInsets.all(5),
          child: Text(
            widget.pickerTypeLabels[ColorPickerType.both] ??
                ColorPicker._selectBothLabel,
            textAlign: TextAlign.center,
            style: _activePicker == ColorPickerType.both
                ? segmentTextStyle.copyWith(color: _thumbOnColor)
                : segmentTextStyle,
          ),
        ),
      if (_pickers[ColorPickerType.primary]!)
        ColorPickerType.primary: Padding(
          padding: const EdgeInsets.all(5),
          child: Text(
            widget.pickerTypeLabels[ColorPickerType.primary] ??
                ColorPicker._selectPrimaryLabel,
            textAlign: TextAlign.center,
            style: _activePicker == ColorPickerType.primary
                ? segmentTextStyle.copyWith(color: _thumbOnColor)
                : segmentTextStyle,
          ),
        ),
      if (_pickers[ColorPickerType.accent]!)
        ColorPickerType.accent: Padding(
          padding: const EdgeInsets.all(5),
          child: Text(
            widget.pickerTypeLabels[ColorPickerType.accent] ??
                ColorPicker._selectAccentLabel,
            textAlign: TextAlign.center,
            style: _activePicker == ColorPickerType.accent
                ? segmentTextStyle.copyWith(color: _thumbOnColor)
                : segmentTextStyle,
          ),
        ),
      if (_pickers[ColorPickerType.bw]!)
        ColorPickerType.bw: Padding(
          padding: const EdgeInsets.all(5),
          child: Text(
            widget.pickerTypeLabels[ColorPickerType.bw] ??
                ColorPicker._selectBlackWhiteLabel,
            textAlign: TextAlign.center,
            style: _activePicker == ColorPickerType.bw
                ? segmentTextStyle.copyWith(color: _thumbOnColor)
                : segmentTextStyle,
          ),
        ),
      if (_pickers[ColorPickerType.custom]!)
        ColorPickerType.custom: Padding(
          padding: const EdgeInsets.all(5),
          child: Text(
            widget.pickerTypeLabels[ColorPickerType.custom] ??
                ColorPicker._selectCustomLabel,
            textAlign: TextAlign.center,
            style: _activePicker == ColorPickerType.custom
                ? segmentTextStyle.copyWith(color: _thumbOnColor)
                : segmentTextStyle,
          ),
        ),
      if (_pickers[ColorPickerType.wheel]!)
        ColorPickerType.wheel: Padding(
          padding: const EdgeInsets.all(5),
          child: Text(
            widget.pickerTypeLabels[ColorPickerType.wheel] ??
                ColorPicker._selectWheelAnyLabel,
            textAlign: TextAlign.center,
            style: _activePicker == ColorPickerType.wheel
                ? segmentTextStyle.copyWith(color: _thumbOnColor)
                : segmentTextStyle,
          ),
        ),
    };

    // The normal case is that we have a swatch that we need to find
    if (_activePicker != ColorPickerType.wheel) {
      // Pick the active color swatch list from the map based on used swatch
      _activeColorSwatchList = _typeToSwatchMap[_activePicker]!;
      // Set which color swatch is the active one of the ones in the active list
      _activeSwatch = findColorSwatch(
        // TODO: Redesign this when alpha support is implemented.
        _selectedColor.withAlpha(0xFF),
        _activeColorSwatchList,
        widget.includeIndex850,
      ) as ColorSwatch<Object>?;

      // For the 'wheel' color, we need to check if the selected
      // color is part of a swatch and if it is, return that as the active
      // swatch, and only if we do not find one, is a computed swatch created.
    } else {
      if (ColorTools.isAccentColor(_selectedColor.withAlpha(0xFF))) {
        _activeSwatch = ColorTools.accentSwatch(_selectedColor.withAlpha(0xFF));
      } else if (ColorTools.isPrimaryColor(_selectedColor.withAlpha(0xFF))) {
        _activeSwatch =
            ColorTools.primarySwatch(_selectedColor.withAlpha(0xFF));
      } else if (ColorTools.isBlackAndWhiteColor(
          _selectedColor.withAlpha(0xFF))) {
        _activeSwatch =
            ColorTools.blackAndWhiteSwatch(_selectedColor.withAlpha(0xFF));
      } else {
        _activeSwatch = ColorTools.customSwatch(
            _selectedColor.withAlpha(0xFF), widget.customColorSwatchesAndNames);
      }
    }
    // Did not find the selected color in the active swatch list,
    // set active swatch to the first swatch in active list, just
    // to get a selection, this is a fall back from an error situation
    // where a selected color was passed to the color picker that was
    // not found in any of the provided swatches in active pickers. Note that
    // if the wheel picker is enabled, the color will always be found
    // in it as a last resort.
    _activeSwatch ??= _activeColorSwatchList[0];

    // The resulting used text themes, if null was passed in we assign defaults.
    final TextStyle effectiveMaterialNameStyle =
        (widget.materialNameTextStyle ??
            Theme.of(context).textTheme.bodyText2)!;
    final TextStyle effectiveGenericNameStyle =
        (widget.colorNameTextStyle ?? Theme.of(context).textTheme.bodyText2)!;

    // Set the default integer code value text style to bodyText2 if not given.
    final TextStyle effectiveCodeStyle =
        (widget.colorCodeTextStyle ?? Theme.of(context).textTheme.bodyText2)!;

    // Always set to false before a build;
    _wheelDragCancel = false;

    // Used to determine if we should have a context menu at all.
    final TargetPlatform _platform = Theme.of(context).platform;
    final bool _useLongPress = widget.copyPasteBehavior.longPressMenu ||
        (widget.copyPasteBehavior.secondaryOnDesktopLongOnDevice &&
            !isDesktop(_platform));
    final bool _useSecondaryClick = widget.copyPasteBehavior.secondaryMenu ||
        (widget.copyPasteBehavior.secondaryOnDesktopLongOnDevice &&
            isDesktop(_platform));
    final bool _useContextMenu = _useLongPress || _useSecondaryClick;

    // Build and return the layout
    //
    // We start with a RawKeyboardListener that is used to handle keyboard
    // copy and paste events.
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _handleKeyEvent,
      autofocus: true,

      // If the copy paste long press menu feature is enabled we wrap the
      // entire color picker with a Copy Paste long press menu
      child: IfWrapper(
        condition: _useContextMenu, // && !editCodeFocused,
        builder: (BuildContext context, Widget child) {
          return ContextCopyPasteMenu(
            useLongPress: widget.copyPasteBehavior.longPressMenu,
            useSecondaryTapDown: widget.copyPasteBehavior.secondaryMenu,
            useSecondaryOnDesktopLongOnDevice:
                widget.copyPasteBehavior.secondaryOnDesktopLongOnDevice,
            onSelected: (CopyPasteCommands? value) {
              setState(() {
                _wheelDragCancel = false;
              });
              if (value == CopyPasteCommands.copy) _setClipboard();
              if (value == CopyPasteCommands.paste) _getClipboard();
            },
            onOpen: () {
              if (widget.onColorChangeEnd != null && _wheelDragCancel) {
                widget.onColorChangeEnd!(_selectedColor);
                _addToRecentColors(_selectedColor);
              }
              setState(() {
                _wheelDragCancel = false;
              });
            },
            child: child,
          );
        },
        // The gesture detector is used to set focus to the keyboard listener.
        // And to make sure handle the drag cancel event ONLY when we need to
        // when the cancel happened due to opening the long press popup menu.
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          // This is a terrible "hack", but it allows scrolling vertically from
          // the surfaces in the ColorPicker and it picks up the cancel event
          // due to long press menu and allows us to trigger the onEnd callback.
          // If onVerticalDragCancel is used here it prevents v-scrolling from
          // the color picker widget and sub-widgets. We only want the the
          // wheel to do that in order for it to pickup down, drags and pans.
          // It does prevent h-scrolling now, but probably a much smaller issue
          // if at all an issue.
          onHorizontalDragCancel: () {
            setState(() {
              _wheelDragCancel = true;
            });
          },
          child: Padding(
            padding: widget.padding,
            // The layout is a column, it is up to the parent to ensure
            // that it it fits or uses a scrolling parent if it does not.
            child: Column(
              crossAxisAlignment: widget.crossAxisAlignment,
              children: <Widget>[
                // Show title bar widget if we have one.
                if (widget.title != null ||
                    widget.copyPasteBehavior.copyButton ||
                    widget.copyPasteBehavior.pasteButton ||
                    widget.actionButtons.okButton ||
                    widget.actionButtons.closeButton)
                  Padding(
                    padding: EdgeInsets.only(bottom: widget.columnSpacing),
                    child: ColorPickerToolbar(
                      title: widget.title,
                      onCopy: widget.copyPasteBehavior.copyButton
                          ? _setClipboard
                          : null,
                      onPaste: widget.copyPasteBehavior.pasteButton
                          ? _getClipboard
                          : null,
                      onOk: widget.actionButtons.okButton
                          ? () {
                              // OK was pressed, we pop and return TRUE
                              // In case this was not used in a dialog the
                              // canPop will at least avoid a crash, but may
                              // still do the wrong thing.
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop(true);
                              }
                            }
                          : null,
                      onClose: widget.actionButtons.closeButton
                          ? () {
                              // Cancel was pressed, we pop and return FALSE
                              // In case this was not used in a dialog the
                              // canPop will at least avoid a crash, but may
                              // still do the wrong thing.
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop(false);
                              }
                            }
                          : null,
                      toolIcons: widget.actionButtons,
                      copyPasteBehavior: widget.copyPasteBehavior,
                      enableTooltips: widget.enableTooltips,
                    ),
                  ),
                // Show heading widget if we have one.
                if (widget.heading != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: widget.columnSpacing),
                    child: widget.heading,
                  ),
                // Show picker selector, if more than one picker is enabled.
                if (_usePickerSelector)
                  Focus(
                    focusNode: _pickerFocusNode,
                    onKey: (FocusNode node, RawKeyEvent event) {
                      _handleKeyEvent(event);
                      return KeyEventResult.ignored;
                    },
                    child: PickerSelector(
                      pickerTypes: pickerTypes,
                      onValueChanged: (ColorPickerType value) {
                        _pickerFocusNode.requestFocus();
                        setState(() {
                          _activePicker = value;
                          _selectedShouldFocus = true;
                          if (_activePicker == ColorPickerType.wheel &&
                              !widget.enableShadesSelection) {
                            _wheelShouldFocus = true;
                          }
                        });
                      },
                      value: _activePicker,
                      thumbColor: widget.selectedPickerTypeColor,
                      columnSpacing: widget.columnSpacing,
                    ),
                  ),
                // Add a tiny bit of extra hard coded space after the picker
                // type selector if there was one.
                if (_usePickerSelector) const SizedBox(height: 4),
                // This is not the Wheel case, so we draw all the main colors
                // for the active swatch list.
                if (_activePicker != ColorPickerType.wheel)
                  MainColors(
                    spacing: widget.spacing,
                    runSpacing: widget.runSpacing,
                    columnSpacing: widget.columnSpacing,
                    activeColorSwatchList: _activeColorSwatchList,
                    // TODO Redesign when enable alpha
                    selectedColor: _selectedColor.withAlpha(0xFF),
                    onSelectColor: _onSelectColor,
                    includeIndex850: widget.includeIndex850,
                    width: widget.width,
                    height: widget.height,
                    borderRadius: widget.borderRadius,
                    hasBorder: widget.hasBorder,
                    borderColor: widget.borderColor,
                    elevation: widget.elevation,
                    selectedColorIcon: widget.selectedColorIcon,
                    selectedRequestsFocus: _selectedShouldFocus,
                  ),
                // This is the wheel case, draw the custom painter color wheel.
                if (_activePicker == ColorPickerType.wheel)
                  Padding(
                    padding: EdgeInsets.only(bottom: widget.columnSpacing),
                    child: SizedBox(
                      height: widget.wheelDiameter,
                      width: widget.wheelDiameter,
                      child: ColorWheelPicker(
                        // TODO Redesign when enable alpha
                        color: _selectedColor.withAlpha(0xFF),
                        wheelWidth: widget.wheelWidth,
                        hasBorder: widget.wheelHasBorder,
                        shouldUpdate: _wheelShouldUpdate,
                        shouldRequestsFocus: _wheelShouldFocus,
                        onChangeStart: (Color color) {
                          if (widget.onColorChangeStart != null) {
                            widget.onColorChangeStart!(color);
                          }
                          _addToRecentColors(color);
                        },
                        onChanged: (Color color) {
                          setState(() {
                            _selectedColor = color;
                            _wheelShouldUpdate = false;
                            _editShouldUpdate = true;
                            _selectedShouldFocus = true;
                            _wheelShouldFocus = false;
                          });
                          widget.onColorChanged(_selectedColor);
                        },
                        onChangeEnd: (Color color) {
                          if (widget.onColorChangeEnd != null) {
                            widget.onColorChangeEnd!(color);
                          }
                        },
                      ),
                    ),
                  ),
                // Show the sub-heading for the none wheel case.
                if (widget.subheading != null &&
                    widget.enableShadesSelection &&
                    _activePicker != ColorPickerType.wheel)
                  Padding(
                    padding: EdgeInsets.only(bottom: widget.columnSpacing),
                    child: widget.subheading,
                  ),
                // Show the sub-heading for the wheel case.
                if (widget.wheelSubheading != null &&
                    widget.enableShadesSelection &&
                    _activePicker == ColorPickerType.wheel)
                  Padding(
                    padding: EdgeInsets.only(bottom: widget.columnSpacing),
                    child: widget.wheelSubheading,
                  ),
                // Draw the shade colors for the selected main color.
                if (widget.enableShadesSelection)
                  ShadeColors(
                    spacing: widget.spacing,
                    runSpacing: widget.runSpacing,
                    columnSpacing: widget.columnSpacing,
                    activeSwatch: _activeSwatch!,
                    selectedColor: _selectedColor.withAlpha(0xFF),
                    onSelectColor: (Color color) {
                      _onSelectColor(color);
                      if (_activePicker == ColorPickerType.wheel) {
                        setState(() {
                          _selectedShouldFocus = true;
                        });
                      }
                    },
                    includeIndex850: widget.includeIndex850,
                    width: widget.width,
                    height: widget.height,
                    borderRadius: widget.borderRadius,
                    hasBorder: widget.hasBorder,
                    borderColor: widget.borderColor,
                    elevation: widget.elevation,
                    selectedColorIcon: widget.selectedColorIcon,
                    selectedRequestsFocus: _selectedShouldFocus,
                  ),
                // If we show material or generic name, we enclose them in a
                // Wrap, they will be on same row nicely if there is room
                // enough, but also wrap to two rows when so needed when both
                // are shown at the same and they don't fit on one row.
                if (widget.showMaterialName || widget.showColorName)
                  Wrap(
                    children: <Widget>[
                      // Show the Material color name, if enabled.
                      if (widget.showMaterialName)
                        Padding(
                          padding:
                              EdgeInsets.only(bottom: widget.columnSpacing),
                          child: Text(
                            ColorTools.materialName(
                              _selectedColor.withAlpha(0xFF),
                              colorSwatchNameMap:
                                  widget.customColorSwatchesAndNames,
                            ),
                            style: effectiveMaterialNameStyle,
                          ),
                        ),
                      // If we show both material and generic name, add some
                      // hard coded horizontal space between them.
                      if (widget.showMaterialName && widget.showColorName)
                        const SizedBox(width: 8),
                      // Show the generic color name, if enabled.
                      if (widget.showColorName)
                        Padding(
                          padding:
                              EdgeInsets.only(bottom: widget.columnSpacing),
                          child: Text(
                            ColorTools.nameThatColor(_selectedColor),
                            style: effectiveGenericNameStyle,
                          ),
                        ),
                    ],
                  ),
                // If we show color code or its int value, we enclose them in a
                // Wrap, they will be on same row nicely if there is room enough
                // but also wrap to two rows when so needed when both are
                // shown at the same and they don't fit on one row.
                if (widget.showColorCode || widget.showColorValue)
                  Padding(
                    padding: EdgeInsets.only(bottom: widget.columnSpacing),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runAlignment: WrapAlignment.center,
                      alignment: WrapAlignment.center,
                      children: <Widget>[
                        // Show the copy and edit color code field, if enabled.
                        if (widget.showColorCode)
                          ColorCodeField(
                            color: _selectedColor,
                            readOnly: _activePicker != ColorPickerType.wheel ||
                                widget.colorCodeReadOnly,
                            textStyle: widget.colorCodeTextStyle,
                            prefixStyle: widget.colorCodePrefixStyle,
                            colorCodeHasColor: widget.colorCodeHasColor,
                            enableTooltips: widget.enableTooltips,
                            shouldUpdate: _editShouldUpdate,
                            onColorChanged: (Color color) {
                              if (widget.onColorChangeStart != null) {
                                widget.onColorChangeStart!(_selectedColor);
                              }
                              setState(() {
                                _selectedColor = color;
                                // Color changed outside wheel picker, the
                                // code was edited, it should update!
                                _wheelShouldUpdate = true;
                                _editShouldUpdate = false;
                              });
                              widget.onColorChanged(_selectedColor);
                              if (widget.onColorChangeEnd != null) {
                                widget.onColorChangeEnd!(_selectedColor);
                              }
                              _addToRecentColors(color);
                            },
                            onEditFocused: (bool editInFocus) {
                              setState(() {
                                _editCodeFocused = editInFocus;
                                if (_editCodeFocused) {
                                  _selectedShouldFocus = false;
                                  _wheelShouldFocus = false;
                                }
                              });
                            },
                            toolIcons: widget.actionButtons,
                            copyPasteBehavior: widget.copyPasteBehavior,
                          ),
                        // If we show both hex code and int value, add some
                        // hardcoded horizontal space between them.
                        if (widget.showColorCode && widget.showColorValue)
                          const SizedBox(width: 8),
                        if (widget.showColorValue)
                          SelectableText(
                            _selectedColor.value.toString(),
                            style: effectiveCodeStyle,
                          ),
                      ],
                    ),
                  ),
                // Show the sub-heading recent colors.
                if (widget.recentColorsSubheading != null &&
                    widget.showRecentColors)
                  Padding(
                    padding: EdgeInsets.only(bottom: widget.columnSpacing),
                    child: widget.recentColorsSubheading,
                  ),
                if (widget.showRecentColors)
                  RecentColors(
                    spacing: widget.spacing,
                    runSpacing: widget.runSpacing,
                    columnSpacing: widget.columnSpacing,
                    recentColors: _recentColors,
                    selectedColor: _selectedColor,
                    onSelectColor: (Color color) {
                      _onSelectColor(color);
                      // Move the picker to the selected color value.
                      _initSelectedValue(findPicker: true);
                    },
                    includeIndex850: widget.includeIndex850,
                    width: widget.width,
                    height: widget.height,
                    borderRadius: widget.borderRadius,
                    hasBorder: widget.hasBorder,
                    borderColor: widget.borderColor,
                    elevation: widget.elevation,
                    selectedColorIcon: widget.selectedColorIcon,
                    selectedRequestsFocus: _selectedShouldFocus,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // A color was selected, update state and notify parent via callbacks.
  void _onSelectColor(Color color) {
    // Have start callback, call it with current selectedColor before change.
    if (widget.onColorChangeStart != null) {
      widget.onColorChangeStart!(_selectedColor);
    }
    // Add the previously selected color to recent colors.
    _addToRecentColors(_selectedColor);

    // update the state of the selectedColor to the new selected color.
    setState(() {
      // Set selected color to the new value.
      _selectedColor = color;
      // When the a color was clicked and selected, the right item is already
      // focused an other selected color indicators and wheel should not focus.
      _selectedShouldFocus = false;
      _wheelShouldFocus = false;
      // Color changed outside wheel and edit, a new shade or color was
      // selected outside the wheel and edit field, they should update!
      _wheelShouldUpdate = true;
      _editShouldUpdate = true;
    });

    // Call the change call back with the new color.
    widget.onColorChanged(_selectedColor);
    // We have and end callback, call it with the new color.
    if (widget.onColorChangeEnd != null) {
      widget.onColorChangeEnd!(_selectedColor);
    }
  }

  void _addToRecentColors(Color color) {
    // We are not showing recent colors, do nothing.
    if (!widget.showRecentColors) return;

    // If recent colors already contains the color, do nothing.
    if (_recentColors.contains(color)) return;

    // Clamp the max recent colors to the allowed range.
    final int clampedRecentColors =
        widget.maxRecentColors.clamp(_minRecentColors, _maxRecentColors);

    // Max recent colors reached, remove first one added.
    if (_recentColors.length >= clampedRecentColors) {
      _recentColors.removeRange(clampedRecentColors - 1, _recentColors.length);
    }
    setState(() {
      _recentColors = <Color>[color, ..._recentColors];
    });

    // Call callback for the handling recent colors, if there is one.
    if (widget.onRecentColorsChanged != null) {
      widget.onRecentColorsChanged!(_recentColors);
    }
  }

  // Handle the keyboard events from the RawKeyboardListener.
  void _handleKeyEvent(RawKeyEvent event) {
    // If edit color code is focused and we do not use parsed paste, we
    // exit out of here. The TextField's normal paste action will then handle
    // the paste as before.
    if (_editCodeFocused && !widget.copyPasteBehavior.editUsesParsedPaste) {
      return;
    }
    // Make Desktop OS independent copy/paste modifier key.
    final bool isMacOS = event.data is RawKeyEventDataMacOs;
    final bool isCtrlPressed =
        isMacOS ? event.isMetaPressed : event.isControlPressed;
    // The raw keyboard listener reacts to both up and down events, we only
    // use down so we execute the copy and paste command only once
    // when the key are presses down, we do not want to do it 2nd time when
    // the key goes up.
    if (event.runtimeType == RawKeyDownEvent) {
      // If logical key is paste OR CTRL+V and we use ctrlV paste behavior, then
      // we get the clipboard data.
      if ((event.logicalKey == LogicalKeyboardKey.paste ||
              (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.keyV)) &&
          widget.copyPasteBehavior.ctrlV) {
        _getClipboard();
      }
      // If logical key is copy or CTRL+C and we used ctrlC copy behavior, then
      // we set the current color to the clipboard data.
      if ((event.logicalKey == LogicalKeyboardKey.copy ||
              (isCtrlPressed && event.logicalKey == LogicalKeyboardKey.keyC)) &&
          widget.copyPasteBehavior.ctrlC) {
        _setClipboard();
      }
    }
  }

  // Get the current clipboard data. Try to parse it to a color value.
  // If successful, set the current color to the color value.
  Future<void> _getClipboard() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    // Clipboard data was null, exit.
    if (data == null) return;
    final Color? clipColor = data.text
        .toColorShortMaybeNull(widget.copyPasteBehavior.parseShortHexCode);
    if (clipColor != null) {
      if (widget.onColorChangeStart != null) {
        widget.onColorChangeStart!(_selectedColor);
      }
      // Add the previous selected color to recent colors
      _addToRecentColors(_selectedColor);
      // This wait for 100ms feels a bit like a hack, but if not done, the
      // paste when using paste parser in the color code edit field does not
      // work correctly. This delay allows the edit field to first process
      // it variant of the paste, that we will disregard when the paste parser
      // is active for the edit field, and it will be caught here also
      // and we get the complete value as evaluated by the parser instead.
      // The extra wait here has no impact on other pasting when the edit
      // field is not active.
      await Future<void>.delayed(const Duration(milliseconds: 100));
      setState(() {
        _selectedColor = clipColor;
        // Color changed outside wheel and edit field, a new shade or color was
        // selected outside the wheel and edit, they should update!
        _wheelShouldUpdate = true;
        _editShouldUpdate = true;
      });
      // Callback with new color
      widget.onColorChanged(_selectedColor);
      if (widget.onColorChangeEnd != null) {
        widget.onColorChangeEnd!(_selectedColor);
      }
      // Move the picker to the pasted color value.
      _initSelectedValue(findPicker: true);
    } else {
      // TODO: Improve feedback/sound when it can be done with SDK features.
      // This is a nice idea, but it does not do much on most platforms.
      // Would just like to get a nice "error bleep" sound on all platforms
      // without any plugin by using SDK only, but not doable, bummer.
      // Keeping it around as an experimental feature.
      // If we do all, vibrate, click and alert, there just might some kind
      // of feedback on most platforms.
      // Maybe one day Material sound design will be supported out of the box,
      // then we can make this nicer.
      if (widget.copyPasteBehavior.feedbackParseError) {
        await HapticFeedback.vibrate();
        await SystemSound.play(SystemSoundType.click);
        await SystemSound.play(SystemSoundType.alert);
      }
      // Show a snack bar paste format error message.
      if (widget.copyPasteBehavior.snackBarParseError) {
        // Get the Material localizations.
        final MaterialLocalizations translate =
            MaterialLocalizations.of(context);
        final String message = '${translate.pasteButtonLabel}: '
            '${translate.invalidDateFormatLabel}';
        // Wait 400ms, if we show it at once, it feel to fast.
        await Future<void>.delayed(const Duration(milliseconds: 400));
        // Show a snack bar with the paste error message.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: widget.copyPasteBehavior.snackBarMessage ?? Text(message),
            duration: widget.copyPasteBehavior.snackBarDuration,
          ),
        );
      }
    }
  }

  // Set current selected color value as a String on the Clipboard in
  // currently configured format.
  Future<void> _setClipboard() async {
    String colorString = '00000000';
    switch (widget.copyPasteBehavior.copyFormat) {
      case ColorPickerCopyFormat.dartCode:
        colorString = '0x${_selectedColor.hexAlpha}';
        break;
      case ColorPickerCopyFormat.hexRRGGBB:
        colorString = _selectedColor.hex;
        break;
      case ColorPickerCopyFormat.hexAARRGGBB:
        colorString = _selectedColor.hexAlpha;
        break;
      case ColorPickerCopyFormat.numHexRRGGBB:
        colorString = '#${_selectedColor.hex}';
        break;
      case ColorPickerCopyFormat.numHexAARRGGBB:
        colorString = '#${_selectedColor.hexAlpha}';
        break;
    }
    final ClipboardData data = ClipboardData(text: colorString);
    await Clipboard.setData(data);
  }
}
