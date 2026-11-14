import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/model/enums.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context.dart';
import '../../../core/utils/dates.dart';
import '../../../core/utils/money.dart';
import '../../../core/widgets/list_items.dart';
import '../../../core/widgets/status_widgets.dart';
import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../engine/common/local_date.dart';
import '../application/day_groups.dart';
import 'transaction_sheet.dart';
import 'transaction_tile.dart';

/// Layar Transaksi (DESIGN.md layar 07): ringkasan siklus, filter jenis,
/// kategori, dan akun, pencarian, lalu daftar per hari. Ketuk transaksi untuk
/// mengubah atau menghapusnya.
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  /// Jumlah baris per halaman. Halaman berikutnya dimuat saat daftar
  /// di-scroll mendekati akhir, jadi riwayat panjang tidak dibaca sekaligus.
  static const pageSize = 100;

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _search = TextEditingController();
  Timer? _debounce;
  var _searching = false;
  var _filter = TransactionFilter.none;
  var _limit = TransactionsScreen.pageSize;

  // Hasil terakhir yang sudah dimuat, supaya daftar tidak berkedip kosong
  // selama query untuk filter atau halaman baru berjalan.
  List<TransactionView>? _shown;
  var _shownLimit = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _setFilter(TransactionFilter filter) {
    if (!mounted || filter == _filter) return;
    setState(() {
      _filter = filter;
      _limit = TransactionsScreen.pageSize;
    });
  }

  void _onQueryChanged(String text) {
    setState(() {}); // tombol hapus teks muncul/hilang
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () => _setFilter(_filter.withQuery(text)));
  }

  void _closeSearch() {
    _debounce?.cancel();
    _search.clear();
    setState(() => _searching = false);
    _setFilter(_filter.withQuery(''));
  }

  void _clearAll() {
    _debounce?.cancel();
    _search.clear();
    _setFilter(TransactionFilter.none);
  }

  bool _onScroll(ScrollNotification notification, {required bool truncated}) {
    final waiting = _shownLimit != _limit;
    if (truncated && !waiting && notification.metrics.extentAfter < 600) {
      setState(() => _limit += TransactionsScreen.pageSize);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = transactionListProvider((filter: _filter, limit: _limit));
    ref.listen(provider, (_, next) {
      if (next case AsyncError(:final error, :final stackTrace)) {
        debugPrint('Daftar transaksi gagal dimuat: $error\n$stackTrace');
      }
    });
    final list = ref.watch(provider);
    if (list case AsyncData(:final value)) {
      _shown = value;
      _shownLimit = _limit;
    }
    final views = _shown;
    final truncated = views != null && views.length >= _shownLimit;
    final today = LocalDate.fromDateTime(ref.watch(clockProvider)());

    return PopScope(
      canPop: !_searching,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _closeSearch();
      },
      child: Scaffold(
        appBar: _searching
            ? _searchBar(context)
            : AppBar(
                title: const Text('Transaksi'),
                actions: [
                  IconButton(
                    tooltip: 'Cari transaksi',
                    onPressed: () => setState(() => _searching = true),
                    icon: const Icon(AppIcons.search),
                  ),
                ],
              ),
        body: NotificationListener<ScrollNotification>(
          onNotification: (notification) => _onScroll(notification, truncated: truncated),
          child: CustomScrollView(
            slivers: [
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  AppSpacing.s8,
                  AppSpacing.screen,
                  AppSpacing.s8,
                ),
                sliver: SliverToBoxAdapter(child: _CycleSummary()),
              ),
              SliverToBoxAdapter(
                child: _FilterChips(filter: _filter, onChanged: _setFilter),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen,
                  0,
                  AppSpacing.screen,
                  AppSpacing.s48 * 2,
                ),
                sliver: _list(views, today, truncated: truncated, failed: list.hasError),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _list(
    List<TransactionView>? views,
    LocalDate today, {
    required bool truncated,
    required bool failed,
  }) {
    Widget note(Widget child) => SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.s16),
        child: child,
      ),
    );
    if (views == null) {
      return failed
          ? note(const EmptyNote('Transaksi gagal dimuat. Coba buka lagi layar ini.'))
          : const SliverToBoxAdapter(child: SizedBox(height: 120));
    }
    final days = groupByDay(views, truncated: truncated);
    if (days.isEmpty) {
      return note(
        _filter.isEmpty
            ? const EmptyNote('Belum ada transaksi. Ketuk + untuk mencatat yang pertama.')
            : EmptyNote(
                'Tidak ada transaksi yang cocok.',
                actionLabel: 'Hapus filter',
                onAction: _clearAll,
              ),
      );
    }
    return SliverList.builder(
      itemCount: days.length,
      itemBuilder: (context, index) => _DayGroup(day: days[index], today: today),
    );
  }

  PreferredSizeWidget _searchBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        tooltip: 'Tutup pencarian',
        onPressed: _closeSearch,
        icon: const Icon(AppIcons.chevronLeft),
      ),
      titleSpacing: 0,
      title: TextField(
        controller: _search,
        autofocus: true,
        textInputAction: TextInputAction.search,
        style: AppTypography.bodyLarge.copyWith(color: context.colors.textPrimary),
        decoration: const InputDecoration(
          hintText: 'Cari transaksi',
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: _onQueryChanged,
        onSubmitted: (text) {
          _debounce?.cancel();
          _setFilter(_filter.withQuery(text));
        },
      ),
      actions: [
        if (_search.text.isNotEmpty)
          IconButton(
            tooltip: 'Hapus teks',
            onPressed: () {
              _search.clear();
              _onQueryChanged('');
            },
            icon: const Icon(AppIcons.close),
          ),
      ],
    );
  }
}

