# CLAUDE.md

Permanent project rules. Follow them whenever generating, modifying, or refactoring code in this project.

## Project Overview

A Flutter Web admin dashboard for the Zuno platform. Planned areas include the Users module, Aadhaar upload cards, and banners.

The repository currently holds the design system in `lib/core/theme/` and `lib/core/utils/`, the admin login screen in `lib/features/auth/`, and the dashboard and user list in `lib/features/dashboard/` and `lib/features/user_management/`, which use temporary mock data. The sidebar and top bar shell is in `lib/core/widgets/admin_shell/`. Routes are in `lib/core/navigation/app_routes.dart`: `/` is login, `/dashboard` is the dashboard (`lib/features/dashboard/`; the header's `DateRangeDropdown` (Today by default, Yesterday, Last 7 / 30 Days, All Dates, Custom Date Range, which shows start and end `AppDateField`s) sets one `DateRangeFilter` that filters every section; `DashboardRepository`, a lazy singleton, caches each section per date range for 5 minutes and refetches early when `DataRevision` (`lib/core/data/data_revision.dart`) changes, which `UsersRemoteDataSource` writes and `addAdminRecharge` bump; Top-up Revenue sums `rechargeAmount` on completed `recharge` transactions (gateway and admin) by `createdAt`, Total Admin Revenue is that minus `gstAmount`; for a dated range Total Users / Hosts count non-deleted sign-ups by `createdAt` and `role`, Deleted Users / Hosts and Deleted Account Profit (sum of `walletBalance`) use `deletedAt` (written by admin delete; the user app must write it on Delete Account), and the free bonus figures add welcome bonuses by `welcomeBonusClaimedAt` / `welcomeBonusAmount` (user app) to `amountFromOffer` on completed admin recharges, counting a user who got both once; All Dates uses all-time counts, `walletBalance` on every deleted account and the `walletSources.bonus` ledger; records written before those date fields existed appear only under All Dates; Recent Recharge Activity shows the latest 5 completed recharges in the range with their users joined by ID; the call revenue and call statistics tiles are still mock data), and `/users` is User Management, and `/users/details` is User Details (`lib/features/user_details/`), opened with the `AdminUser` as the route argument, and `/hosts` is Host Management's Host List (`lib/features/host_management/`), and `/hosts/details` is Host Details (`lib/features/host_details/`), opened with `HostDetailsArguments`, and `/hosts/surge-sessions` is Surge Charge Sessions (`lib/features/surge_charge_sessions/`), and `/calls` is Calls (`lib/features/calls/`; lists the root Firestore `calls` collection written by the calling app's Cloud Functions (`customerId`, `customerName`, `customerUserId`, `hostId`, `hostName`, `hostUserId`, `callType` `audio` / `video`, `status` `ringing` / `accepted` / `ongoing` / `completed` / `rejected` / `cancelled` / `missed` / `failed`, `createdAt`, `startedAt`, `endedAt`, `durationSeconds`, `coinsCharged`, `amountCharged`, `hostEarning`, `platformEarning`, `insufficientBalance`, `endedBy`, `endReason`); browsing loads 10 at a time by newest `createdAt` through `CursorPager`, with the date (Today by default, Yesterday, Last 7 / 30 Days, custom), call and type filters in the Firestore query (composite indexes in `firestore.indexes.json`) and a count query for Total Calls; the call filter maps Completed, Rejected and Busy to that `status`, Not Answered to `missed`, Missed to `cancelled` (caller hung up while ringing) and Low Balance to `insufficientBalance`; the debounced search (user or host name, user mobile, host ID) downloads the selected date range once, joins `users` by `customerId` for the phone, and pages through the matches locally), and `/calls/details` is Call Details (`lib/features/call_details/`), opened with the `CallLog` as the route argument, and `/approval` is Approval (`lib/features/approval/`; the Host Requests, Payout Review and Profile Photo Review tabs are built, and the Approval sidebar sub-items switch tabs through `AdminShell.onSubItemSelected`; Host Requests lists Firestore `users` documents whose `hostDetails.hostStatus` is `submitted`, each Aadhaar Front, Aadhaar Back and Selfie field is reviewed individually, the sheet's main Approve button appears only once all three are approved and its Reject button also appears as soon as any document is rejected or missing (`HostRequest.canApprove` / `canReject`, enforced again in `UserRecord.hostRequestDecision`), main Reject sets `hostDetails.hostStatus` to `rejected`, main Approve sets `hostDetails.hostStatus` to `approved` and `role` to `host` in one transaction; only after that succeeds, `ApprovalRepository` re-reads the user and, unless `avatharImage` is a custom picture (any URL outside the Storage folders `users_avathar` / `host_avathar`, which the calling app also picks from at sign-up), gives a `hostDetails.gender` `male` host a random `users_avathar` image and a `female` host a random `host_avathar` image through `AvatarStorageRemoteDataSource` (avoids the current and recently assigned avatars, checks the download URL), written to `avatharImage` in a guarded transaction with no audit entry (`isAvathar` / `avatharStatus` are set only when the user had no avatar status); other or missing genders, empty folders and Storage errors leave the picture unchanged and never fail the approval; Profile Photo Review lists `users` documents whose `isAvathar` is false and `avatharStatus` is `submited` with a valid `submitedImageUrl` (these misspellings are the real Firestore field names and value, centralized in `UserRecord`), Accept sets `avatharStatus` to `approved` and `avatharImage` to the reviewed URL, Reject sets `avatharStatus` to `rejected`, each in one transaction with a local state update and no refetch; approving a host request sets `hostDetails.approvedAt` and `hostDetails.approvedBy`, and accepting a photo sets `avatarApprovedAt` and `avatarApprovedBy`, using a server timestamp and the signed-in admin's UID, only when no approval date exists yet; every host document review, host decision and photo decision also writes an `approvalAuditLogs` entry in the same transaction through `lib/core/data/approval_audit.dart`; Payout Review lists `bankAccounts` documents whose `bankAccountStatus` is `submitted`, each document ID being the user's ID, joined to `users` by ID, and approving re-reads the signed-in admin's `admin` document (by email) and requires the Approval module (super admins have all modules), then sets `bankAccountStatus`, `adminApprovedAt` and `adminApprovedBy` in one transaction that refuses a changed account; all three tabs load 10 records at a time from Firestore with cursors, newest `updatedAt` first, through `lib/core/data/record_page.dart`, search with a 450 ms debounce on the normalized `searchKeywords` array built by `lib/core/data/search_keywords.dart` (mirrored in `tool/backfill_search_keywords/backfill.js`, so change both together), require the composite indexes in `firestore.indexes.json`, and cache pages in `ApprovalPager`), and `/reports` is Reports (`lib/features/reports/`; lists the root Firestore `reports` collection written by the calling app's `hideCallHistory` callable (document ID `{callId}_{reporterId}`; `reportedBy` / `reported` user document IDs, `reporterRole` `user` / `host` (older reports without it are worked out from `reportedBy` == `hostId`), `reportType` (`askingPersonalDetails`, `offensiveLanguage`, `inappropriateBehavior`, `requestingPersonalDetails`, `notResponding`, `moneyRequests`, `other`; unknown values show as Other), `reportDetails`, `reportedByName`, `reportedName`, `reportedByPhone` / `reportedPhone` (country code and number in one string), `receivedReportCount` (that reporter's reports against that person, not shown), the root `reportedUsers/{reportedId}` document (`totalReceivedCount`, every report the person received from anyone, and `lastReportedAt`; written only by `hideCallHistory` in the same transaction as each new report, started from that person's existing reports the first time, and created for older data by `tool/backfill_report_totals/` (dry run by default, `--write` to apply, only creates missing totals); the Received Total Report Count column shows it, read fresh for every loaded page with one `whereIn` query on the page's reported people, `—` when a person has no total), `reportedAt`, plus the call's `callId`, `callType`, `customerId`, `customerName`, `customerUserId`, `hostId`, `hostName`, `hostUserId` and avatars); browsing loads 10 at a time by newest `reportedAt` through `CursorPager`, with the date (All Dates by default), report type and reporter filters in the Firestore query (composite indexes in `firestore.indexes.json`) and a count query for the footer total; like Calls, `ReportsCubit` loads fresh data each time the page opens and resets its one `CursorPager` and count whenever a filter or the search changes (there is no refresh button); search (debounced, at least 2 characters) runs "starts with" range queries from `ReportSearch` (names as typed, lowercase and capitalized on `reportedByName` / `reportedName`, uppercase user ID on `customerUserId` / `hostUserId`, or for phone-like text the digits with and without `+` / `+91` on the phone fields; up to 50 results each), merges them, and applies the date, type and reporter filters and paging locally; `ReportsRepository` (a factory, so its cache lasts one page visit) caches each term's results and, when an earlier term's results were complete and cover the new term, narrows them locally instead of querying again), and `/packages` is Packages (`lib/features/packages/`; only the Package List tab is built; it lists 10 at a time by ascending `rechargeAmount` through `CursorPager`, with count queries for the summary, and adds and edits documents in the Firestore `packages` collection, whose fields are `coins`, `createdAt`, `updatedAt`, `offerPercentage`, `offerTag`, `packageStatus` (`active` / `inactive`; the user app shows only active packages), `rechargeAmount`, `receivableAmount` and `isGstEnabled`, and `tool/migrate_packages/` migrates older documents to that schema; amounts are doubles limited to 2 decimal places through `DecimalInputFormatter` and shown with 2 decimals by `NumberFormatter.rupeesAmount` / `groupedAmount`; Receivable Coin is read-only, a whole number, and always receivable amount × `PackagePlan.coinsPerRupee` (15) rounded to the nearest coin), and `/recharge` is Recharge (`lib/features/recharge/`; lists the Firestore `transactions` collection, whose documents have random Firestore IDs (gateway payments are looked up by `razorpayOrderId`) and exactly these fields on every document: `userId`, `type` (`recharge` / `adminCredit` / `adminDebit`), `status` (`pending` / `success` / `failed`, shown as Created / Completed / Failed), `packageId`, `isRechargedByAdmin` (true for admin recharges, credits and debits), `rechargeAmount` (the package's `rechargeAmount`, GST included, on gateway and admin recharges), `adminCreditAmount`, `adminDebitAmount`, `gstAmount`, `amountFromOffer` (`offerPercentage` of `rechargeAmount - gstAmount`), `receivedTotalAmount` (what reached the wallet: `rechargeAmount - gstAmount + amountFromOffer` for recharges, the amount for credits, 0 for debits and until credited), `currency` (`INR`), `razorpayOrderId`, `razorpayPaymentId`, `failureReason`, `adminUid`, `description`, `createdAt`, `creditedAt` (null until credited and on debits); unused fields are null or 0; coins are not stored and are `receivedTotalAmount` (or the debit amount) × 15; `tool/clear_transactions/` backs up and deletes the whole collection, joined to `users` by `userId` for name and phone; browsing loads 10 at a time with cursors through `CursorPager`, with the date, status and source filters in the Firestore query (admin versus gateway recharges are separated in the app), while the debounced search (name, phone, recharge amount, order or payment ID) downloads the selected date range once and pages through the matches locally; documents with a `razorpayOrderId` are gateway payments and the others admin recharges, and `adminCredit` / `adminDebit` types are admin credit and debit; the stat cards total completed transactions with Firestore count and sum queries on `rechargeAmount`, `adminCreditAmount` and `adminDebitAmount` and follow the date filter only), and `/payment` is Payment (`lib/features/payment/`; lists the root Firestore `hostPayouts` collection, one document per host per payout cycle with the ID `{hostId}_{cycle}` (`hostId`, `cycle`, `withdrawId` `WD-{userID}-{cycle}`, `status` `pending` / `success`, `callCount`, `callDurationSeconds`, `callEarnings` (base host earnings), `surgeEarnings`, `adminCreditAmount`, `adminDebitAmount`, `bonusAmount` (always 0 for now), `totalAmount` (the payable sum), `hostName`, `hostUserId`, `hostCountryCode`, `hostPhoneNumber`, `createdAt`, `updatedAt`, and once paid `paidAt`, `paidBy`, `tdsPercent`, `tdsAmount`, `receivableAmount` and a `bankAccount` snapshot); amounts are rupee doubles; the records are written only by the calling app's Cloud Functions (`functions/payouts/`): call settlement adds each paid call to the host's pending record, and `adjustHostEarnings` (Host Details Credit / Debit Wallet, admin `hostManagement` module, refuses a debit above the pending total) adds admin credits and debits, both through `applyPayoutDelta`, which reads `users/{hostId}.hostDetails.pendingPayoutId` from the host document the transaction already holds and creates the next cycle's record (bumping `hostDetails.payoutCycle`) when there is none, so a host has at most one pending record and paid records are never written again; `completeHostPayout` (the Withdraw review dialog, admin `payment` module) checks the record is still pending with the reviewed amount, at least `settings/app.minimumPayoutAmount` and has an approved `bankAccounts` document, then marks it `success`, clears the host's `pendingPayoutId` and writes a `host_payout` `ledger` entry in one transaction; the Pending tab lists pending records with `totalAmount` at or above the minimum (a missing or invalid minimum counts as none) largest first, the Success tab lists paid records newest `paidAt` first, and the Withdrawal List tab shows both in that order, 10 at a time through `CursorPager`, with one count / sum aggregation for the overview card and tab counts; pending rows join the host's approved `bankAccounts` document by ID; the debounced search uses the host search (`UsersRemoteDataSource.searchUsers`) and each host's `pendingPayoutId`, or an exact `withdrawId`, and pages locally; paying updates the lists locally; TDS is 2% (`PayoutSettings.tdsPercent`, mirrored by `PAYOUT_TDS_PERCENT` in the calling app); Export Withdrawal Sheet shows an Export complete dialog without creating a file yet), and `/settings` is Settings (`lib/features/settings/`; the Maintenance Mode, Admin Management, Notification Management and Banner Image Management tabs are built; banners are stored in the single Firestore document `settings/bannerImages` as map fields keyed by banner ID (each map has `role` (`user` / `host`), `screen` (`home` / `recharge`, modelled by `BannerScreen`; a missing `screen` means `home`), `createdAt`, `status` (`active` / `inactive`), `imageName`, `imageUrl`) loaded and added through `BannerImagesRemoteDataSource`; Add Banner and the Add banner image tile first open an options menu (Home Banner / Recharge Banner), then the add dialog for that screen, whose subtitle names the screen and whose User / Host switch offers only User for recharge banners because hosts have no recharge screen (`BannerScreen.audiences`); the calling app's `BannerSlider` shows only active banners whose `screen` and `role` match it (user and host Home, user Recharge on the coin package page); the dialog picks a PNG or JPG of up to 5 MB from the gallery with `image_picker`, uploads it to Firebase Storage at `bannerImages/{role}/{documentId}.{ext}`, then merges the banner's map field into that document (the uploaded file is removed if the write fails); Delete asks for confirmation, then removes the banner's field and its Storage file (a failure shows a snackbar); the maintenance switch asks for confirmation, then writes `isMaintenanceMode` to the Firestore `settings/app` document (merged, with `updatedAt`) through `SettingsRemoteDataSource`, and shows a top-bar badge through `AdminShell.topBarNotice` on the Settings page only; the Maintenance Mode tab also edits `settings/app.minimumPayoutAmount` (rupees, 2 decimals, read with the maintenance flag in one `fetchGeneralSettings` read; parsed by `PayoutSettings` in `lib/core/data/payout_settings.dart`), the minimum pending total for a host to appear on the Payment page; `settings/app` also holds `appVersion` (`android` / `ios` maps with `minimumVersion`, `currentVersion`, `minimumBuildNumber`, `currentBuildNumber`, `forceUpdate`, `storeUrl`, plus `updateMessage`), which `tool/seed_settings/` creates without overwriting existing values; `settings/app` also holds `setHostPrice`, a map with `audio` and `video` maps, each with per-minute `adminAmount` and `hostAmount`, and a `message` map with only `adminAmount` (rupee doubles, 2 decimals; saving deletes any old `message.hostAmount`), modelled by `HostPricing` in `lib/core/data/host_pricing.dart` for reuse by the calling, wallet and messaging modules, edited in Host Management's Set call & message price dialog (Admin / Host tabs) through `CallPricingCubit` and `SettingsRepository`, merged into the document on save, and seeded with zeros by `tool/seed_settings/`; `setHostPrice.surgeCharge` is a list of maps (`sessionName`, `startTime` / `endTime` as Firestore Timestamps whose time of day is the daily window, stored on the date the times were last changed with the end moved to the next day for overnight sessions, untouched entries keeping their stored Timestamps, older whole-minute values still read, `surgeCharge` as a whole-number percent, `status` `enabled` / `disabled`) mapped by `SurgeSession`, listed and edited on the Surge Charge Sessions page through `SurgeSessionsCubit` and `SettingsRepository`; every add, edit, delete or status toggle merges the whole list into `settings/app` in one write (other `setHostPrice` fields are untouched) and updates the page without a refetch; list position is the entry's identity, there is no stored ID; Add admin and Edit open the admin side sheet and save to the Firestore `admin` collection through `lib/core/data/admins_remote_data_source.dart` (random Firestore document ID, looked up by the lowercased `email` field, which must stay unique; fields `name`, `email`, `phoneNumber`, `role` (`AdminRole` name), `permissions` (`AdminNavItem` names), `createdAt`, `updatedAt`), and only super admins see Add admin and Edit; every module route is wrapped in `AdminAccessGate` for its `AdminNavItem`, the sidebar lists only the signed-in admin's permitted modules through the app-wide `AdminSessionCubit`, Add admin also takes a password (at least 6 characters, Firebase Auth's minimum) and creates the Firebase Auth email/password login through a separate non-persisted Firebase app so the current admin stays signed in (an email that already has a login keeps its password); sign-in admits any account with an `admin` document that has at least one module, and the `admin` claim is only needed for the first admin, the first claimed admin to sign in while the collection is empty becomes a super admin automatically; the notification audience counts come from Firestore `users` documents that are not deleted (count by `role` minus those with `isAccountDeleted` true), with hosts optionally narrowed by `hostDetails.motherTongue`, and the mother tongue selection is cleared when Send to is User; Send notification validates the form and opens a confirmation dialog, and Send now calls the `sendAdminNotification` callable Cloud Function (`functions/`, codebase `admin`, region `asia-south1`) through `NotificationsRemoteDataSource`; the function checks the caller has an `admin` document with the `settings` permission and sends to FCM topics instead of querying `users`: `users_all` for users, `hosts_all` for all hosts, or one `hosts_{code}` topic per selected mother tongue (`hosts_en`, `hosts_ml`, `hosts_ta`, `hosts_hi`, `hosts_kn`, `hosts_te`, mapped from the `HostLanguage` names in `functions/src/topics.js`, mirrored in the calling app's `functions/src/topics.js` and `fcm_topics.dart`, so change all three together), combining topics into FCM conditions of at most 5 so a device subscribed to several gets one message; each device's topics are kept in sync by the calling app's single `onUserWritten` trigger on `users/{uid}` (`syncUserTopics`: none when deleted or blocked, `users_all` for users, `hosts_all` plus the `hostDetails.motherTongue` topic for hosts, moved when `fcmToken` changes), backed up by the app's own sign-in and logout sync, and `functions/scripts/backfill_fcm_topics.js` there subscribes existing tokens once; admin sends are not stored in Firestore (only logged); the root `notifications` collection holds per-user app notifications (`userId`, `title`, `body`, `type`, `isRead`, `createdAt`, `data`), written only by the calling app's Cloud Functions, never by the dashboard: Add Recharge creates `admin_recharge` inside `addAdminRecharge`, Credit / Debit Wallet on User Details creates `admin_credit` / `admin_debit` through the calling app's `onTransactionCreated` trigger on the `transactions` document, and approving a host request creates `host_approved` through its `onUserWritten` trigger (the `userId` + `createdAt` index is in both repos' `firestore.indexes.json`), and the success dialog lists the topics sent to; the Settings sidebar sub-items switch tabs). The sidebar navigates to any `AdminNavItem` or `AdminSubNavItem` that has a route; a selected item's sub-items show beneath it. Editing, blocking, and deleting a user or host use the shared `AppActionMenu` / `AppTakeActionButton`, plus the side sheet, confirm dialog, and success dialog from `lib/core/widgets/`. Add Recharge on User Details lists the active Firestore `packages` and calls the `addAdminRecharge` Cloud Function (in the calling app's `functions/index.js`), which checks the caller's `admin` document, re-reads the package and, in one transaction, adds `receivedTotalAmount` to `walletBalance`, the amount without GST to `walletSources.adminRechargeAmount` and the offer to `walletSources.bonus`, and creates a `transactions` document with `isRechargedByAdmin: true` and the package cost in `rechargeAmount`, whose random Firestore ID is generated per confirmation so a repeat is applied once; gateway recharges have `isRechargedByAdmin: false`. The Total Recharge and Available Coins cards on User Details are calculated from all of the user's completed `transactions` through `UserRechargeSummary`: Total Recharge sums `rechargeAmount` on recharges, and Available Coins is currently the total Received Coins (recharges and admin credits minus admin debits), while the Credit / Debit Wallet limit still uses `walletBalance`. Credit / Debit Wallet on User Details changes the user's `walletBalance` and adds to `walletSources.adminCredit` or `walletSources.adminDebit` and creates a `transactions` document with the full schema (`type` `adminCredit` / `adminDebit`, `status` `success`, `isRechargedByAdmin: true`, `adminCreditAmount` or `adminDebitAmount`, `receivedTotalAmount`, `description`, `adminUid`, `createdAt`, `creditedAt` on credits) in one transaction that refuses a debit above the current balance; the same dialog on Host Details calls `adjustHostEarnings`, which changes the host's pending `hostPayouts` record (see Payment) and writes a `host_admin_credit` / `host_admin_debit` `ledger` entry; Host Details' Withdrawal History tab lists the host's `hostPayouts` newest `createdAt` first, its Wallet History tab lists the host's `ledger` entries (`uid` is the host's document ID; `call_earning`, `host_admin_credit`, `host_admin_debit`, `host_payout`; zero amounts are skipped), both loading 10 at a time when the tab first opens, and its stat cards come from two aggregations on the host's `hostPayouts` plus `hostDetails.lifetimeEarningsPaise`. The Recharge History tab on User Details lists the selected user's Firestore `transactions` (always filtered by `userId`), 10 at a time with cursors, newest `createdAt` first, loading only when the tab first opens; `RechargeSearch` turns the search text into an exact amount (`rechargeAmount`, `adminCreditAmount` or `adminDebitAmount`), `razorpayOrderId` or `razorpayPaymentId` match, a `status` query, a document ID lookup, or an in-app payment method check. The Call History tab on User Details and Host Details lists the root `calls` documents whose `customerId` (user) or `hostId` (host) is that `users` document ID, through the shared `CallHistoryCubit` and `CallHistoryPanel` in `lib/features/calls/` (`CallParticipant` picks the field), 10 at a time with cursors through `CursorPager`, newest `createdAt` first, loading with the page; the All / Audio / Video filter (`callType`) and the date filter (Single Date, today by default, or Date Range, yesterday to today by default) are in the Firestore query (the `customerId` / `hostId` + `createdAt` and + `callType` + `createdAt` indexes are in `firestore.indexes.json`), a count query gives the filtered total shown in the filter bar and footer, and another gives the tab badge's all-time total; the user table shows the host's per-minute rate as Host Revenue, like the Calls list, and the host table shows the call's `hostEarning`. Sign-in uses Firebase email/password through `lib/features/auth/` and only admits accounts with the `admin` custom claim, which `tool/create_admin/` grants, and the top-bar profile chip opens a Logout menu; User Management and Host Management list real records from the Firestore `users` collection by `role` through `lib/core/data/`, 10 at a time with cursors through `lib/core/data/cursor_pager.dart`, newest `createdAt` first, with search and filters in the Firestore query (search is a "starts with" match on the name (`hostDetails.userName` for hosts, top-level `userName` for users; lowercase or as typed), `userID` (uppercase) or `phoneNumber` (digits, also the last 10 digits): `UsersRemoteDataSource.searchUsers` runs one range query per prefix from `lib/core/data/user_search.dart` (up to 100 results each) with the status filters, merges and sorts them newest `createdAt` first, and the repositories page through them locally with `LocalPageCursor`; this needs the `role` + filter fields + searched field composite indexes in `firestore.indexes.json`; `searchKeywords` is no longer used by these two lists), and their edit, block, unblock and delete actions update those documents by ID, with delete being a soft delete (`isAccountDeleted` plus `deletedBy: "admin"`); the other modules are not built yet.

Architecture: feature-based, inspired by Clean Architecture, **with no Domain layer and no abstract repository interfaces**.

| Concern | Choice |
| --- | --- |
| Structure | Feature folders plus a shared `lib/core/` |
| State management | Cubit (`flutter_bloc`) |
| Dependency injection | GetIt |
| Error handling | `fpdart` |
| Backend | Firebase, reached through Firebase Cloud Functions (future) |

`flutter_bloc`, `get_it` and `fpdart` are in `pubspec.yaml`.

## Flutter and Dart Version

The project uses **Flutter 3.47.7** (bundled Dart SDK 3.13.5; `pubspec.yaml` constraint `sdk: ^3.13.5`). Run it with the global `flutter` command; FVM is not used.

- Always write code compatible with Flutter 3.47.7 and its bundled Dart SDK.
- Do not use deprecated APIs when a supported alternative exists.
- Do not use APIs, packages, or language features incompatible with the project's SDK version.
- Inspect the `pubspec.yaml` SDK constraints before making dependency changes.
- Never upgrade or downgrade Flutter or Dart.
- Preserve the existing project configuration.

## Project Structure

```text
lib/
├── main.dart                     # flavorMain(Environment): flavor setup, then app start
│
├── core/
│   ├── app_environment/          # config/ (FlavorConfig, Firebase options), entry_point/ (main_staging, main_production)
│   ├── enums/                    # Shared enums, including AppStatus
│   ├── resources/                # images/, icons/, strings/, other shared resources
│   ├── di/                       # All GetIt registration
│   ├── navigation/               # All route configuration
│   ├── theme/                    # app_colors, app_text_styles, app_theme, theme_utils
│   ├── errors/                   # Failure types
│   ├── utils/                    # Reusable helpers, including app_utils
│   └── widgets/                  # Application-wide reusable widgets
│
└── features/
    └── {module_name}/            # One folder per dashboard module, for example users/
        ├── data/
        │   ├── datasources/
        │   ├── models/
        │   └── repositories/
        └── presentation/
            ├── pages/
            ├── state/            # Cubits and states
            └── widgets/          # Feature-specific widgets
```

Additional subfolders are fine for organizing resources. Do not add unnecessary folders or layers.

## Entry Point and Environments

The app is Flutter Web only. Two web entry points exist, one per environment. Each calls `flavorMain(Environment.<flavor>)`:

| Environment | Entry point | Firebase |
| --- | --- | --- |
| `staging` | `lib/core/app_environment/entry_point/main_staging.dart` | `suno-staging-aaa4d`, configured by `lib/core/app_environment/config/firebase_options_staging.dart` |
| `production` | `lib/core/app_environment/entry_point/main_production.dart` | None yet; does not initialize Firebase |

`lib/main.dart` has no `main()` function, so always pass the entry point with `-t`. Flutter web does not support `--flavor`:

```bash
flutter run -d chrome -t lib/core/app_environment/entry_point/main_staging.dart
flutter run -d chrome -t lib/core/app_environment/entry_point/main_production.dart
flutter build web --release -t lib/core/app_environment/entry_point/main_staging.dart
flutter build web --release -t lib/core/app_environment/entry_point/main_production.dart
```

Responsibilities:

- **Entry points** call `flavorMain(Environment.<flavor>)`.
- **`lib/main.dart`** receives the environment, initializes `FlavorConfig`, registers dependencies with `configureDependencies()`, and calls `runApp`.
- **`FlavorConfig`** (`core/app_environment/config/flavor_config.dart`) performs per-environment setup. Only `staging` initializes Firebase.

Rules:

- Never change the environment configuration unless explicitly requested.
- Do not assume or invent environment names or configurations beyond those above.

## 1. Architecture Rules

- Always follow the established feature-based architecture.
- Shared functionality belongs inside `lib/core/`.
- Feature-specific functionality belongs inside `lib/features/{module_name}/`.
- Add each dashboard module as its own feature folder, for example `lib/features/auth/`.
- Never create a Domain layer.
- Never create abstract repository interfaces.
- Never introduce unnecessary layers or abstractions, or architectural patterns that conflict with this structure.
- Avoid putting feature-specific code inside `core/`.
- Do not change the established architecture without explicit permission.

## 2. Data Flow Rules

The data flow must strictly follow:

```text
UI (Pages / Widgets)
        ↓
Cubit
        ↓
Repository (Concrete implementation)
        ↓
DataSource
        ↓
Firebase Cloud Functions
```

### Presentation

- Pages and widgets are responsible for displaying UI.
- Cubits manage presentation state and coordinate operations.
- Widgets must not directly access repositories or data sources.
- Pages must not directly perform backend operations.
- Keep UI and backend responsibilities separate.

### Repository

- Contains feature-specific data coordination and business-related data operations.
- Communicates with the appropriate data source.
- Handles mapping between data sources and presentation-facing models where appropriate.
- Uses concrete classes only. Do not create repository interfaces or abstract repository classes.

### DataSource

- Handles communication with external services.
- Future Firebase Cloud Functions integrations must be implemented here.
- Keep backend-specific implementation details inside data sources.
- Do not put Firebase-specific code inside presentation widgets or Cubits.

### Current Development Stage

The project is in its **UI development stage**. Unless explicitly requested, do not create:

- Firebase backend implementations.
- Cloud Functions.
- API integrations.
- Backend-dependent functionality.
- Firestore collections or database structures.

For UI-only development, use temporary presentation states or mock data only when explicitly needed. Do not introduce backend abstractions just to support UI development.

## 3. State Management Rules

Use `flutter_bloc` with Cubit.

- Use Cubit for feature-level state management.
- Keep state management inside `presentation/state/`.
- Keep Cubits focused on their respective features.
- Do not put UI logic inside repositories.
- Do not put backend logic inside Cubits.
- Use immutable states.
- Follow consistent naming: `{module}_cubit.dart`, `{module}_state.dart`, for example `users_cubit.dart` and `users_state.dart`.
- Do not use Provider, Riverpod, or other state management solutions unless explicitly requested.

## 4. Dependency Injection Rules

Use GetIt for dependency injection.

- Centralize all dependency registration inside `core/di/`.
- Register dependencies in the correct order: data sources, then repositories, then Cubits.
- Do not instantiate dependencies manually inside widgets or pages.
- Do not use unnecessary global service instances.
- Use dependency injection whenever a dependency needs to be shared or managed.
- Dependency initialization must complete before `runApp()`.

## 5. Error Handling Rules

Use `fpdart` for functional error handling.

- Prefer `Either<Failure, T>` for operations that can fail.
- Use appropriate failure types defined inside `core/errors/`.
- Keep error handling consistent across features.
- Avoid throwing exceptions for expected application failures.
- Convert external exceptions into meaningful application failures at the appropriate layer.
- Avoid repetitive error-handling implementations.
- Keep failure handling separate from presentation logic.
- Do not introduce another error-handling library or pattern unless explicitly requested.

## 6. Core Reusability Rules

Before creating any new shared component, utility, or helper:

1. Check whether a similar implementation already exists in `core/`.
2. Check whether an existing widget can be extended or reused.
3. Check existing utilities and helper functions.
4. Check existing constants and resources.
5. Reuse existing implementations whenever possible.

Avoid duplicate implementations.

### Shared Widgets

- Reusable application-wide widgets go inside `core/widgets/`.
- Feature-specific widgets stay inside their feature's `presentation/widgets/`.
- Do not create duplicate widgets when an existing shared widget can be reused.
- Common UI components must be reusable across dashboard modules whenever appropriate.
- Do not put feature-specific UI components inside `core/widgets/`.

### Utilities

- Reusable helper functions belong inside `core/utils/`.
- Avoid duplicating utility methods across features.
- Keep utilities focused and reusable.
- Check for existing utility methods before implementing new ones.

### Resources

- Centralize images, icons, strings, and other shared resources inside `core/resources/`.
- Never use asset paths directly in code. Add every asset path to `AppImages` (`core/resources/images/app_images.dart`) and reference that constant.
- Reuse centralized resources wherever possible.

## 7. UI Component Organization and Widget Extraction

**Important: always follow this when creating or modifying screens.**

Keep the main page file small, clean, and readable. Never implement an entire complex screen inside one large page file.

### Widget Extraction

- Break complex UI sections into smaller, focused widgets.
- Extract logically independent UI sections into separate widget files.
- Keep the main page responsible primarily for composing the screen from smaller widgets.
- Avoid unnecessarily large `build()` methods.
- Use meaningful widget names that describe their responsibilities.
- Extract widgets whenever doing so improves readability, maintainability, or reusability.
- Avoid excessive extraction of trivial one-line UI elements.

### Widget Placement

**Application-wide reusable widgets** go in `lib/core/widgets/`:

- Common buttons, text fields, loading indicators, dialogs, and app bars.
- Common empty-state and error-state widgets.
- Other reusable application-wide components.

**Feature-specific widgets** go in `lib/features/{module_name}/presentation/widgets/`:

- Module-specific dashboard sections.
- Module-specific form sections.
- Feature-specific cards and UI components.

### Before Creating a New Widget

1. Check whether an equivalent widget already exists in `core/widgets/`.
2. If it exists, reuse it instead of creating another implementation.
3. If a new widget can be reused across multiple features, place it inside `core/widgets/`.
4. If it is specific to one feature or screen, place it inside that feature's `presentation/widgets/`.

### Main Page Responsibilities

The main screen file should:

- Compose the overall screen layout.
- Organize and arrange extracted widgets.
- Connect the appropriate Cubit state to the UI.
- Handle screen-level interactions when appropriate.

It should not contain hundreds of lines of unrelated widget implementations.

**Goal:** every screen is modular, readable, maintainable, and easy to modify without making the main page file unnecessarily large.

### Safe Area and System Bars

**Always consider these when building UI, especially when creating a new screen.**

- Use `SafeArea` so content stays clear of the status bar, notches, and navigation bar. Backgrounds may extend behind the system bars, but content must not.
- Set the status bar and navigation bar colors with `AnnotatedRegion<SystemUiOverlayStyle>`, including icon brightness, so they match the screen and the icons stay readable.
- Take these colors from the theme. Do not hardcode them.

### Overflow Handling

- Always consider the possibility of overflow when building UI, including long text, small screens, and large system font sizes.
- Choose overflow fixes with UX in mind. The user should still be able to see the full content.
- Do not use `TextOverflow.ellipsis` or other truncation as the default fix, because it hides text from the user. Prefer layouts that adapt, such as wrapping text onto more lines, `Flexible` or `Expanded`, `Wrap`, or scrolling.

## 8. Theme and Styling Rules

The centralized theme system lives inside `lib/core/theme/`:

```text
lib/core/theme/
├── app_colors.dart
├── app_text_styles.dart
├── app_theme.dart
└── theme_utils.dart
```

**The application theme has been provided and implemented.** Brand yellow `#FDC903`, sidebar and primary text `#17243A`, body background `#F5F4EF`. Fonts are Poppins (headings) and DM Sans (body and labels), plus JetBrains Mono, Arial, and Courier New for specific styles. The app runs `ThemeMode.light`; the dark theme exists but is not enabled.

Poppins (500, 600), DM Sans (400, 500, 600, 700), and JetBrains Mono (400) are bundled in `assets/fonts/` and registered in `pubspec.yaml`. Arial and Courier New are not bundled, so `emphasisArial` and `displayCourier` use a fallback font until their files are added. Add other weights before using them.

- `AppColors`: every raw color, gradient and shadow (light and `dark*` counterparts).
- `AppTextStyles`: font families, all text styles, and the uncolored `textTheme`.
- `AppTheme`: `AppTheme.light` / `AppTheme.dark` plus shape tokens (`radiusSmall/Medium/Large`, `buttonHeight`).
- `theme_utils.dart`: `AppThemeColors` (a `ThemeExtension` for brightness-aware semantic colors such as status badges and upload cards) and the `ThemeUtils` extension on `BuildContext` (`context.appColors`, `context.textTheme`, `context.colorScheme`, `context.isDarkMode`).
- `lib/core/utils/app_utils.dart`: `AppUtils` for breakpoints, screen dimensions, spacing, radius, status color lookup, and common decorations.

Flutter text styles cannot set case or alignment. Call `.toUpperCase()` on `sectionLabel` text and set `textAlign: TextAlign.center` on `displayCourier` text.

Rules:

- Use `AppColors` for colors.
- Use `AppTextStyles` for typography.
- Use `AppTheme` for application theme configuration.
- Use `ThemeUtils` for theme-related utilities, including dark-mode handling.
- Use `AppUtils` for layout helpers and common decorations.
- Support light and dark themes according to the provided theme. In widgets, prefer `context.appColors` / `context.colorScheme` over raw `AppColors` so dark mode works.
- Never hardcode colors inside widgets.
- Never duplicate text styles.
- Do not use arbitrary font sizes, font weights, or colors when centralized styles already exist.
- Prefer extending existing theme definitions over creating feature-specific global styling systems.
- Respect the established application design system.
- If a required style or color does not exist, add it to the appropriate centralized theme file instead of hardcoding it inside a widget.

## 9. Navigation Rules

- Centralize navigation configuration inside `core/navigation/`.
- Do not scatter route definitions throughout the application.
- Follow the existing navigation implementation once one exists.
- Keep feature pages independent of navigation implementation details wherever possible.
- Avoid defining the same route in multiple places.
- `MaterialApp` builds every route through `AppRoutes.onGenerateRoute` as an `AppPageRoute` (`core/navigation/app_page_route.dart`). Shell pages swap with no route animation, so the sidebar and top bar never move. `AdminShell` fades and slides only its content through `AdminContentTransition`, which plays on page entry and when a page above it is popped (via `AppRoutes.observer`); switching tabs or `selectedSubItem` within a page does not replay it. `AppUnderlineTabs` and `AppSegmentedControl` size each label for its bold weight through `AppWeightStableText`, so selecting one does not shift its neighbours. Only the login route fades the whole page. Use the `AppTheme.pageTransition*` tokens for page motion and do not add per-page route transitions.

## 10. Naming Conventions

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables and methods: `camelCase`
- Constants: follow the existing project convention.
- Cubits: `{Feature}Cubit`
- States: `{Feature}State`
- Repositories: `{Feature}Repository`
- Data sources: `{Feature}RemoteDataSource` or an appropriate descriptive name.
- Module pages: `{module}_page.dart`, for example `users_page.dart`

Use descriptive names that reflect actual responsibilities. Keep feature-specific functionality within its respective feature.

## 11. Flutter Development Standards

- Write clean, readable, maintainable Dart code.
- Follow SOLID principles where appropriate, without unnecessary abstraction.
- Prefer small, focused widgets, and extract reusable widgets when appropriate.
- Avoid large monolithic widgets and unnecessarily large screen files.
- Avoid unnecessary rebuilds.
- Dispose controllers, subscriptions, and other resources correctly.
- Handle loading, success, empty, and error states.
- Write null-safe Dart code.
- Avoid unnecessary dependencies.
- Follow Flutter 3.47.7 and Dart best practices.
- Maintain existing project conventions.
- Do not add code comments unless explicitly asked.

## 12. Important Development Restrictions

- Never modify existing functionality without understanding its dependencies.
- Never introduce new packages without a valid reason.
- Never duplicate existing utilities, widgets, theme definitions, or constants.
- Never bypass Cubit to access repositories directly from UI.
- Never communicate with Firebase directly from presentation widgets.
- Never create Cloud Functions unless explicitly requested.
- Never create a Domain layer.
- Never introduce abstract repository classes.
- Never move shared functionality into feature folders, or feature-specific functionality into core, without a clear reason.
- Never implement a complete complex screen inside one large Dart file.
- Always extract appropriate UI sections into separate widget files.
- Always check and reuse common widgets from `core/widgets/`.
- Never change the Flutter SDK version.
