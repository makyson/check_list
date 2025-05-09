import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../../flutter_flow/form_field_controller.dart';

class FlutterFlowDropDown<T> extends FormField<T> {
  FlutterFlowDropDown({
    super.key,
    FormFieldController<T?>? controller,
    FormFieldController<List<T>?>? multiSelectController,
    String? hintText,
    String? searchHintText,
    required List<T> options,
    List<String>? optionLabels,
    Function(T?)? onChanged,
    Function(List<T>?)? onMultiSelectChanged,
    Widget? icon,
    double? width,
    double? height,
    double? maxHeight,
    Color? fillColor,
    TextStyle? searchHintTextStyle,
    TextStyle? searchTextStyle,
    Color? searchCursorColor,
    required TextStyle textStyle,
    required double elevation,
    required double borderWidth,
    required double borderRadius,
    required Color borderColor,
    required EdgeInsetsGeometry margin,
    bool hidesUnderline = false,
    bool disabled = false,
    bool isOverButton = false,
    Offset? menuOffset,
    bool isSearchable = false,
    bool isMultiSelect = false,
    String? labelText,
    TextStyle? labelTextStyle,
    super.validator,
  }) : super(
          initialValue: isMultiSelect
              ? multiSelectController?.value
                  ?.firstOrNull // Inicializa com o primeiro valor ou null
              : controller?.value,
          builder: (FormFieldState<T> state) {
            if (state.hasError) {
              Vibration.vibrate(duration: 200); // Adiciona vibração
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FlutterFlowDropDownWidget<T>(
                  controller: controller,
                  multiSelectController: multiSelectController,
                  hintText: hintText,
                  searchHintText: searchHintText,
                  options: options,
                  optionLabels: optionLabels,
                  onChanged: (val) {
                    state.didChange(val);
                    if (onChanged != null) {
                      onChanged(val);
                    }
                  },
                  onMultiSelectChanged: onMultiSelectChanged,
                  icon: icon,
                  width: width,
                  height: height,
                  maxHeight: maxHeight,
                  fillColor: fillColor,
                  searchHintTextStyle: searchHintTextStyle,
                  searchTextStyle: searchTextStyle,
                  searchCursorColor: searchCursorColor,
                  textStyle: state.hasError
                      ? textStyle.copyWith(color: Colors.red)
                      : textStyle,
                  elevation: elevation,
                  borderWidth: borderWidth,
                  borderRadius: borderRadius,
                  borderColor: state.hasError
                      ? Colors.red
                      : borderColor, // Borda vermelha em caso de erro
                  margin: margin,
                  hidesUnderline: hidesUnderline,
                  disabled: disabled,
                  isOverButton: isOverButton,
                  menuOffset: menuOffset,
                  isSearchable: isSearchable,
                  isMultiSelect: isMultiSelect,
                  labelText: labelText,
                  labelTextStyle: labelTextStyle,
                  state: state,
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      state.errorText ?? '',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
}

class _FlutterFlowDropDownWidget<T> extends StatelessWidget {
  final FormFieldController<T?>? controller;
  final FormFieldController<List<T>?>? multiSelectController;
  final String? hintText;
  final String? searchHintText;
  final List<T> options;
  final List<String>? optionLabels;
  final Function(T?)? onChanged;
  final Function(List<T>?)? onMultiSelectChanged;
  final Widget? icon;
  final double? width;
  final double? height;
  final double? maxHeight;
  final Color? fillColor;
  final TextStyle? searchHintTextStyle;
  final TextStyle? searchTextStyle;
  final Color? searchCursorColor;
  final TextStyle textStyle;
  final double elevation;
  final double borderWidth;
  final double borderRadius;
  final Color borderColor;
  final EdgeInsetsGeometry margin;
  final bool hidesUnderline;
  final bool disabled;
  final bool isOverButton;
  final Offset? menuOffset;
  final bool isSearchable;
  final bool isMultiSelect;
  final String? labelText;
  final TextStyle? labelTextStyle;
  final FormFieldState<T> state;

  const _FlutterFlowDropDownWidget({
    this.controller,
    this.multiSelectController,
    this.hintText,
    this.searchHintText,
    required this.options,
    this.optionLabels,
    this.onChanged,
    this.onMultiSelectChanged,
    this.icon,
    this.width,
    this.height,
    this.maxHeight,
    this.fillColor,
    this.searchHintTextStyle,
    this.searchTextStyle,
    this.searchCursorColor,
    required this.textStyle,
    required this.elevation,
    required this.borderWidth,
    required this.borderRadius,
    required this.borderColor,
    required this.margin,
    this.hidesUnderline = false,
    this.disabled = false,
    this.isOverButton = false,
    this.menuOffset,
    this.isSearchable = false,
    this.isMultiSelect = false,
    this.labelText,
    this.labelTextStyle,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
          color: fillColor,
        ),
        child: Padding(
          padding: _useDropdown2() ? EdgeInsets.zero : margin,
          child: hidesUnderline
              ? DropdownButtonHideUnderline(child: _buildDropdown())
              : _buildDropdown(),
        ),
      ),
    );
  }

  bool _useDropdown2() =>
      isMultiSelect || isSearchable || !isOverButton || maxHeight != null;

  Widget _buildDropdown() {
    final overlayColor = MaterialStateProperty.resolveWith<Color?>((states) =>
        states.contains(MaterialState.focused) ? Colors.transparent : null);
    final iconStyleData =
        icon != null ? IconStyleData(icon: icon!) : const IconStyleData();
    return DropdownButton2<T>(
      value: state.value,
      hint: hintText != null ? Text(hintText!, style: textStyle) : null,
      items: _createMenuItems(),
      iconStyleData: iconStyleData,
      buttonStyleData: ButtonStyleData(
        elevation: elevation.toInt(),
        overlayColor: overlayColor,
        padding: margin,
      ),
      menuItemStyleData: MenuItemStyleData(
        overlayColor: overlayColor,
        padding: EdgeInsets.zero,
      ),
      dropdownStyleData: DropdownStyleData(
        elevation: elevation.toInt(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: fillColor,
        ),
        isOverButton: isOverButton,
        offset: menuOffset ?? Offset.zero,
        maxHeight: maxHeight,
        padding: EdgeInsets.zero,
      ),
      onChanged: disabled
          ? null
          : (val) {
              state.didChange(val);
              if (onChanged != null) {
                onChanged!(val);
              }
            },
      isExpanded: true,
      selectedItemBuilder: (context) => options
          .map(
            (item) => Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                optionLabels?[options.indexOf(item)] ?? item.toString(),
                style: textStyle,
                maxLines: 1,
              ),
            ),
          )
          .toList(),
      dropdownSearchData: isSearchable
          ? DropdownSearchData<T>(
              searchController: TextEditingController(),
              searchInnerWidgetHeight: 50,
              searchInnerWidget: Container(
                height: 50,
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 4,
                  right: 8,
                  left: 8,
                ),
                child: TextFormField(
                  expands: true,
                  maxLines: null,
                  cursorColor: searchCursorColor,
                  style: searchTextStyle,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    hintText: searchHintText,
                    hintStyle: searchHintTextStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              searchMatchFn: (item, searchValue) {
                return (optionLabels?[options.indexOf(item as T)] ?? '')
                    .toLowerCase()
                    .contains(searchValue.toLowerCase());
              },
            )
          : null,
      onMenuStateChange: (isOpen) {
        if (!isOpen && isSearchable) {
          TextEditingController().clear();
        }
      },
    );
  }

  List<DropdownMenuItem<T>> _createMenuItems() => options
      .map(
        (option) => DropdownMenuItem<T>(
          value: option,
          child: Padding(
            padding: _useDropdown2() ? margin : EdgeInsets.zero,
            child: Text(
                optionLabels?[options.indexOf(option)] ?? option.toString(),
                style: textStyle),
          ),
        ),
      )
      .toList();
}

class CustomDropdownFormField extends FormField<Map<String, dynamic>> {
  CustomDropdownFormField({
    Key? key,
    required List<Map<String, dynamic>> items,
    required String titleKey,
    required String subtitleKey,
    ValueNotifier<String?>?
        initialTitleNotifier, // Título inicial monitorado por ValueNotifier
    ValueChanged<Map<String, dynamic>?>? onChanged,
    VoidCallback? onAddNewItem,
    FormFieldSetter<Map<String, dynamic>>? onSaved,
    FormFieldValidator<Map<String, dynamic>>? validator,
    bool enabled = true,
    bool showAddNewItem = false,
    AutovalidateMode autovalidateMode = AutovalidateMode.disabled,
    InputDecoration decoration = const InputDecoration(),
    bool isExpanded = true,
    TextStyle? style,
    int dropdownElevation = 8,
    double iconSize = 28,
    bool? autoFocus,
    EdgeInsetsGeometry padding = const EdgeInsets.all(8.0),
    FocusNode? focusNode,
    bool readOnly = false,
    Color? dropdownColor,
    Radius? borderRadius,
    double? dropdownMaxHeight,
    double? dropdownMaxWidth,
  })  : _items = items,
        _titleKey = titleKey,
        _subtitleKey = subtitleKey,
        super(
          key: key,
          initialValue: initialTitleNotifier?.value != null
              ? items.firstWhere(
                  (item) => item[titleKey] == initialTitleNotifier!.value,
                  orElse: () => {},
                )
              : null,
          enabled: enabled,
          autovalidateMode: autovalidateMode,
          onSaved: onSaved,
          validator: validator,
          builder: (FormFieldState<Map<String, dynamic>> field) {
            final _CustomDropdownFormFieldState state =
                field as _CustomDropdownFormFieldState;
            final effectiveDecoration = decoration.applyDefaults(
              Theme.of(field.context).inputDecorationTheme,
            );

            TextEditingController searchController = TextEditingController();

            List<Map<String, dynamic>> getFilteredItems() {
              final searchValue = searchController.text.toLowerCase();
              return items.where((item) {
                final title = item[titleKey]?.toString().toLowerCase() ?? '';
                final subtitle =
                    item[subtitleKey]?.toString().toLowerCase() ?? '';
                return title.contains(searchValue) ||
                    subtitle.contains(searchValue);
              }).toList();
            }

            List<DropdownMenuItem<Map<String, dynamic>>> buildMenuItems() {
              List<DropdownMenuItem<Map<String, dynamic>>> menuItems = [];

              if (showAddNewItem) {
                menuItems.add(
                  DropdownMenuItem<Map<String, dynamic>>(
                    value: null,
                    enabled: false,
                    child: InkWell(
                      onTap: onAddNewItem,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          width: double.maxFinite,
                          child: Text(
                            "Adicionar Novo Item",
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(field.context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              menuItems.addAll(getFilteredItems().map((item) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: item,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item[titleKey]?.toString() ?? '',
                        style: TextStyle(
                          fontSize: 16.5,
                          height: 0.8,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item[subtitleKey]?.toString().toLowerCase() ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }).toList());

              return menuItems;
            }

            void onChangedHandler(Map<String, dynamic>? value) {
              if (value != null) {
                field.didChange(value);
                onChanged?.call(value);
              }
            }

            return ValueListenableBuilder<String?>(
              valueListenable: initialTitleNotifier!,
              builder: (context, initialTitle, child) {
                final newValue = items.firstWhere(
                  (item) => item[titleKey] == initialTitle,
                  orElse: () => {},
                );
                if (newValue.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    field.didChange(newValue);
                  });
                }

                return UnmanagedRestorationScope(
                  bucket: field.bucket,
                  child: DropdownButtonFormField2<Map<String, dynamic>>(
                    dropdownSearchData:
                        DropdownSearchData<Map<String, dynamic>>(
                            searchController: searchController,
                            searchInnerWidgetHeight: 50,
                            searchInnerWidget: Container(
                              height: 50,
                              padding: const EdgeInsets.only(
                                top: 8,
                                bottom: 4,
                                right: 8,
                                left: 8,
                              ),
                              child: TextFormField(
                                expands: true,
                                maxLines: null,
                                controller: searchController,
                                decoration: InputDecoration(
                                  hintText: 'Pesquisar aqui',
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onChanged: (value) {
                                  // Atualiza a lista quando o valor de pesquisa mudar
                                  field.setState(() {});
                                },
                              ),
                            )),
                    value: newValue.isNotEmpty ? newValue : state.value,
                    decoration: effectiveDecoration.copyWith(
                        errorText: field.errorText),
                    isExpanded: isExpanded,
                    items: buildMenuItems(),
                    onChanged: onChangedHandler,
                    iconStyleData: IconStyleData(
                      iconSize: iconSize,
                    ),
                    style: style,
                    focusNode: focusNode,
                    onSaved: onSaved,
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        color: dropdownColor,
                        borderRadius: BorderRadius.all(
                            borderRadius ?? Radius.circular(8.0)),
                      ),
                      elevation: dropdownElevation,
                      maxHeight: dropdownMaxHeight,
                      width: dropdownMaxWidth,
                    ),
                    autofocus: autoFocus ?? false,
                  ),
                );
              },
            );
          },
        );

  final List<Map<String, dynamic>> _items;
  final String _titleKey;
  final String _subtitleKey;

  @override
  FormFieldState<Map<String, dynamic>> createState() =>
      _CustomDropdownFormFieldState();
}

class _CustomDropdownFormFieldState
    extends FormFieldState<Map<String, dynamic>> {
  RestorableTextEditingController? _controller;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    super.restoreState(oldBucket, initialRestore);
    if (_controller != null) {
      registerForRestoration(_controller!, 'controller');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChange(Map<String, dynamic>? value) {
    super.didChange(value);
    if (_controller != null && _controller!.value.text != value.toString()) {
      _controller!.value.text = value.toString();
    }
  }

  @override
  void reset() {
    super.reset();
    didChange(null);
  }
}

/*

class FlutterFlowDropDown<T> extends StatefulWidget {
  const FlutterFlowDropDown({
    super.key,
    this.controller,
    this.multiSelectController,
    this.hintText,
    this.searchHintText,
    required this.options,
    this.optionLabels,
    this.onChanged,
    this.onMultiSelectChanged,
    this.icon,
    this.width,
    this.height,
    this.maxHeight,
    this.fillColor,
    this.searchHintTextStyle,
    this.searchTextStyle,
    this.searchCursorColor,
    required this.textStyle,
    required this.elevation,
    required this.borderWidth,
    required this.borderRadius,
    required this.borderColor,
    required this.margin,
    this.hidesUnderline = false,
    this.disabled = false,
    this.isOverButton = false,
    this.menuOffset,
    this.isSearchable = false,
    this.isMultiSelect = false,
    this.labelText,
    this.labelTextStyle,
    this.validator,
  }) : assert(
          isMultiSelect
              ? (controller == null &&
                  onChanged == null &&
                  multiSelectController != null &&
                  onMultiSelectChanged != null)
              : (controller != null &&
                  onChanged != null &&
                  multiSelectController == null &&
                  onMultiSelectChanged == null),
        );

  final FormFieldController<T?>? controller;
  final FormFieldController<List<T>?>? multiSelectController;
  final String? hintText;
  final String? searchHintText;
  final List<T> options;
  final List<String>? optionLabels;
  final Function(T?)? onChanged;
  final Function(List<T>?)? onMultiSelectChanged;
  final Widget? icon;
  final double? width;
  final double? height;
  final double? maxHeight;
  final Color? fillColor;
  final TextStyle? searchHintTextStyle;
  final TextStyle? searchTextStyle;
  final Color? searchCursorColor;
  final InputDecoration textStyle;
  final double elevation;
  final double borderWidth;
  final double borderRadius;
  final Color borderColor;
  final EdgeInsetsGeometry margin;
  final bool hidesUnderline;
  final bool disabled;
  final bool isOverButton;
  final Offset? menuOffset;
  final bool isSearchable;
  final bool isMultiSelect;
  final String? labelText;
  final TextStyle? labelTextStyle;

  final FormFieldValidator<T>? validator;

  @override
  State<FlutterFlowDropDown<T>> createState() => _FlutterFlowDropDownState<T>();
}

class _FlutterFlowDropDownState<T> extends State<FlutterFlowDropDown<T>> {
  bool get isMultiSelect => widget.isMultiSelect;
  FormFieldController<T?> get controller => widget.controller!;
  FormFieldController<List<T>?> get multiSelectController =>
      widget.multiSelectController!;

  T? get currentValue {
    final value = isMultiSelect
        ? multiSelectController.value?.firstOrNull
        : controller.value;
    return widget.options.contains(value) ? value : null;
  }

  Set<T> get currentValues {
    if (!isMultiSelect || multiSelectController.value == null) {
      return {};
    }
    return widget.options
        .toSet()
        .intersection(multiSelectController.value!.toSet());
  }

  Map<T, String> get optionLabels => Map.fromEntries(
        widget.options.asMap().entries.map(
              (option) => MapEntry(
                option.value,
                widget.optionLabels == null ||
                        widget.optionLabels!.length < option.key + 1
                    ? option.value.toString()
                    : widget.optionLabels![option.key],
              ),
            ),
      );

  EdgeInsetsGeometry get horizontalMargin => widget.margin.clamp(
        EdgeInsetsDirectional.zero,
        const EdgeInsetsDirectional.symmetric(horizontal: double.infinity),
      );

  late void Function() _listener;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (isMultiSelect) {
      _listener =
          () => widget.onMultiSelectChanged!(multiSelectController.value);
      multiSelectController.addListener(_listener);
    } else {
      _listener = () => widget.onChanged!(controller.value);
      controller.addListener(_listener);
    }
  }

  @override
  void dispose() {
    if (isMultiSelect) {
      multiSelectController.removeListener(_listener);
    } else {
      controller.removeListener(_listener);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dropdownWidget = _buildDropdownWidget();
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.borderColor,
            width: widget.borderWidth,
          ),
          color: widget.fillColor,
        ),
        child: Padding(
          padding: _useDropdown2() ? EdgeInsets.zero : widget.margin,
          child: widget.hidesUnderline
              ? DropdownButtonHideUnderline(child: dropdownWidget)
              : dropdownWidget,
        ),
      ),
    );
  }

  bool _useDropdown2() =>
      widget.isMultiSelect ||
      widget.isSearchable ||
      !widget.isOverButton ||
      widget.maxHeight != null;

  Widget _buildDropdownWidget() =>
      _useDropdown2() ? _buildDropdown() : _buildLegacyDropdown();

  Widget _buildLegacyDropdown() {
    return DropdownButtonFormField<T>(
      value: currentValue,
      hint: _createHintText(),
      items: _createMenuItems(),
      elevation: widget.elevation.toInt(),
      onChanged: widget.disabled ? null : (value) => controller.value = value,
      icon: widget.icon,
      isExpanded: true,
      dropdownColor: widget.fillColor,
      focusColor: Colors.transparent,
      decoration: InputDecoration(
        labelText: widget.labelText == null || widget.labelText!.isEmpty
            ? null
            : widget.labelText,
        labelStyle: widget.labelTextStyle,
        border: widget.hidesUnderline
            ? InputBorder.none
            : const UnderlineInputBorder(),
      ),
      validator: widget.validator,
    );
  }

  Text? _createHintText() => widget.hintText != null
      ? Text(widget.hintText!,  style: TextStyle(decoration: widget.textStyle))
      : null;

  List<DropdownMenuItem<T>> _createMenuItems() => widget.options
      .map(
        (option) => DropdownMenuItem<T>(
          value: option,
          child: Padding(
            padding: _useDropdown2() ? horizontalMargin : EdgeInsets.zero,
            child: Text(optionLabels[option] ?? '', style: widget.textStyle),
          ),
        ),
      )
      .toList();

  List<DropdownMenuItem<T>> _createMultiselectMenuItems() => widget.options
      .map(
        (item) => DropdownMenuItem<T>(
          value: item,
          // Disable default onTap to avoid closing menu when selecting an item
          enabled: false,
          child: StatefulBuilder(
            builder: (context, menuSetState) {
              final isSelected =
                  multiSelectController.value?.contains(item) ?? false;
              return InkWell(
                onTap: () {
                  multiSelectController.value ??= [];
                  isSelected
                      ? multiSelectController.value!.remove(item)
                      : multiSelectController.value!.add(item);
                  multiSelectController.value = multiSelectController.value;
                  // This rebuilds the StatefulWidget to update the button's text.
                  setState(() {});
                  // This rebuilds the dropdownMenu Widget to update the check mark.
                  menuSetState(() {});
                },
                child: Container(
                  height: double.infinity,
                  padding: horizontalMargin,
                  child: Row(
                    children: [
                      if (isSelected)
                        const Icon(Icons.check_box_outlined)
                      else
                        const Icon(Icons.check_box_outline_blank),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          optionLabels[item]!,
                          style: widget.textStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      )
      .toList();

  Widget _buildDropdown() {
    final overlayColor = MaterialStateProperty.resolveWith<Color?>((states) =>
        states.contains(MaterialState.focused) ? Colors.transparent : null);
    final iconStyleData = widget.icon != null
        ? IconStyleData(icon: widget.icon!)
        : const IconStyleData();
    return DropdownButton2<T>(
      value: currentValue,
      hint: _createHintText(),
      items: isMultiSelect ? _createMultiselectMenuItems() : _createMenuItems(),
      iconStyleData: iconStyleData,
      buttonStyleData: ButtonStyleData(
        elevation: widget.elevation.toInt(),
        overlayColor: overlayColor,
        padding: widget.margin,
      ),
      menuItemStyleData: MenuItemStyleData(
        overlayColor: overlayColor,
        padding: EdgeInsets.zero,
      ),
      dropdownStyleData: DropdownStyleData(
        elevation: widget.elevation.toInt(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: widget.fillColor,
        ),
        isOverButton: widget.isOverButton,
        offset: widget.menuOffset ?? Offset.zero,
        maxHeight: widget.maxHeight,
        padding: EdgeInsets.zero,
      ),
      onChanged: widget.disabled
          ? null
          : (isMultiSelect ? (_) {} : (val) => widget.controller!.value = val),
      isExpanded: true,
      selectedItemBuilder: (context) => widget.options
          .map(
            (item) => Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                isMultiSelect
                    ? currentValues
                        .where((v) => optionLabels.containsKey(v))
                        .map((v) => optionLabels[v])
                        .join(', ')
                    : optionLabels[item]!,
                style: widget.textStyle,
                maxLines: 1,
              ),
            ),
          )
          .toList(),
      dropdownSearchData: widget.isSearchable
          ? DropdownSearchData<T>(
              searchController: _textEditingController,
              searchInnerWidgetHeight: 50,
              searchInnerWidget: Container(
                height: 50,
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 4,
                  right: 8,
                  left: 8,
                ),
                child: TextFormField(
                  expands: true,
                  maxLines: null,
                  controller: _textEditingController,
                  cursorColor: widget.searchCursorColor,
                  style: widget.searchTextStyle,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    hintText: widget.searchHintText,
                    hintStyle: widget.searchHintTextStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              searchMatchFn: (item, searchValue) {
                return (optionLabels[item.value] ?? '')
                    .toLowerCase()
                    .contains(searchValue.toLowerCase());
              },
            )
          : null,
      // This is to clear the search value when you close the menu
      onMenuStateChange: widget.isSearchable
          ? (isOpen) {
              if (!isOpen) {
                _textEditingController.clear();
              }
            }
          : null,
    );
  }
}

*/

// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// A [FormField] that contains a [TextField].
///
/// This is a convenience widget that wraps a [TextField] widget in a
/// [FormField].
///
/// A [Form] ancestor is not required. The [Form] allows one to
/// save, reset, or validate multiple fields at once. To use without a [Form],
/// pass a `GlobalKey<FormFieldState>` (see [GlobalKey]) to the constructor and use
/// [GlobalKey.currentState] to save or reset the form field.
///
/// When a [controller] is specified, its [TextEditingController.text]
/// defines the [initialValue]. If this [FormField] is part of a scrolling
/// container that lazily constructs its children, like a [ListView] or a
/// [CustomScrollView], then a [controller] should be specified.
/// The controller's lifetime should be managed by a stateful widget ancestor
/// of the scrolling container.
///
/// If a [controller] is not specified, [initialValue] can be used to give
/// the automatically generated controller an initial value.
///
/// {@macro flutter.material.textfield.wantKeepAlive}
///
/// Remember to call [TextEditingController.dispose] of the [TextEditingController]
/// when it is no longer needed. This will ensure any resources used by the object
/// are discarded.
///
/// By default, `decoration` will apply the [ThemeData.inputDecorationTheme] for
/// the current context to the [InputDecoration], see
/// [InputDecoration.applyDefaults].
///
/// For a documentation about the various parameters, see [TextField].
///
/// {@tool snippet}
///
/// Creates a [TextFormField] with an [InputDecoration] and validator function.
///
/// ![If the user enters valid text, the TextField appears normally without any warnings to the user](https://flutter.github.io/assets-for-api-docs/assets/material/text_form_field.png)
///
/// ![If the user enters invalid text, the error message returned from the validator function is displayed in dark red underneath the input](https://flutter.github.io/assets-for-api-docs/assets/material/text_form_field_error.png)
///
/// ```dart
/// TextFormField(
///   decoration: const InputDecoration(
///     icon: Icon(Icons.person),
///     hintText: 'What do people call you?',
///     labelText: 'Name *',
///   ),
///   onSaved: (String? value) {
///     // This optional block of code can be used to run
///     // code when the user saves the form.
///   },
///   validator: (String? value) {
///     return (value != null && value.contains('@')) ? 'Do not use the @ char.' : null;
///   },
/// )
/// ```
/// {@end-tool}
///
/// {@tool dartpad}
/// This example shows how to move the focus to the next field when the user
/// presses the SPACE key.
///
/// ** See code in examples/api/lib/material/text_form_field/text_form_field.1.dart **
/// {@end-tool}
///
/// See also:
///
///  * <https://material.io/design/components/text-fields.html>
///  * [TextField], which is the underlying text field without the [Form]
///    integration.
///  * [InputDecorator], which shows the labels and other visual elements that
///    surround the actual text editing widget.
///  * Learn how to use a [TextEditingController] in one of our [cookbook recipes](https://flutter.dev/docs/cookbook/forms/text-field-changes#2-use-a-texteditingcontroller).
///
/*
class TextFormField extends FormField<String> {
  /// Creates a [FormField] that contains a [TextField].
  ///
  /// When a [controller] is specified, [initialValue] must be null (the
  /// default). If [controller] is null, then a [TextEditingController]
  /// will be constructed automatically and its `text` will be initialized
  /// to [initialValue] or the empty string.
  ///
  /// For documentation about the various parameters, see the [TextField] class
  /// and [TextField.new], the constructor.
  TextFormField({
    super.key,
    this.controller,
    String? initialValue,
    FocusNode? focusNode,
    InputDecoration? decoration = const InputDecoration(),
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction? textInputAction,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextDirection? textDirection,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical? textAlignVertical,
    bool autofocus = false,
    bool readOnly = false,
    @Deprecated(
      'Use `contextMenuBuilder` instead. '
          'This feature was deprecated after v3.3.0-0.5.pre.',
    )
    ToolbarOptions? toolbarOptions,
    bool? showCursor,
    String obscuringCharacter = '•',
    bool obscureText = false,
    bool autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    bool enableSuggestions = true,
    MaxLengthEnforcement? maxLengthEnforcement,
    int? maxLines = 1,
    int? minLines,
    bool expands = false,
    int? maxLength,
    this.onChanged,
    GestureTapCallback? onTap,
    bool onTapAlwaysCalled = false,
    TapRegionCallback? onTapOutside,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onFieldSubmitted,
    super.onSaved,
    super.validator,
    List<TextInputFormatter>? inputFormatters,
    bool? enabled,
    bool? ignorePointers,
    double cursorWidth = 2.0,
    double? cursorHeight,
    Radius? cursorRadius,
    Color? cursorColor,
    Color? cursorErrorColor,
    Brightness? keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool? enableInteractiveSelection,
    TextSelectionControls? selectionControls,
    InputCounterWidgetBuilder? buildCounter,
    ScrollPhysics? scrollPhysics,
    Iterable<String>? autofillHints,
    AutovalidateMode? autovalidateMode,
    ScrollController? scrollController,
    super.restorationId,
    bool enableIMEPersonalizedLearning = true,
    MouseCursor? mouseCursor,
    EditableTextContextMenuBuilder? contextMenuBuilder = _defaultContextMenuBuilder,
    SpellCheckConfiguration? spellCheckConfiguration,
    TextMagnifierConfiguration? magnifierConfiguration,
    UndoHistoryController? undoController,
    AppPrivateCommandCallback? onAppPrivateCommand,
    bool? cursorOpacityAnimates,
    ui.BoxHeightStyle selectionHeightStyle = ui.BoxHeightStyle.tight,
    ui.BoxWidthStyle selectionWidthStyle = ui.BoxWidthStyle.tight,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ContentInsertionConfiguration? contentInsertionConfiguration,
    MaterialStatesController? statesController,
    Clip clipBehavior = Clip.hardEdge,
    bool scribbleEnabled = true,
    bool canRequestFocus = true,
  }) : assert(initialValue == null || controller == null),
        assert(obscuringCharacter.length == 1),
        assert(maxLines == null || maxLines > 0),
        assert(minLines == null || minLines > 0),
        assert(
        (maxLines == null) || (minLines == null) || (maxLines >= minLines),
        "minLines can't be greater than maxLines",
        ),
        assert(
        !expands || (maxLines == null && minLines == null),
        'minLines and maxLines must be null when expands is true.',
        ),
        assert(!obscureText || maxLines == 1, 'Obscured fields cannot be multiline.'),
        assert(maxLength == null || maxLength == TextField.noMaxLength || maxLength > 0),
        super(
        initialValue: controller != null ? controller.text : (initialValue ?? ''),
        enabled: enabled ?? decoration?.enabled ?? true,
        autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
        builder: (FormFieldState<String> field) {
          final _TextFormFieldState state = field as _TextFormFieldState;
          final InputDecoration effectiveDecoration = (decoration ?? const InputDecoration())
              .applyDefaults(Theme.of(field.context).inputDecorationTheme);
          void onChangedHandler(String value) {
            field.didChange(value);
            onChanged?.call(value);
          }
          return UnmanagedRestorationScope(
            bucket: field.bucket,
            child: TextField(
              restorationId: restorationId,
              controller: state._effectiveController,
              focusNode: focusNode,
              decoration: effectiveDecoration.copyWith(errorText: field.errorText),
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              style: style,
              strutStyle: strutStyle,
              textAlign: textAlign,
              textAlignVertical: textAlignVertical,
              textDirection: textDirection,
              textCapitalization: textCapitalization,
              autofocus: autofocus,
              statesController: statesController,
              toolbarOptions: toolbarOptions,
              readOnly: readOnly,
              showCursor: showCursor,
              obscuringCharacter: obscuringCharacter,
              obscureText: obscureText,
              autocorrect: autocorrect,
              smartDashesType: smartDashesType ?? (obscureText ? SmartDashesType.disabled : SmartDashesType.enabled),
              smartQuotesType: smartQuotesType ?? (obscureText ? SmartQuotesType.disabled : SmartQuotesType.enabled),
              enableSuggestions: enableSuggestions,
              maxLengthEnforcement: maxLengthEnforcement,
              maxLines: maxLines,
              minLines: minLines,
              expands: expands,
              maxLength: maxLength,
              onChanged: onChangedHandler,
              onTap: onTap,
              onTapAlwaysCalled: onTapAlwaysCalled,
              onTapOutside: onTapOutside,
              onEditingComplete: onEditingComplete,
              onSubmitted: onFieldSubmitted,
              inputFormatters: inputFormatters,
              enabled: enabled ?? decoration?.enabled ?? true,
              ignorePointers: ignorePointers,
              cursorWidth: cursorWidth,
              cursorHeight: cursorHeight,
              cursorRadius: cursorRadius,
              cursorColor: cursorColor,
              cursorErrorColor: cursorErrorColor,
              scrollPadding: scrollPadding,
              scrollPhysics: scrollPhysics,
              keyboardAppearance: keyboardAppearance,
              enableInteractiveSelection: enableInteractiveSelection ?? (!obscureText || !readOnly),
              selectionControls: selectionControls,
              buildCounter: buildCounter,
              autofillHints: autofillHints,
              scrollController: scrollController,
              enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
              mouseCursor: mouseCursor,
              contextMenuBuilder: contextMenuBuilder,
              spellCheckConfiguration: spellCheckConfiguration,
              magnifierConfiguration: magnifierConfiguration,
              undoController: undoController,
              onAppPrivateCommand: onAppPrivateCommand,
              cursorOpacityAnimates: cursorOpacityAnimates,
              selectionHeightStyle: selectionHeightStyle,
              selectionWidthStyle: selectionWidthStyle,
              dragStartBehavior: dragStartBehavior,
              contentInsertionConfiguration: contentInsertionConfiguration,
              clipBehavior: clipBehavior,
              scribbleEnabled: scribbleEnabled,
              canRequestFocus: canRequestFocus,
            ),
          );
        },
      );


  final TextEditingController? controller;

  final ValueChanged<String>? onChanged;

  static Widget _defaultContextMenuBuilder(BuildContext context, EditableTextState editableTextState) {
    return AdaptiveTextSelectionToolbar.editableText(
      editableTextState: editableTextState,
    );
  }

  @override
  FormFieldState<String> createState() => _TextFormFieldState();
}

class _TextFormFieldState extends FormFieldState<String> {
  RestorableTextEditingController? _controller;

  TextEditingController get _effectiveController => _textFormField.controller ?? _controller!.value;

  TextFormField get _textFormField => super.widget as TextFormField;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    super.restoreState(oldBucket, initialRestore);
    if (_controller != null) {
      _registerController();
    }
    // Make sure to update the internal [FormFieldState] value to sync up with
    // text editing controller value.
    setValue(_effectiveController.text);
  }

  void _registerController() {
    assert(_controller != null);
    registerForRestoration(_controller!, 'controller');
  }

  void _createLocalController([TextEditingValue? value]) {
    assert(_controller == null);
    _controller = value == null
        ? RestorableTextEditingController()
        : RestorableTextEditingController.fromValue(value);
    if (!restorePending) {
      _registerController();
    }
  }

  @override
  void initState() {
    super.initState();
    if (_textFormField.controller == null) {
      _createLocalController(widget.initialValue != null ? TextEditingValue(text: widget.initialValue!) : null);
    } else {
      _textFormField.controller!.addListener(_handleControllerChanged);
    }
  }

  @override
  void didUpdateWidget(TextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_textFormField.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      _textFormField.controller?.addListener(_handleControllerChanged);

      if (oldWidget.controller != null && _textFormField.controller == null) {
        _createLocalController(oldWidget.controller!.value);
      }

      if (_textFormField.controller != null) {
        setValue(_textFormField.controller!.text);
        if (oldWidget.controller == null) {
          unregisterFromRestoration(_controller!);
          _controller!.dispose();
          _controller = null;
        }
      }
    }
  }

  @override
  void dispose() {
    _textFormField.controller?.removeListener(_handleControllerChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChange(String? value) {
    super.didChange(value);

    if (_effectiveController.text != value) {
      _effectiveController.text = value ?? '';
    }
  }

  @override
  void reset() {

    _effectiveController.text = widget.initialValue ?? '';
    super.reset();
    _textFormField.onChanged?.call(_effectiveController.text);
  }

  void _handleControllerChanged() {

    if (_effectiveController.text != value) {
      didChange(_effectiveController.text);
    }
  }
}
*/

/*
class FlutterFlowDropDown<T> extends StatefulWidget {
  const FlutterFlowDropDown({
    super.key,
    this.controller,
    this.multiSelectController,
    this.hintText,
    this.searchHintText,
    required this.options,
    this.optionLabels,
    this.onChanged,
    this.onMultiSelectChanged,
    this.icon,
    this.width,
    this.height,
    this.maxHeight,
    this.fillColor,
    this.searchHintTextStyle,
    this.searchTextStyle,
    this.searchCursorColor,
    required this.textStyle,
    required this.elevation,
    required this.borderWidth,
    required this.borderRadius,
    required this.borderColor,
    required this.margin,
    this.hidesUnderline = false,
    this.disabled = false,
    this.isOverButton = false,
    this.menuOffset,
    this.isSearchable = false,
    this.isMultiSelect = false,
    this.labelText,
    this.labelTextStyle,
    this.validator,
  }) : assert(
          isMultiSelect
              ? (controller == null &&
                  onChanged == null &&
                  multiSelectController != null &&
                  onMultiSelectChanged != null)
              : (controller != null &&
                  onChanged != null &&
                  multiSelectController == null &&
                  onMultiSelectChanged == null),
        );

  final FormFieldController<T?>? controller;
  final FormFieldController<List<T>?>? multiSelectController;
  final String? hintText;
  final String? searchHintText;
  final List<T> options;
  final List<String>? optionLabels;
  final Function(T?)? onChanged;
  final Function(List<T>?)? onMultiSelectChanged;
  final Widget? icon;
  final double? width;
  final double? height;
  final double? maxHeight;
  final Color? fillColor;
  final TextStyle? searchHintTextStyle;
  final TextStyle? searchTextStyle;
  final Color? searchCursorColor;
  final TextStyle textStyle;
  final double elevation;
  final double borderWidth;
  final double borderRadius;
  final Color borderColor;
  final EdgeInsetsGeometry margin;
  final bool hidesUnderline;
  final bool disabled;
  final bool isOverButton;
  final Offset? menuOffset;
  final bool isSearchable;
  final bool isMultiSelect;
  final String? labelText;
  final TextStyle? labelTextStyle;

  final FormFieldValidator<T>? validator;

  @override
  State<FlutterFlowDropDown<T>> createState() => _FlutterFlowDropDownState<T>();
}

class _FlutterFlowDropDownState<T> extends State<FlutterFlowDropDown<T>> {
  bool get isMultiSelect => widget.isMultiSelect;
  FormFieldController<T?> get controller => widget.controller!;
  FormFieldController<List<T>?> get multiSelectController =>
      widget.multiSelectController!;

  T? get currentValue {
    final value = isMultiSelect
        ? multiSelectController.value?.firstOrNull
        : controller.value;
    return widget.options.contains(value) ? value : null;
  }

  Set<T> get currentValues {
    if (!isMultiSelect || multiSelectController.value == null) {
      return {};
    }
    return widget.options
        .toSet()
        .intersection(multiSelectController.value!.toSet());
  }

  Map<T, String> get optionLabels => Map.fromEntries(
        widget.options.asMap().entries.map(
              (option) => MapEntry(
                option.value,
                widget.optionLabels == null ||
                        widget.optionLabels!.length < option.key + 1
                    ? option.value.toString()
                    : widget.optionLabels![option.key],
              ),
            ),
      );

  EdgeInsetsGeometry get horizontalMargin => widget.margin.clamp(
        EdgeInsetsDirectional.zero,
        const EdgeInsetsDirectional.symmetric(horizontal: double.infinity),
      );

  late void Function() _listener;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (isMultiSelect) {
      _listener =
          () => widget.onMultiSelectChanged!(multiSelectController.value);
      multiSelectController.addListener(_listener);
    } else {
      _listener = () => widget.onChanged!(controller.value);
      controller.addListener(_listener);
    }
  }

  @override
  void dispose() {
    if (isMultiSelect) {
      multiSelectController.removeListener(_listener);
    } else {
      controller.removeListener(_listener);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dropdownWidget = _buildDropdownWidget();
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.borderColor,
            width: widget.borderWidth,
          ),
          color: widget.fillColor,
        ),
        child: Padding(
          padding: _useDropdown2() ? EdgeInsets.zero : widget.margin,
          child: widget.hidesUnderline
              ? DropdownButtonHideUnderline(child: dropdownWidget)
              : dropdownWidget,
        ),
      ),
    );
  }

  bool _useDropdown2() =>
      widget.isMultiSelect ||
      widget.isSearchable ||
      !widget.isOverButton ||
      widget.maxHeight != null;

  Widget _buildDropdownWidget() =>
      _useDropdown2() ? _buildDropdown() : _buildLegacyDropdown();

  Widget _buildLegacyDropdown() {
    return DropdownButtonFormField<T>(
      value: currentValue,
      hint: _createHintText(),
      items: _createMenuItems(),
      elevation: widget.elevation.toInt(),
      onChanged: widget.disabled ? null : (value) => controller.value = value,
      icon: widget.icon,
      isExpanded: true,
      dropdownColor: widget.fillColor,
      focusColor: Colors.transparent,
      decoration: InputDecoration(
        labelText: widget.labelText == null || widget.labelText!.isEmpty
            ? null
            : widget.labelText,
        labelStyle: widget.labelTextStyle,
        border: widget.hidesUnderline
            ? InputBorder.none
            : const UnderlineInputBorder(),
      ),
      validator: widget.validator,
    );
  }

  Text? _createHintText() => widget.hintText != null
      ? Text(widget.hintText!, style: widget.textStyle)
      : null;

  List<DropdownMenuItem<T>> _createMenuItems() => widget.options
      .map(
        (option) => DropdownMenuItem<T>(
          value: option,
          child: Padding(
            padding: _useDropdown2() ? horizontalMargin : EdgeInsets.zero,
            child: Text(optionLabels[option] ?? '', style: widget.textStyle),
          ),
        ),
      )
      .toList();

  List<DropdownMenuItem<T>> _createMultiselectMenuItems() => widget.options
      .map(
        (item) => DropdownMenuItem<T>(
          value: item,
          // Disable default onTap to avoid closing menu when selecting an item
          enabled: false,
          child: StatefulBuilder(
            builder: (context, menuSetState) {
              final isSelected =
                  multiSelectController.value?.contains(item) ?? false;
              return InkWell(
                onTap: () {
                  multiSelectController.value ??= [];
                  isSelected
                      ? multiSelectController.value!.remove(item)
                      : multiSelectController.value!.add(item);
                  multiSelectController.value = multiSelectController.value;
                  // This rebuilds the StatefulWidget to update the button's text.
                  setState(() {});
                  // This rebuilds the dropdownMenu Widget to update the check mark.
                  menuSetState(() {});
                },
                child: Container(
                  height: double.infinity,
                  padding: horizontalMargin,
                  child: Row(
                    children: [
                      if (isSelected)
                        const Icon(Icons.check_box_outlined)
                      else
                        const Icon(Icons.check_box_outline_blank),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          optionLabels[item]!,
                          style: widget.textStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      )
      .toList();

  Widget _buildDropdown() {
    final overlayColor = MaterialStateProperty.resolveWith<Color?>((states) =>
        states.contains(MaterialState.focused) ? Colors.transparent : null);
    final iconStyleData = widget.icon != null
        ? IconStyleData(icon: widget.icon!)
        : const IconStyleData();
    return DropdownButton2<T>(
      value: currentValue,
      hint: _createHintText(),
      items: isMultiSelect ? _createMultiselectMenuItems() : _createMenuItems(),
      iconStyleData: iconStyleData,
      buttonStyleData: ButtonStyleData(
        elevation: widget.elevation.toInt(),
        overlayColor: overlayColor,
        padding: widget.margin,
      ),
      menuItemStyleData: MenuItemStyleData(
        overlayColor: overlayColor,
        padding: EdgeInsets.zero,
      ),
      dropdownStyleData: DropdownStyleData(
        elevation: widget.elevation.toInt(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: widget.fillColor,
        ),
        isOverButton: widget.isOverButton,
        offset: widget.menuOffset ?? Offset.zero,
        maxHeight: widget.maxHeight,
        padding: EdgeInsets.zero,
      ),
      onChanged: widget.disabled
          ? null
          : (isMultiSelect ? (_) {} : (val) => widget.controller!.value = val),
      isExpanded: true,
      selectedItemBuilder: (context) => widget.options
          .map(
            (item) => Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                isMultiSelect
                    ? currentValues
                        .where((v) => optionLabels.containsKey(v))
                        .map((v) => optionLabels[v])
                        .join(', ')
                    : optionLabels[item]!,
                style: widget.textStyle,
                maxLines: 1,
              ),
            ),
          )
          .toList(),
      dropdownSearchData: widget.isSearchable
          ? DropdownSearchData<T>(
              searchController: _textEditingController,
              searchInnerWidgetHeight: 50,
              searchInnerWidget: Container(
                height: 50,
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 4,
                  right: 8,
                  left: 8,
                ),
                child: TextFormField(
                  expands: true,
                  maxLines: null,
                  controller: _textEditingController,
                  cursorColor: widget.searchCursorColor,
                  style: widget.searchTextStyle,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    hintText: widget.searchHintText,
                    hintStyle: widget.searchHintTextStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              searchMatchFn: (item, searchValue) {
                return (optionLabels[item.value] ?? '')
                    .toLowerCase()
                    .contains(searchValue.toLowerCase());
              },
            )
          : null,
      // This is to clear the search value when you close the menu
      onMenuStateChange: widget.isSearchable
          ? (isOpen) {
              if (!isOpen) {
                _textEditingController.clear();
              }
            }
          : null,
    );
  }
}

*/
/*

class FlutterFlowDropDown<T> extends StatefulWidget {
  const FlutterFlowDropDown({
    super.key,
    this.controller,
    this.multiSelectController,
    this.hintText,
    this.searchHintText,
    required this.options,
    this.optionLabels,
    this.onChanged,
    this.onMultiSelectChanged,
    this.icon,
    this.width,
    this.height,
    this.maxHeight,
    this.fillColor,
    this.searchHintTextStyle,
    this.searchTextStyle,
    this.searchCursorColor,
    required this.textStyle,
    required this.elevation,
    required this.borderWidth,
    required this.borderRadius,
    required this.borderColor,
    required this.margin,
    this.hidesUnderline = false,
    this.disabled = false,
    this.isOverButton = false,
    this.menuOffset,
    this.isSearchable = false,
    this.isMultiSelect = false,
    this.labelText,
    this.labelTextStyle,
    this.validator,
  }) : assert(
          isMultiSelect
              ? (controller == null &&
                  onChanged == null &&
                  multiSelectController != null &&
                  onMultiSelectChanged != null)
              : (controller != null &&
                  onChanged != null &&
                  multiSelectController == null &&
                  onMultiSelectChanged == null),
        );

  final FormFieldController<T?>? controller;
  final FormFieldController<List<T>?>? multiSelectController;
  final String? hintText;
  final String? searchHintText;
  final List<T> options;
  final List<String>? optionLabels;
  final Function(T?)? onChanged;
  final Function(List<T>?)? onMultiSelectChanged;
  final Widget? icon;
  final double? width;
  final double? height;
  final double? maxHeight;
  final Color? fillColor;
  final TextStyle? searchHintTextStyle;
  final TextStyle? searchTextStyle;
  final Color? searchCursorColor;
  final TextStyle textStyle;
  final double elevation;
  final double borderWidth;
  final double borderRadius;
  final Color borderColor;
  final EdgeInsetsGeometry margin;
  final bool hidesUnderline;
  final bool disabled;
  final bool isOverButton;
  final Offset? menuOffset;
  final bool isSearchable;
  final bool isMultiSelect;
  final String? labelText;
  final TextStyle? labelTextStyle;

  final FormFieldValidator<T>? validator;

  @override
  State<FlutterFlowDropDown<T>> createState() => _FlutterFlowDropDownState<T>();
}

class _FlutterFlowDropDownState<T> extends State<FlutterFlowDropDown<T>> {
  bool get isMultiSelect => widget.isMultiSelect;
  FormFieldController<T?> get controller => widget.controller!;
  FormFieldController<List<T>?> get multiSelectController =>
      widget.multiSelectController!;

  T? get currentValue {
    final value = isMultiSelect
        ? multiSelectController.value?.firstOrNull
        : controller.value;
    return widget.options.contains(value) ? value : null;
  }

  Set<T> get currentValues {
    if (!isMultiSelect || multiSelectController.value == null) {
      return {};
    }
    return widget.options
        .toSet()
        .intersection(multiSelectController.value!.toSet());
  }

  Map<T, String> get optionLabels => Map.fromEntries(
        widget.options.asMap().entries.map(
              (option) => MapEntry(
                option.value,
                widget.optionLabels == null ||
                        widget.optionLabels!.length < option.key + 1
                    ? option.value.toString()
                    : widget.optionLabels![option.key],
              ),
            ),
      );

  EdgeInsetsGeometry get horizontalMargin => widget.margin.clamp(
        EdgeInsetsDirectional.zero,
        const EdgeInsetsDirectional.symmetric(horizontal: double.infinity),
      );

  late void Function() _listener;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (isMultiSelect) {
      _listener =
          () => widget.onMultiSelectChanged!(multiSelectController.value);
      multiSelectController.addListener(_listener);
    } else {
      _listener = () => widget.onChanged!(controller.value);
      controller.addListener(_listener);
    }
  }

  @override
  void dispose() {
    if (isMultiSelect) {
      multiSelectController.removeListener(_listener);
    } else {
      controller.removeListener(_listener);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dropdownWidget = _buildDropdownWidget();
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: widget.borderColor,
            width: widget.borderWidth,
          ),
          color: widget.fillColor,
        ),
        child: Padding(
          padding: _useDropdown2() ? EdgeInsets.zero : widget.margin,
          child: widget.hidesUnderline
              ? DropdownButtonHideUnderline(child: dropdownWidget)
              : dropdownWidget,
        ),
      ),
    );
  }

  bool _useDropdown2() =>
      widget.isMultiSelect ||
      widget.isSearchable ||
      !widget.isOverButton ||
      widget.maxHeight != null;

  Widget _buildDropdownWidget() =>
      _useDropdown2() ? _buildDropdown() : _buildLegacyDropdown();

  Widget _buildLegacyDropdown() {
    return DropdownButtonFormField<T>(
      value: currentValue,
      hint: _createHintText(),
      items: _createMenuItems(),
      elevation: widget.elevation.toInt(),
      onChanged: widget.disabled ? null : (value) => controller.value = value,
      icon: widget.icon,
      isExpanded: true,
      dropdownColor: widget.fillColor,
      focusColor: Colors.transparent,
      decoration: InputDecoration(
        labelText: widget.labelText == null || widget.labelText!.isEmpty
            ? null
            : widget.labelText,
        labelStyle: widget.labelTextStyle,
        border: widget.hidesUnderline
            ? InputBorder.none
            : const UnderlineInputBorder(),
      ),
      validator: widget.validator,
    );
  }

  Text? _createHintText() => widget.hintText != null
      ? Text(widget.hintText!, style: widget.textStyle)
      : null;

  List<DropdownMenuItem<T>> _createMenuItems() => widget.options
      .map(
        (option) => DropdownMenuItem<T>(
          value: option,
          child: Padding(
            padding: _useDropdown2() ? horizontalMargin : EdgeInsets.zero,
            child: Text(optionLabels[option] ?? '', style: widget.textStyle),
          ),
        ),
      )
      .toList();

  List<DropdownMenuItem<T>> _createMultiselectMenuItems() => widget.options
      .map(
        (item) => DropdownMenuItem<T>(
          value: item,
          // Disable default onTap to avoid closing menu when selecting an item
          enabled: false,
          child: StatefulBuilder(
            builder: (context, menuSetState) {
              final isSelected =
                  multiSelectController.value?.contains(item) ?? false;
              return InkWell(
                onTap: () {
                  multiSelectController.value ??= [];
                  isSelected
                      ? multiSelectController.value!.remove(item)
                      : multiSelectController.value!.add(item);
                  multiSelectController.value = multiSelectController.value;
                  // This rebuilds the StatefulWidget to update the button's text.
                  setState(() {});
                  // This rebuilds the dropdownMenu Widget to update the check mark.
                  menuSetState(() {});
                },
                child: Container(
                  height: double.infinity,
                  padding: horizontalMargin,
                  child: Row(
                    children: [
                      if (isSelected)
                        const Icon(Icons.check_box_outlined)
                      else
                        const Icon(Icons.check_box_outline_blank),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          optionLabels[item]!,
                          style: widget.textStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      )
      .toList();

  Widget _buildDropdown() {
    final overlayColor = MaterialStateProperty.resolveWith<Color?>((states) =>
        states.contains(MaterialState.focused) ? Colors.transparent : null);
    final iconStyleData = widget.icon != null
        ? IconStyleData(icon: widget.icon!)
        : const IconStyleData();
    return DropdownButton2<T>(
      value: currentValue,
      hint: _createHintText(),
      items: isMultiSelect ? _createMultiselectMenuItems() : _createMenuItems(),
      iconStyleData: iconStyleData,
      buttonStyleData: ButtonStyleData(
        elevation: widget.elevation.toInt(),
        overlayColor: overlayColor,
        padding: widget.margin,
      ),
      menuItemStyleData: MenuItemStyleData(
        overlayColor: overlayColor,
        padding: EdgeInsets.zero,
      ),
      dropdownStyleData: DropdownStyleData(
        elevation: widget.elevation.toInt(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.0),
          color: widget.fillColor,
        ),
        isOverButton: widget.isOverButton,
        offset: widget.menuOffset ?? Offset.zero,
        maxHeight: widget.maxHeight,
        padding: EdgeInsets.zero,
      ),
      onChanged: widget.disabled
          ? null
          : (isMultiSelect ? (_) {} : (val) => widget.controller!.value = val),
      isExpanded: true,
      selectedItemBuilder: (context) => widget.options
          .map(
            (item) => Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                isMultiSelect
                    ? currentValues
                        .where((v) => optionLabels.containsKey(v))
                        .map((v) => optionLabels[v])
                        .join(', ')
                    : optionLabels[item]!,
                style: widget.textStyle,
                maxLines: 1,
              ),
            ),
          )
          .toList(),
      dropdownSearchData: widget.isSearchable
          ? DropdownSearchData<T>(
              searchController: _textEditingController,
              searchInnerWidgetHeight: 50,
              searchInnerWidget: Container(
                height: 50,
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 4,
                  right: 8,
                  left: 8,
                ),
                child: TextFormField(
                  expands: true,
                  maxLines: null,
                  controller: _textEditingController,
                  cursorColor: widget.searchCursorColor,
                  style: widget.searchTextStyle,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    hintText: widget.searchHintText,
                    hintStyle: widget.searchHintTextStyle,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              searchMatchFn: (item, searchValue) {
                return (optionLabels[item.value] ?? '')
                    .toLowerCase()
                    .contains(searchValue.toLowerCase());
              },
            )
          : null,
      // This is to clear the search value when you close the menu
      onMenuStateChange: widget.isSearchable
          ? (isOpen) {
              if (!isOpen) {
                _textEditingController.clear();
              }
            }
          : null,
    );
  }
}
*/
