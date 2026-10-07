// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:get_it/get_it.dart' as _i174;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/auth/data/datasources/auth_remote_data_source.dart' as _i558;
import '../../features/auth/data/repositories/auth_repository_impl.dart' as _i559;
import '../../features/auth/presentation/bloc/auth_bloc.dart' as _i560;
import '../../features/scp/data/datasources/scp_local_data_source.dart'
    as _i284;
import '../../features/scp/data/datasources/scp_remote_data_source.dart'
    as _i543;
import '../../features/scp/data/repositories/scp_repository_impl.dart' as _i557;
import '../../features/scp/domain/repositories/scp_repository.dart' as _i319;
import '../../features/scp/domain/usecases/get_scp_articles.dart' as _i483;
import '../../features/scp/domain/usecases/get_scp_detail.dart' as _i1018;
import '../../features/scp/domain/usecases/manage_bookmarks.dart' as _i843;
import '../../features/scp/domain/usecases/manage_history.dart' as _i574;
import '../../features/scp/presentation/bloc/bookmark/bookmark_bloc.dart'
    as _i568;
import '../../features/scp/presentation/bloc/history/history_bloc.dart'
    as _i691;
import '../../features/scp/presentation/bloc/scp_detail/scp_detail_bloc.dart'
    as _i953;
import '../../features/scp/presentation/bloc/scp_list/scp_list_bloc.dart'
    as _i699;
import 'injection.dart' as _i464;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i519.Client>(() => registerModule.httpClient);
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => registerModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i543.ScpRemoteDataSource>(
      () => _i543.ScpRemoteDataSourceImpl(client: gh<_i519.Client>()),
    );
    gh.lazySingleton<_i284.ScpLocalDataSource>(
      () => _i284.ScpLocalDataSourceImpl(
        sharedPreferences: gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i558.AuthRemoteDataSource>(
      () => _i558.AuthRemoteDataSourceImpl(
        client: gh<_i519.Client>(),
        sharedPreferences: gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i559.AuthRepository>(
      () => _i559.AuthRepositoryImpl(
        remoteDataSource: gh<_i558.AuthRemoteDataSource>(),
      ),
    );
    gh.factory<_i560.AuthBloc>(
      () => _i560.AuthBloc(
        authRepository: gh<_i559.AuthRepository>(),
      ),
    );
    gh.lazySingleton<_i319.ScpRepository>(
      () => _i557.ScpRepositoryImpl(
        remoteDataSource: gh<_i543.ScpRemoteDataSource>(),
        localDataSource: gh<_i284.ScpLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i483.GetScpArticles>(
      () => _i483.GetScpArticles(gh<_i319.ScpRepository>()),
    );
    gh.lazySingleton<_i1018.GetScpDetail>(
      () => _i1018.GetScpDetail(gh<_i319.ScpRepository>()),
    );
    gh.lazySingleton<_i843.GetBookmarks>(
      () => _i843.GetBookmarks(gh<_i319.ScpRepository>()),
    );
    gh.lazySingleton<_i843.ToggleBookmark>(
      () => _i843.ToggleBookmark(gh<_i319.ScpRepository>()),
    );
    gh.lazySingleton<_i843.IsBookmarked>(
      () => _i843.IsBookmarked(gh<_i319.ScpRepository>()),
    );
    gh.lazySingleton<_i574.GetHistory>(
      () => _i574.GetHistory(gh<_i319.ScpRepository>()),
    );
    gh.lazySingleton<_i574.AddToHistory>(
      () => _i574.AddToHistory(gh<_i319.ScpRepository>()),
    );
    gh.lazySingleton<_i574.ClearHistory>(
      () => _i574.ClearHistory(gh<_i319.ScpRepository>()),
    );
    gh.factory<_i691.HistoryBloc>(
      () => _i691.HistoryBloc(
        getHistory: gh<_i574.GetHistory>(),
        clearHistory: gh<_i574.ClearHistory>(),
      ),
    );
    gh.factory<_i699.ScpListBloc>(
      () => _i699.ScpListBloc(gh<_i483.GetScpArticles>()),
    );
    gh.factory<_i953.ScpDetailBloc>(
      () => _i953.ScpDetailBloc(
        getScpDetail: gh<_i1018.GetScpDetail>(),
        checkIsBookmarked: gh<_i843.IsBookmarked>(),
        toggleBookmark: gh<_i843.ToggleBookmark>(),
        addToHistory: gh<_i574.AddToHistory>(),
      ),
    );
    gh.factory<_i568.BookmarkBloc>(
      () => _i568.BookmarkBloc(
        getBookmarks: gh<_i843.GetBookmarks>(),
        toggleBookmark: gh<_i843.ToggleBookmark>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i464.RegisterModule {}