/// "Siklus 25 Okt – 24 Nov": pemasukan dan pengeluaran siklus berjalan, tanpa
/// transfer. Tidak ikut filter, supaya angkanya selalu bisa dibandingkan.
class _CycleSummary extends ConsumerWidget {
  const _CycleSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final summary = ref.watch(cycleTotalsProvider).value;
    if (summary == null) return const SizedBox(height: 104);
    final cycle = summary.cycle;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Siklus ${formatDateRange(cycle.start, cycle.end)}',
              style: AppTypography.labelMedium.copyWith(color: c.textTertiary),
            ),
            const SizedBox(height: AppSpacing.s12),
            Row(
              children: [
                Expanded(
                  child: _Flow(
                    label: 'Masuk',
                    icon: AppIcons.arrowDownLeft,
                    iconColor: c.tone(Tone.brand).fg,
                    value: formatRupiah(summary.totals.income, signed: true),
                    valueColor: c.textIncome,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                  child: Container(width: 1, height: 40, color: c.bgSurfaceMuted),
                ),
                Expanded(
                  child: _Flow(
                    label: 'Keluar',
                    icon: AppIcons.arrowUpRight,
                    iconColor: c.tone(Tone.neutral).fg,
                    value: formatRupiah(summary.totals.expense),
                    valueColor: c.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Flow extends StatelessWidget {
  const _Flow({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: AppSpacing.s4),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(color: context.colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTypography.titleMedium.copyWith(
                color: valueColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip filter yang di-scroll menyamping (DESIGN.md §8.4). Tiap kelompok
/// (jenis, kategori, akun) satu pilihan, dan kelompoknya bisa digabung.
class _FilterChips extends ConsumerWidget {
  const _FilterChips({required this.filter, required this.onChanged});

  final TransactionFilter filter;
  final ValueChanged<TransactionFilter> onChanged;

  static const _types = [
    (TransactionType.expense, 'Pengeluaran'),
    (TransactionType.income, 'Pemasukan'),
    (TransactionType.transfer, 'Transfer'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountBalancesProvider).value ?? const <AccountBalance>[];
    final allCategories = ref.watch(allCategoriesProvider).value ?? const <CategoryRecord>[];
    CategoryRecord? selectedCategory;
    for (final category in allCategories) {
      if (category.id == filter.categoryId) selectedCategory = category;
    }

    final chips = <Widget>[
      FilterChip(
        label: const Text('Semua'),
        selected: !filter.hasSelection,
        onSelected: (_) => onChanged(TransactionFilter(query: filter.query)),
      ),
      for (final (type, label) in _types)
        FilterChip(
          label: Text(label),
          selected: filter.type == type,
          onSelected: (_) =>
              onChanged(_withType(filter.type == type ? null : type, selectedCategory)),
        ),
      FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selectedCategory?.name ?? 'Kategori'),
            const SizedBox(width: AppSpacing.s4),
            Icon(AppIcons.chevronDown, size: 16, color: context.colors.iconSecondary),
          ],
        ),
        selected: selectedCategory != null,
        onSelected: (_) => unawaited(
          _pickCategory(context, [
            for (final category in allCategories)
              if (!category.archived) category,
          ]),
        ),
      ),
      for (final entry in accounts)
        FilterChip(
          label: Text(entry.account.name),
          selected: filter.accountId == entry.account.id,
          onSelected: (_) => onChanged(
            filter.withAccount(filter.accountId == entry.account.id ? null : entry.account.id),
          ),
        ),
    ];

    // Chip-nya sedikit, jadi semuanya dibangun sekaligus (bukan ListView lazy)
    // supaya pembaca layar bisa menjangkau semua pilihan tanpa scroll.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: Row(
        children: [
          for (final (index, chip) in chips.indexed) ...[
            if (index > 0) const SizedBox(width: AppSpacing.s8),
            chip,
          ],
        ],
      ),
    );
  }

  /// Transfer tidak punya kategori, dan kategori pengeluaran tidak cocok dengan
  /// pemasukan, jadi kategori yang bertentangan dengan jenis baru dilepas.
  TransactionFilter _withType(TransactionType? type, CategoryRecord? category) {
    final next = filter.withType(type);
    if (category == null || type == null || _typeOf(category) == type) return next;
    return next.withCategory(null);
  }

  static TransactionType _typeOf(CategoryRecord category) =>
      category.type == CategoryType.income ? TransactionType.income : TransactionType.expense;

  Future<void> _pickCategory(BuildContext context, List<CategoryRecord> categories) async {
    final picked = await showModalBottomSheet<({CategoryRecord? category})>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _CategoryPicker(categories: categories, selectedId: filter.categoryId),
    );
    if (picked == null) return;
    final category = picked.category;
    onChanged(
      category == null
          ? filter.withCategory(null)
          : filter.withCategory(category.id).withType(_typeOf(category)),
    );
  }
}

/// Daftar kategori untuk filter. Memilih kategori ikut memilih jenisnya.
class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({required this.categories, required this.selectedId});

  final List<CategoryRecord> categories;
  final int? selectedId;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    Widget section(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.s16,
        AppSpacing.screen,
        AppSpacing.s4,
      ),
      child: Semantics(
        header: true,
        child: Text(title, style: AppTypography.overline.copyWith(color: c.textTertiary)),
      ),
    );

    Widget tile(CategoryRecord? category) {
      final selected = category?.id == selectedId;
      return ListTile(
        leading: category == null
            ? null
            : CategoryTile(icon: AppIcons.named(category.icon), tone: category.tone, size: 32),
        title: Text(category?.name ?? 'Semua kategori'),
        trailing: selected ? Icon(AppIcons.check, color: c.textBrand) : null,
        selected: selected,
        onTap: () => Navigator.pop(context, (category: category)),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.75),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: AppSpacing.s16),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
            child: Text(
              'Pilih kategori',
              style: AppTypography.titleMedium.copyWith(color: c.textPrimary),
            ),
          ),
          tile(null),
          section('PENGELUARAN'),
          for (final category in categories)
            if (category.type == CategoryType.expense) tile(category),
          section('PEMASUKAN'),
          for (final category in categories)
            if (category.type == CategoryType.income) tile(category),
        ],
      ),
    );
  }
}

/// Satu hari: judul tanggal dengan total harian, lalu kartu berisi transaksinya.
class _DayGroup extends StatelessWidget {
  const _DayGroup({required this.day, required this.today});

  final TransactionDay day;
  final LocalDate today;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.s16, bottom: AppSpacing.s8),
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    formatDayHeader(day.date, today).toUpperCase(),
                    style: AppTypography.overline.copyWith(color: c.textTertiary),
                  ),
                ),
              ),
              if (day.complete && day.hasCashFlow)
                Text(
                  formatRupiah(day.net, signed: true),
                  style: AppTypography.labelMedium.copyWith(
                    color: c.textTertiary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          ),
        ),
        ListCard(
          children: [
            for (final view in day.items)
              transactionListItem(
                context,
                view,
                onTap: () => unawaited(showTransactionSheet(context, editing: view)),
              ),
          ],
        ),
      ],
    );
  }
}
