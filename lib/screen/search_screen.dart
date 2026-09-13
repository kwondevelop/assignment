import 'package:flutter/material.dart';

import '../data/stock_api.dart';
import '../model/search.dart';
import '../model/stock_meta.dart';
import '../state/favorite_store.dart';
import '../theme/theme.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.favoriteStore});

  final FavoriteStore favoriteStore;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _textController = TextEditingController();

  final StockApi _stockApi = StockApi();

  List<Search> _results = [];
  String _searchedKeyword = '';
  String? _error;
  bool _isLoading = false;

  // 이전 검색 응답이 최신 화면을 덮지 않도록 구분합니다.
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    widget.favoriteStore.addListener(_onFavoritesChanged);
  }

  void _onFavoritesChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.favoriteStore.removeListener(_onFavoritesChanged);
    _textController.dispose();
    super.dispose();
  }

  void _toggleFavorite(Search stock) {
    final wasFavorite = widget.favoriteStore.contains(stock.code);

    widget.favoriteStore.toggle(
      StockMeta(
        symbolCode: stock.code,
        stockName: stock.name,
        exchangeName: stock.exchangeName,
      ),
    );

    final messenger = ScaffoldMessenger.of(context);

    // 연속 클릭 시 토스트 교체
    messenger.removeCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: context.colors.surfaceOverlay,
        elevation: 0,
        margin: EdgeInsets.all(context.dimens.space4),
        padding: EdgeInsets.symmetric(
          horizontal: context.dimens.space4,
          vertical: context.dimens.space3,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.dimens.radiusMd),
        ),
        content: Row(
          children: [
            Icon(
              wasFavorite ? Icons.star_border : Icons.star,
              size: context.dimens.iconMd,
              color: wasFavorite
                  ? context.colors.favoriteInactive
                  : context.colors.favoriteActive,
            ),
            SizedBox(width: context.dimens.space2),
            Expanded(
              child: Text(
                wasFavorite ? '관심이 해제되었습니다' : '관심이 등록되었습니다',
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onInputChanged(String value) {
    setState(() {
      _requestId++;
      _results = [];
      _searchedKeyword = '';
      _error = null;
      _isLoading = false;
    });
  }

  void _clearInput() {
    _textController.clear();
    _onInputChanged('');
  }

  Future<void> _search() async {
    final keyword = _textController.text;

    if (keyword.trim().isEmpty) {
      _onInputChanged(keyword);
      return;
    }

    FocusScope.of(context).unfocus();

    final requestId = ++_requestId;

    setState(() {
      _isLoading = true;
      _error = null;
      _searchedKeyword = keyword;
      _results = [];
    });

    try {
      final candidates = await _stockApi.searchStocks(keyword);

      if (!mounted || requestId != _requestId) return;

      final results = <Search>[];
      int metadataFailures = 0;

      for (final candidate in candidates) {
        // 사용자가 검색어를 바꾸면 이전 검색 작업은 중단합니다.
        if (!mounted || requestId != _requestId) return;

        try {
          final metadata = await _stockApi.fetchMetadata(candidate.code);

          if (!mounted || requestId != _requestId) return;

          results.add(
            Search(
              id: candidate.id,
              code: metadata.symbolCode,
              name: metadata.stockName,
              exchangeName: metadata.exchangeName,
            ),
          );
        } catch (error) {
          debugPrint('종목 정보 조회 오류: $error');

          // 메타데이터 조회 실패 시 검색 응답으로 결과를 유지합니다.
          results.add(candidate);
          metadataFailures++;
        }
      }

      if (!mounted || requestId != _requestId) return;

      setState(() {
        _results = results;
      });

      if (metadataFailures > 0) {
        final messenger = ScaffoldMessenger.of(context);

        messenger.removeCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            backgroundColor: context.colors.surfaceOverlay,
            content: Text(
              '일부 종목 정보는 검색 응답으로 표시했습니다. 다시 검색하면 재시도합니다.',
              style: TextStyle(color: context.colors.textPrimary),
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted || requestId != _requestId) return;

      debugPrint('종목 검색 오류: $error');

      setState(() {
        _error = '검색하지 못했습니다. 다시 시도해 주세요.';
      });
    } finally {
      if (mounted && requestId == _requestId) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildHighlightedName(String name) {
    final keyword = _searchedKeyword;
    final spans = <TextSpan>[];

    if (keyword.isEmpty) {
      spans.add(TextSpan(text: name));
    } else {
      final lowerName = name.toLowerCase();
      final lowerKeyword = keyword.toLowerCase();
      int start = 0;

      while (start < name.length) {
        final match = lowerName.indexOf(lowerKeyword, start);

        if (match == -1) {
          spans.add(TextSpan(text: name.substring(start)));
          break;
        }

        if (match > start) {
          spans.add(TextSpan(text: name.substring(start, match)));
        }

        final end = match + keyword.length;

        spans.add(
          TextSpan(
            text: name.substring(match, end),
            style: TextStyle(color: context.colors.searchHighlight),
          ),
        );

        start = end;
      }
    }

    return Text.rich(
      TextSpan(
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        children: spans,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMessage(String title, String description) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.dimens.space6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 40, color: context.colors.textTertiary),
            SizedBox(height: context.dimens.space4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 18,
                fontWeight: AppTypography.bold,
                height: 1.4,
              ),
            ),
            SizedBox(height: context.dimens.space2),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textTertiary,
                fontSize: 11,
                fontWeight: AppTypography.regular,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: context.colors.accentDefault),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              style: TextStyle(color: context.colors.feedbackWarning),
            ),
            TextButton(
              onPressed: _search,
              child: Text(
                '재시도',
                style: TextStyle(color: context.colors.accentDefault),
              ),
            ),
          ],
        ),
      );
    }

    if (_searchedKeyword.isEmpty) {
      return _buildMessage('종목을 검색해 보세요', '종목명 또는 종목코드 6자리로 \n검색하실 수 있습니다.');
    }

    if (_results.isEmpty) {
      return _buildMessage(
        '검색 결과가 없습니다',
        "'$_searchedKeyword'와 일치하는 검색 결과를 찾지 못했습니다.",
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: context.dimens.space4),
      itemCount: _results.length,
      separatorBuilder: (context, index) => Divider(
        height: context.dimens.borderHairline,
        color: context.colors.borderSubtle,
      ),
      itemBuilder: (context, index) {
        final stock = _results[index];
        final isFavorite = widget.favoriteStore.contains(stock.code);

        return ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => DetailScreen(
                  stock: StockMeta(
                    symbolCode: stock.code,
                    stockName: stock.name,
                    exchangeName: stock.exchangeName,
                  ),
                  favoriteStore: widget.favoriteStore,
                ),
              ),
            );
          },
          title: _buildHighlightedName(stock.name),
          subtitle: Text(
            '${stock.code} · ${stock.exchangeName}',
            style: TextStyle(color: context.colors.textTertiary, fontSize: 11),
          ),
          trailing: IconButton(
            tooltip: isFavorite ? '관심 해제' : '관심 등록',
            onPressed: () => _toggleFavorite(stock),
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              size: context.dimens.iconMd,
              color: isFavorite
                  ? context.colors.favoriteActive
                  : context.colors.favoriteInactive,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(context.dimens.radiusMd),
      borderSide: BorderSide(
        color: context.colors.borderSubtle,
        width: context.dimens.borderHairline,
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.dimens.space4,
                context.dimens.space4,
                context.dimens.space4,
                context.dimens.space2,
              ),
              child: SizedBox(
                height: 40,
                child: TextField(
                  controller: _textController,
                  onChanged: _onInputChanged,
                  onSubmitted: (_) => _search(),
                  textInputAction: TextInputAction.search,
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: context.colors.accentDefault,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: '종목명 또는 종목코드',
                    hintStyle: TextStyle(
                      color: context.colors.textTertiary,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: context.colors.surfaceRaised,
                    contentPadding: EdgeInsets.zero,
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 40,
                    ),
                    prefixIcon: IconButton(
                      tooltip: '검색',
                      onPressed: _search,
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.search,
                        size: context.dimens.iconSm,
                        color: context.colors.textTertiary,
                      ),
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 40,
                    ),
                    suffixIcon: IconButton(
                      tooltip: '입력 지우기',
                      onPressed: _clearInput,
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.close,
                        size: context.dimens.iconSm,
                        color: context.colors.textTertiary,
                      ),
                    ),
                    border: border,
                    enabledBorder: border,
                    focusedBorder: border.copyWith(
                      borderSide: BorderSide(
                        color: context.colors.accentDefault,
                        width: context.dimens.borderHairline,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }
}
