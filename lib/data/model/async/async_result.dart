import 'package:freezed_annotation/freezed_annotation.dart';

part 'async_result.freezed.dart';

@freezed
class AsyncResult3<R> with _$AsyncResult3<R> {
  const AsyncResult3._();

  const factory AsyncResult3.loading([R? prev]) = AsyncResultLoading;

  const factory AsyncResult3.success(R value) = AsyncResultSuccess;

  const factory AsyncResult3.error(dynamic error, [StackTrace? stackTrace]) = AsyncResultError;

  T as<T extends AsyncResult3<R>>() => this as T;

  bool get isSuccess => this is AsyncResultSuccess;

  R get data => as<AsyncResultSuccess<R>>().value;
}

@freezed
class AsyncResult4<R> with _$AsyncResult4<R> {
  const AsyncResult4._();

  const factory AsyncResult4.idle() = AsyncResult4Idle;

  const factory AsyncResult4.loading([R? prev]) = AsyncResult4Loading;

  const factory AsyncResult4.success(R value) = AsyncResult4Success;

  const factory AsyncResult4.error(dynamic error, [StackTrace? stackTrace]) = AsyncResult4Error;

  bool get isSuccess => this is AsyncResult4Success;

  bool get isLoading => this is AsyncResult4Loading;
}
