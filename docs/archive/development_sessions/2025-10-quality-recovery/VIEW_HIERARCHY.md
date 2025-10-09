# View Hierarchy & Navigation - iOS/macOS

**Project**: [Project Name]
**Platform**: [iOS / macOS / watchOS / tvOS]
**UI Framework**: [SwiftUI / UIKit / AppKit]
**Last Updated**: [YYYY-MM-DD]
**Total Views**: [Number]
**Status**: [ ] Draft / [ ] Complete / [ ] Validated

---

## 1. App Entry Point

### Initial View on Launch
```
App Launch
  ↓
SplashView (0.5s)
  ↓
if authenticated:
    → ContentView (Tab Bar)
else:
    → WelcomeView → LoginView
```

**Files**:
- `[ProjectName]App.swift` - App entry point
- `SplashView.swift` - Splash screen
- `ContentView.swift` - Main container

---

## 2. Tab Bar Structure (Main Navigation)

### Tab Configuration

| Tab # | Icon | Label | Root View | File Path |
|-------|------|-------|-----------|-----------|
| 1 | house.fill | Home | HomeView | Views/Home/HomeView.swift |
| 2 | magnifyingglass | Search | SearchView | Views/Search/SearchView.swift |
| 3 | plus.circle | Create | CreateView | Views/Create/CreateView.swift |
| 4 | person.fill | Profile | ProfileView | Views/Profile/ProfileView.swift |
| 5 | gear | Settings | SettingsView | Views/Settings/SettingsView.swift |

---

## 3. Navigation Stacks

### Home Tab Navigation Stack
```
HomeView (NavigationStack root)
├─ CategoryListView (NavigationLink push)
│  └─ CategoryDetailView (NavigationLink push)
│     ├─ ItemDetailView (NavigationLink push)
│     │  └─ ItemEditView (sheet presentation)
│     └─ RelatedItemsView (NavigationLink push)
└─ FeaturedContentView (NavigationLink push)
```

**Files**:
- `Views/Home/HomeView.swift`
- `Views/Home/CategoryListView.swift`
- `Views/Home/CategoryDetailView.swift`
- `Views/Home/ItemDetailView.swift`
- `Views/Home/ItemEditView.swift`

### Search Tab Navigation Stack
```
SearchView (NavigationStack root)
├─ SearchResultsView (inline display)
└─ FilterOptionsView (sheet presentation)
```

### Profile Tab Navigation Stack
```
ProfileView (NavigationStack root)
├─ EditProfileView (NavigationLink push)
├─ FollowersListView (NavigationLink push)
├─ FollowingListView (NavigationLink push)
└─ AchievementsView (NavigationLink push)
```

---

## 4. Modal Presentations

### Sheet Presentations (.sheet modifier)

| Parent View | Presented View | Trigger | Binding | Dismissal |
|-------------|----------------|---------|---------|-----------|
| HomeView | ShareSheet | Share button | @State isShowingShare | User swipe down |
| ItemDetailView | ItemEditSheet | Edit button | @State isEditing | Save or Cancel |
| SettingsView | ThemePickerSheet | Theme row tap | @State showingTheme | Selection made |
| ProfileView | EditProfileSheet | Edit button | @State isEditingProfile | Save or Cancel |

### Full Screen Covers (.fullScreenCover modifier)

| Parent View | Presented View | Trigger | Purpose |
|-------------|----------------|---------|---------|
| ContentView | OnboardingFlow | First launch | New user onboarding |
| ContentView | LoginView | Not authenticated | Force authentication |
| HomeView | CameraView | Camera button | Full screen camera |

### Alert Dialogs (.alert modifier)

| Parent View | Alert Type | Trigger | Actions |
|-------------|------------|---------|---------|
| ItemDetailView | DeleteConfirmation | Delete button | [Cancel, Delete] |
| SettingsView | LogoutConfirmation | Logout button | [Cancel, Logout] |
| ProfileView | ErrorAlert | API error | [OK] |

---

## 5. State Management

### App-Level State (@EnvironmentObject)

