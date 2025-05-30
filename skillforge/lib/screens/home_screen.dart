import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/challenge_provider.dart';
import '../widgets/home_header.dart';
import '../widgets/search_bar.dart';
import '../widgets/active_challenge.dart';
import '../widgets/challenge_list.dart';
import '../providers/search_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final challengeState = ref.watch(challengeProvider);
    final searchState = ref.watch(searchProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildAppBarHeader(),
                _buildSearchBar(),
                _buildActiveChallenge(challengeState),
                if (searchState.query.isEmpty) _buildTabBar(),
              ];
            },
            body: searchState.query.isNotEmpty 
                ? _buildSearchResults(searchState)
                : _buildTabBarView(challengeState),
          ),
        ),
      ),
      floatingActionButton: _buildCreateButton(),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  SliverAppBar _buildAppBarHeader() {
    return SliverAppBar(
      floating: true,
      pinned: false,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      expandedHeight: 120,
      collapsedHeight: 80,
      flexibleSpace: FlexibleSpaceBar(
        background: HomeHeader(
          onProfileTap: () {
          },
        ),
      ),
    );
  }

  SliverPersistentHeader _buildSearchBar() {
    return SliverPersistentHeader(
      delegate: SearchBarDelegate(
        controller: _searchController,
        onChanged: () {
          ref.read(searchProvider.notifier).searchChallenges(_searchController.text);
        },
      ),
      pinned: true,
    );
  }

  SliverToBoxAdapter _buildActiveChallenge(ChallengeState challengeState) {
    return SliverToBoxAdapter(
      child: challengeState.activeChallenges.isNotEmpty
          ? ActiveChallengeCard(challenge: challengeState.activeChallenges.first)
          : const SizedBox.shrink(),
    );
  }

  SliverAppBar _buildTabBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      automaticallyImplyLeading: false,
      toolbarHeight: 0,
      elevation: 0,
      bottom: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Theme.of(context).colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Popular'),
          Tab(text: 'New'),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchState searchState) {
    return ChallengeList(
      challenges: searchState.results,
      isLoading: searchState.isSearching,
    );
  }

  TabBarView _buildTabBarView(ChallengeState challengeState) {
    return TabBarView(
      controller: _tabController,
      children: [
        ChallengeList(
          challenges: challengeState.allChallenges,
          isLoading: challengeState.isLoading,
        ),
        Consumer(
          builder: (context, ref, child) {
            final popularChallenges = ref.watch(popularChallengesProvider);
            return ChallengeList(
              challenges: popularChallenges,
              isLoading: challengeState.isLoading,
            );
          },
        ),
        Consumer(
          builder: (context, ref, child) {
            final newChallenges = ref.watch(newChallengesProvider);
            return ChallengeList(
              challenges: newChallenges,
              isLoading: challengeState.isLoading,
            );
          },
        ),
      ],
    );
  }

  FloatingActionButton _buildCreateButton() {
    return FloatingActionButton.extended(
      onPressed: () {
      },
      icon: const Icon(Icons.add),
      label: const Text('Create Challenge'),
    );
  }

  BottomNavigationBar _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          activeIcon: Icon(Icons.search),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline),
          activeIcon: Icon(Icons.favorite),
          label: 'Saved',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}