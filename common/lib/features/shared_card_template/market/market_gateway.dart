import 'package:dio/dio.dart';

import 'market_dtos.dart';

typedef MarketAuthHeadersProvider = Future<Map<String, String>> Function();

abstract class MarketGateway {
  Future<MarketTemplatesPageDto> listTemplates({
    String? cursor,
    int limit = 20,
    String? query,
    List<String>? tags,
  });

  Future<MarketTemplateDetailDto> getTemplateDetail({
    required String templateId,
  });

  Future<MarketTemplatePayloadDto> getTemplatePayload({
    required String templateId,
    required String versionId,
  });

  Future<MarketTemplateDetailDto> publishTemplate({
    required PublishMarketTemplateRequestDto request,
  });
}

class DioMarketGateway implements MarketGateway {
  DioMarketGateway({
    required String baseUrl,
    Dio? dio,
    Map<String, String>? defaultHeaders,
    MarketAuthHeadersProvider? authHeadersProvider,
  })  : _dio = dio ?? Dio(),
        _defaultHeaders = Map.unmodifiable(defaultHeaders ?? const {}),
        _authHeadersProvider = authHeadersProvider {
    _dio.options.baseUrl = baseUrl;
  }

  final Dio _dio;
  final Map<String, String> _defaultHeaders;
  final MarketAuthHeadersProvider? _authHeadersProvider;

  Future<Map<String, String>> _headers() async {
    final auth = _authHeadersProvider;
    if (auth == null) return _defaultHeaders;

    final fromAuth = await auth();
    return {
      ..._defaultHeaders,
      ...fromAuth,
    };
  }

  static Map<String, dynamic> _requireJsonObject(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    throw DioException(
      requestOptions: RequestOptions(),
      type: DioExceptionType.badResponse,
      error: 'Expected JSON object',
    );
  }

  @override
  Future<MarketTemplatesPageDto> listTemplates({
    String? cursor,
    int limit = 20,
    String? query,
    List<String>? tags,
  }) async {
    final response = await _dio.get(
      '/v1/market/templates',
      queryParameters: <String, dynamic>{
        if (cursor != null) 'cursor': cursor,
        'limit': limit,
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        if (tags != null && tags.isNotEmpty) 'tags': tags,
      },
      options: Options(headers: await _headers()),
    );

    final json = _requireJsonObject(response.data);
    return MarketTemplatesPageDto.fromJson(json);
  }

  @override
  Future<MarketTemplateDetailDto> getTemplateDetail({
    required String templateId,
  }) async {
    final response = await _dio.get(
      '/v1/market/templates/$templateId',
      options: Options(headers: await _headers()),
    );

    final json = _requireJsonObject(response.data);
    return MarketTemplateDetailDto.fromJson(json);
  }

  @override
  Future<MarketTemplatePayloadDto> getTemplatePayload({
    required String templateId,
    required String versionId,
  }) async {
    final response = await _dio.get(
      '/v1/market/templates/$templateId/versions/$versionId/payload',
      options: Options(headers: await _headers()),
    );

    final json = _requireJsonObject(response.data);
    return MarketTemplatePayloadDto.fromJson(json);
  }

  @override
  Future<MarketTemplateDetailDto> publishTemplate({
    required PublishMarketTemplateRequestDto request,
  }) async {
    final response = await _dio.post(
      '/v1/market/templates',
      data: request.toJson(),
      options: Options(headers: await _headers()),
    );

    final json = _requireJsonObject(response.data);
    return MarketTemplateDetailDto.fromJson(json);
  }
}