| State Object | Type | Purpose | File Path |
|--------------|------|---------|-----------|
| AuthenticationManager | ObservableObject | User auth state | Managers/AuthenticationManager.swift |
| UserProfileManager | ObservableObject | User data | Managers/UserProfileManager.swift |
| ThemeManager | ObservableObject | App theme/appearance | Managers/ThemeManager.swift |
| NetworkMonitor | ObservableObject | Network status | Managers/NetworkMonitor.swift |

### View-Level State (@StateObject)

| View | ViewModel | Purpose | File Path |
|------|-----------|---------|-----------|
| HomeView | HomeViewModel | Home data & logic | Views/Home/HomeViewModel.swift |
| SearchView | SearchViewModel | Search functionality | Views/Search/SearchViewModel.swift |
| ProfileView | ProfileViewModel | Profile management | Views/Profile/ProfileViewModel.swift |

### View-Local State (@State)

| View | State Variables | Purpose |
|------|-----------------|---------|
| ItemDetailView | @State isEditing | Edit mode toggle |
| HomeView | @State searchText | Search input |
| SettingsView | @State selectedTheme | Theme selection |

---

## 6. Deep Linking

### URL Scheme Configuration
**Scheme**: `[appname]://`
**Info.plist**: CFBundleURLTypes configured

### Supported Deep Links

| URL | Destination View | Parameters | Example |
|-----|------------------|------------|---------|
| myapp://home | HomeView | none | myapp://home |
| myapp://item/:id | ItemDetailView | id (UUID) | myapp://item/abc-123 |
| myapp://search?q= | SearchView with query | q (string) | myapp://search?q=swift |
| myapp://profile/:id | ProfileView | id (string) | myapp://profile/user123 |
| myapp://settings/theme | SettingsView (theme section) | none | myapp://settings/theme |

### Universal Links (https://)
**Associated Domain**: example.com
**App Links**:
- https://example.com/item/:id → ItemDetailView
- https://example.com/user/:id → ProfileView

---

## 7. View Lifecycle & Data Flow

### Critical Lifecycle Events

| View | Event | Action | Trigger |
|------|-------|--------|---------|
| HomeView | .onAppear | Fetch latest data | View appears |
| HomeView | .onDisappear | Save scroll position | View disappears |
| ItemDetailView | .task | Load item details | Async on appear |
| SearchView | .onChange(searchText) | Perform search | Text changes |
| SettingsView | .onReceive(NotificationCenter) | Handle settings change | Settings updated |

### Data Fetching Patterns
```swift
// HomeView
.task {
    await viewModel.fetchHomeData()  // On appear
}

// SearchView
.onChange(of: searchText) { newValue in
    viewModel.performSearch(query: newValue)  // Debounced
}

// ItemDetailView
.refreshable {
    await viewModel.refresh()  // Pull to refresh
}
```

---

## 8. Navigation Transitions

### Standard Transitions
- **Push**: NavigationLink (slides from right)
- **Sheet**: .sheet (slides up from bottom)
- **Cover**: .fullScreenCover (full screen replacement)

### Custom Transitions
```swift
// Fade transition
.transition(.opacity)

// Scale transition
.transition(.scale)

// Combined transition
.transition(.asymmetric(
    insertion: .move(edge: .trailing),
    removal: .opacity
))
```

---

## 9. Validation Checklist

View Documentation Completeness:

- [ ] All views documented (100% coverage)
- [ ] All navigation stacks mapped
- [ ] All modal presentations listed
- [ ] State management explained (global + view-level)
- [ ] Deep links documented
- [ ] Lifecycle events defined
- [ ] Navigation flows documented (min 3)
- [ ] View files mapped to components
- [ ] Entry point documented
- [ ] Error handling views included
- [ ] Last updated within 7 days

**Minimum Completeness**: 9/11 items (82%)

---

## 10. Maintenance

### Auto-Generate Command
```bash
# Scan Swift files for views and generate hierarchy
python3 ~/.claude/hooks/auto_sitemap_generator.py --type ios --output docs/VIEW_HIERARCHY.md
```

### Validation Command
```bash
python3 ~/.claude/hooks/sitemap_structure_validator.py docs/VIEW_HIERARCHY.md ios
```

**Template Version**: 1.0
**Last Modified**: 2025-10-02