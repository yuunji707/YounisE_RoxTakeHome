# Rox Take Home

## Demo
[Screen Recording](https://drive.google.com/file/d/1vCQsU8uM_k9ZEktfQK1I0CpE8oG3vkOh/view?usp=sharing)

## Setup
1. Open `RoxTakeHome.xcodeproj` in Xcode
2. Build and run (iOS 17+)

## Architecture
MVVM with protocol abstractions and dependency injection. Views observe ViewModels, ViewModels coordinate with Repositories, and Repositories use Services for networking and persistence. Protocols define contracts between layers for testability. A `DependencyContainer` creates and injects shared instances to keep state consistent across screens.

## Features
- News feed with search and category filtering
- Article detail view with share functionality
- Favorites with persistent storage and sorting options
- Pagination, pull-to-refresh, image caching, skeleton loading states, error handling with recovery suggestions

## Shortcuts
- API key is hardcoded — should use environment variables or keychain in production
- Using URLCache for images — a dedicated library like Kingfisher would offer better memory management
- No unit tests — protocols are in place to support mocking

## Challenges
Favorites weren't syncing between tabs because multiple `FavoritesRepository` instances were being created. Fixed by injecting a single shared instance via `DependencyContainer`.

## Tools
Claude was used for code review and refinement.
