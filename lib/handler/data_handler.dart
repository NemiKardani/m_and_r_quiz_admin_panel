import 'package:flutter/material.dart';
import 'package:m_and_r_quiz_admin_panel/components/nk_error_widget.dart';
import 'package:m_and_r_quiz_admin_panel/components/nk_loading_widget.dart';

class DataHandler<T> {
  late bool _isLoading;
  late bool _hasError;
  late bool _hasEmpty;
  late T? _data;
  late String _error;
  late String _emptyError;

  DataHandler([T? data]) {
    if (data != null) {
      _data = data;
    }
    _hasEmpty = false;
    _isLoading = true;
    _hasError = false;
    _data = null;
    _error = '';
    _emptyError = '';
  }

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  T? get data => _data;
  String get error => _error;
  String get empty => _emptyError;

  void startLoading() {
    _isLoading = true;
    _hasError = false;
    _data = null;
    _error = '';
  }

  void onUpdate(T newData) {
    _isLoading = false;
    _hasError = false;
    _data = newData;
    _error = '';
  }

  void onSuccess(T newData) {
    _isLoading = false;
    _hasError = false;
    _data = newData;
    _error = '';
  }

  void onError(String errorMessage) {
    _isLoading = false;
    _hasError = true;
    _data = null;
    _error = errorMessage;
  }

  void onEmpty(String errorMessage) {
    _isLoading = false;
    _hasError = true;
    _data = null;
    _error = errorMessage;
    _emptyError = errorMessage;
  }

  Widget when({
    required BuildContext context,
    Widget Function(BuildContext)? loadingBuilder,
    required Widget Function(T) successBuilder,
    Widget Function(String)? errorBuilder,
    Widget Function(String)? emptyBuilder,
  }) {
    if (_isLoading) {
      return loadingBuilder?.call(context) ?? const NkLoadingWidget();
    } else if (_hasError) {
      return errorBuilder?.call(_error) ??
          NkErrorWidget(
            errorMessage: _error,
          );
    } else if (_data != null) {
      return successBuilder.call(_data as T);
    } else if (_hasEmpty) {
      return emptyBuilder?.call(_emptyError) ??
          NkErrorWidget(
            errorMessage: _error,
          );
    } else {
      return const NkErrorWidget(); // You can return a default widget for empty state
    }
  }
}

checkAPIDataNotNull(DataHandler handler,
    {Function(DataHandler handler)? onChange}) {
  if (handler.data != null &&
      handler.data.toString().isNotEmpty &&
      handler.data.error == false) {
    handler.onSuccess(handler.data);
    onChange?.call(handler);
  } else if (handler.data == null && handler.data.error == true) {
    handler.onError(handler.data.message.toString());
    onChange?.call(handler);
  } else {
    handler.onEmpty('No data found');
    onChange?.call(handler.data);
  }
}
