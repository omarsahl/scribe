import 'package:mobx/mobx.dart';

extension ObservableStreamX<T, R> on ObservableStream<T> {
  R when({
    required R Function() onLoading,
    required R Function(T value) onData,
    required R Function(dynamic error) onError,
  }) {
    if (status == StreamStatus.waiting) {
      return onLoading();
    }
    if (hasError) {
      return onError(error);
    }
    final T streamData = data;
    if (streamData == null) {
      return onLoading();
    }
    return onData(streamData);
  }
}
