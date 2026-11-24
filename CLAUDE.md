# CLAUDE.md

Permanent project rules. Follow them whenever generating, modifying, or refactoring code in this project.

## Project Overview

A Flutter Web admin dashboard for the Zuno platform. Planned areas include the Users module, Aadhaar upload cards, and banners.

The repository currently holds the design system in `lib/core/theme/` and `lib/core/utils/`, the admin login screen in `lib/features/auth/`, and the dashboard and user list in `lib/features/dashboard/` and `lib/features/user_management/`, which use temporary mock data. The sidebar and top bar shell is in `lib/core/widgets/admin_shell/`. Routes are in `lib/core/navigation/app_routes.dart`: `/` is login, `/dashboard` is the dashboard (`lib/features/dashboard/`; the header's `DateRangeDropdown` (Today by default, Yesterday, Last 7 / 30 Days, Custom Date Range, which shows start and end `AppDateField`s) sets one `DateRangeFilter` that filters every section; `DashboardRepository`, a lazy singleton, caches each section per date range for 5 minutes and refetches early when `DataRevision` (`lib/core/data/data_revision.dart`) changes, which `UsersRemoteDataSource` writes and `addAdminRecharge` bump; Top-up Revenue sums `rechargeAmount` on completed `recharge` transactions (gateway and admin) by `createdAt`; Host Audio / Host Video Call Revenue sum `hostEarnings` and Admin Call Revenue sums `adminEarnings` on `calls` documents by `callType` and `createdAt` (one sum query per call type through `CallsRemoteDataSource.fetchRevenue`, needing the `callType` + `createdAt` + `adminEarnings` + `hostEarnings` and `callType` + `adminEarnings` + `hostEarnings` indexes; the lifetime totals in `admin_earnings/main` and `hostDetails.hostEarnings` have no dates and are not used); Total Admin Revenue is Admin Call Revenue plus message revenue plus Deleted Account Profit, rounded once; Admin Message Revenue, the tile after Admin Call Revenue, shows message revenue, which is the sum of `coinsCharged` ÷ 15 on the `messages` collection group (`chats/{userId}_{hostId}/messages`, written by the calling app's `sendChatMessage`, which charges only user-to-host messages and keeps all of it for the platform) by `createdAt`, through `MessageRevenueRemoteDataSource` (a range with no dates filters `createdAt` from 2000 so every range uses the one `createdAt` + `coinsCharged` collection group index); `settings/app.setHostPrice.message.adminAmount` is meant as rupees per message, but the calling app's `sendChatMessage` currently reads it as whole coins; for a dated range Total Users / Hosts count non-deleted sign-ups by `createdAt` and `role`, Deleted Users / Hosts and Deleted Account Profit (sum of `walletBalance` on deleted accounts, which covers accounts deleted before the calling app's `onAccountDeleted` trigger, plus `incomeAmount` of each entry in the `admin_earnings/deletedAccountProfits` document (one map per deleted account, keyed by user doc ID), filtered by the entry's `deletedAt` in the app, through `DeletedAccountRecord`; the trigger empties the wallet so nothing is counted twice) use `deletedAt` (written by admin delete, and by the trigger when the app did not), and the free bonus figures add welcome bonuses by `welcomeBonusClaimedAt` / `welcomeBonusAmount` (user app) to `amountFromOffer` on completed admin recharges, counting a user who got both once; a range with no dates uses all-time counts, `walletBalance` on every deleted account plus every entry's `incomeAmount` in `admin_earnings/deletedAccountProfits` and the `walletSources.bonus` ledger; records written before those date fields existed appear only in a range with no dates; Recent Recharge Activity shows the latest 5 completed recharges in the range with their users joined by ID; the call statistics tiles count `calls` by `status` and `createdAt`), and `/users` is User Management, and `/users/details` is User Details (`lib/features/user_details/`), opened with the `AdminUser` as the route argument and the user's document ID in the URL (`AppRoutes.userDetailsFor`, `/users/details?id=…`); after a browser reload, when only the ID is left, `UserLookupCubit` re-reads it through `UserManagementRepository.findUser` (null unless `role` is `user`) and shows loading, an error with Retry, "couldn't be found" or the page, and without an ID it shows an empty state, never mock data, and `/hosts` is Host Management's Host List (`lib/features/host_management/`; a host's Active / Inactive status, its badge, the Active Hosts / Inactive Hosts filters and Payout Review's host status come from `hostDetails.onlineStatus`, the switch the host flips in the calling app (`online`, or `busy` while on a call, is Active; `offline` or missing is Inactive; `HostManagementRepository.isAvailable`), not from `isActive`, which is set at sign-up and never changes; blocked and deleted take priority; there is no live listener, so changes show when the list loads or the toolbar's Refresh button reloads it from page 1 with the current filter and search), and `/hosts/details` is Host Details (`lib/features/host_details/`), opened with `HostDetailsArguments` and the host's document ID in the URL (`AppRoutes.hostDetailsFor`, `/hosts/details?id=…`); after a browser reload `HostLookupCubit` re-reads the host through `HostManagementRepository.findHost` (null unless `role` is `host`) the same way, and without an ID it shows an empty state; its uploaded documents card shows the Aadhaar card and Selfie tiles, and opening the Aadhaar card slides between `hostDetails.aadharFrontPreview` and `hostDetails.aadharBackPreview` (`AppDocumentSlides`: swipe, mouse / trackpad drag or arrows); below the overview, its Bank Account Details card (`HostBankAccountCard`) shows the host's `bankAccounts/{hostId}` document (holder name, branch, account number, IFSC, PAN and a `bankAccountStatus` badge) whatever its status, loaded with the page and by Refresh through `HostDetailsCubit` and `HostEarningsRepository.fetchBankAccount`, and its Edit button (hidden for deleted hosts and for hosts with no bank account) opens `EditBankAccountSheet`, which edits `accountHolderName`, `branchName`, `accountNo`, `ifscCode` and `panNumber` (PAN may stay empty only on an older account that never had one) with the calling app's rules (`BankAccountValidator` in `lib/core/utils/`, mirroring its `AppValidations`); saving runs one transaction (`HostEarningsRemoteDataSource.updateBankAccount`) that refuses an account whose details changed after the sheet opened (`BankAccountRecord.edit`) and writes only the changed fields plus `updatedAt`; it never changes `bankAccountStatus`, `createdDate` or the approval fields and adds no new keys, because the calling app's `isValidBankAccount` rule allows only the known keys when a host resubmits a rejected account (so there is no `bankName` field); the calling app's `onBankAccountWritten` trigger then copies an approved account's new details onto that host's `pending` / `failed` `hostPayouts`, and the next beneficiary sheet export gives the host a new `beneficiaryId`, and `/hosts/surge-sessions` is Surge Charge Sessions (`lib/features/surge_charge_sessions/`), and `/calls` is Calls (`lib/features/calls/`; lists the root Firestore `calls` collection written by the calling app's Cloud Functions (`customerId`, `customerName`, `customerUserId`, `hostId`, `hostName`, `hostUserId`, `callType` `audio` / `video`, `status` `ringing` / `accepted` / `ongoing` / `completed` / `rejected` / `cancelled` / `missed` / `failed`, `createdAt`, `startedAt`, `endedAt`, `durationSeconds`, `coinsCharged`, `amountCharged`, `hostEarnings`, `adminEarnings` (`CallLog.fromDocument` falls back to the keys older documents still carry: `callStart`, `callEnd`, `callEndedBy`, `callStatus`, `durationInSeconds`, `coinDue` / `coinsDue`, `rupeeSpentByUser`, `hostEarning` / `rupeeGotByHost` / `hostEarningPaise`, `platformEarning` / `rupeeGotByAdmin`, `receiverId`, `receiverName`, `callerName`; it also reads dates stored as epoch numbers, ISO strings or `{seconds, nanoseconds}` maps, and when `endedBy` holds no role it works out who ended the call from `callEndedUserId`, `endReason`, `status`, `endRequestedBy` and the first leave in `left`, the way the calling app's Cloud Functions decide it; Call Duration is the billed `durationSeconds` when positive, otherwise `endedAt` minus `startedAt`; Call Ended By adds the reason for every ending except a plain hang-up, e.g. `Host – rejected`, `User – cancelled`, `Host – no answer` (a ring timeout, `endReason` `noAnswer`, is shown as the host even though the calling app stores `endedBy: system`; a `missed` call with no stored role or reason is also the host, while `hostUnreachable` stays `System`), and shows `User – low balance` when `endReason` is `lowBalance` (written by the calling app's settlement when the caller's wallet ran out, whichever phone sent the end request; the app sends `reason: lowBalance` with `endCall` when its countdown reaches 0, stored as `endRequestReason`, and settlement confirms it against the wallet) or, for calls settled before that reason existed, when `insufficientBalance` is true on a completed plain hang-up (`CallLog.endedForLowBalance`); the Call Status column shows `CallLogLabels.status`: Low Balance when `insufficientBalance`, otherwise `ringing` as Incoming, `completed` / `busy` / `rejected` as themselves, `missed` as Not Answered, `cancelled` as Missed, plus Ongoing and Failed), `insufficientBalance`, `endedBy`, `endReason`); browsing loads 10 at a time by newest `createdAt` through `CursorPager`, with the date (Today by default, Yesterday, Last 7 / 30 Days, custom), call and type filters in the Firestore query (composite indexes in `firestore.indexes.json`) and a count query for Total Calls; the call filter opens on Incoming Calls (no status condition, every call in the range) and maps Ongoing to `accepted` / `ongoing` (one `whereIn`, served by the same `status` + `createdAt` index), Completed, Rejected and Busy to that `status`, Not Answered to `missed`, Missed to `cancelled` (caller hung up while ringing) and Low Balance to `insufficientBalance`; the debounced search (user or host name, user mobile, host ID, call ID or session ID) downloads the selected date range once, and text that could be a call document ID is also looked up directly (`CallsRepository.findCallWithUser`) so an exact call ID finds its call outside the date range (still subject to the call and type filters),, joins `users` by `customerId` for the phone, and pages through the matches locally), and `/calls/details` is Call Details (`lib/features/call_details/`), opened with the `CallLog` as the route argument, and `/approval` is Approval (`lib/features/approval/`; the Host Requests, Payout Review and Profile Photo Review tabs are built, and the Approval sidebar sub-items switch tabs through `AdminShell.onSubItemSelected`; Host Requests lists Firestore `users` documents whose `hostDetails.hostStatus` is `submitted`; the sheet's Edit saves through `ApprovalRepository.updateHostRequest` and `UsersRemoteDataSource.updateRecord`, writing only changed fields with Host Management's mapping (Real Name `hostDetails.fullName`, Nick Name `hostDetails.userName`, City `hostDetails.district`, `dob` as an ISO string, `gender`, `motherTongue`, `languages`, and the mobile number through `UserRecord.phoneFields`), shows an error in the sheet if the write fails and updates the list only after it succeeds; each Aadhaar Front, Aadhaar Back and Selfie field is reviewed individually, the sheet's main Approve button appears only once all three are approved and its Reject button also appears as soon as any document is rejected or missing (`HostRequest.canApprove` / `canReject`, enforced again in `UserRecord.hostRequestDecision`), main Reject sets `hostDetails.hostStatus` to `rejected` (the row stays, marked Rejected, until the list reloads), an approved request is removed from the Host Requests list at once (`ApprovalPager.remove`, and the cubit skips approved IDs in later fetches, including a search's local pages; a page left empty reloads from page 1), and in Payout Review and Profile Photo Review both accepting and rejecting remove the item at once and drop the tab count (`_decidedPayouts` / `_decidedPhotos`, keyed by ID plus `submittedOn` so a host's later resubmission of the same document still shows); a rejected Host Request stays, marked Rejected, until the list reloads, main Approve sets `hostDetails.hostStatus` to `approved` and `role` to `host` in one transaction; only after that succeeds, `ApprovalRepository` re-reads the user and, unless `avatharImage` is a custom picture (any URL outside the Storage folders `users_avathar` / `host_avathar`, which the calling app also picks from at sign-up), gives a `hostDetails.gender` `male` host a random `users_avathar` image and a `female` host a random `host_avathar` image through `AvatarStorageRemoteDataSource` (avoids the current and recently assigned avatars, checks the download URL), written to `avatharImage` in a guarded transaction with no audit entry (`isAvathar` / `avatharStatus` are set only when the user had no avatar status); other or missing genders, empty folders and Storage errors leave the picture unchanged and never fail the approval; Profile Photo Review lists `users` documents whose `isAvathar` is false and `avatharStatus` is `submited` with a valid `submitedImageUrl` (these misspellings are the real Firestore field names and value, centralized in `UserRecord`), Accept sets `avatharStatus` to `approved` and `avatharImage` to the reviewed URL, Reject sets `avatharStatus` to `rejected`, each in one transaction with a local state update and no refetch; approving a host request sets `hostDetails.approvedAt` and `hostDetails.approvedBy` (Host Details' profile card shows `approvedAt` as Host Approved Date, `—` for hosts approved before it was recorded), and accepting a photo sets `avatarApprovedAt` and `avatarApprovedBy`, using a server timestamp and the signed-in admin's UID, only when no approval date exists yet; every host document review, host decision and photo decision also writes an `approvalAuditLogs` entry in the same transaction through `lib/core/data/approval_audit.dart`; Payout Review lists `bankAccounts` documents whose `bankAccountStatus` is `submitted`, each document ID being the user's ID, joined to `users` by ID, and approving re-reads the signed-in admin's `admin` document (by email) and requires the Approval module (super admins have all modules), then sets `bankAccountStatus`, `adminApprovedAt` and `adminApprovedBy` in one transaction that refuses a changed account; all three tabs load 10 records at a time from Firestore with cursors, newest `updatedAt` first, through `lib/core/data/record_page.dart`, search with a 450 ms debounce (at least 2 characters) through "starts with" range queries from `UserSearch.prefixesFor` (name as typed, lowercase and capitalized, uppercase `userID`, phone digits with and without the country code), with no `searchKeywords` field: Host Requests and Profile Photo Review run them on their own base query (`UsersRemoteDataSource.searchHostApplicants` / `searchProfilePhotoRequests`, on `hostDetails.userName`, `hostDetails.fullName`, `userName`, `userID` and `phoneNumber`, needing the tab filter + searched field indexes), Payout Review finds hosts with `searchUsers` and then their submitted `bankAccounts` by ID (`PayoutRemoteDataSource.fetchSubmittedByIds`), and the results are filtered by the date range on `updatedAt`, sorted newest first and paged locally with `LocalPageCursor`; the lists require the composite indexes in `firestore.indexes.json`, and pages are cached in `ApprovalPager`), and `/reports` is Reports (`lib/features/reports/`; lists the root Firestore `reports` collection written by the calling app's `hideCallHistory` callable (document ID `{callId}_{reporterId}`; `reportedBy` / `reported` user document IDs, `reporterRole` `user` / `host` (older reports without it are worked out from `reportedBy` == `hostId`), `reportType` (`askingPersonalDetails`, `offensiveLanguage`, `inappropriateBehavior`, `requestingPersonalDetails`, `notResponding`, `moneyRequests`, `other`; unknown values show as Other), `reportDetails`, `reportedByName`, `reportedName`, `reportedByPhone` / `reportedPhone` (country code and number in one string), `receivedReportCount` (that reporter's reports against that person, not shown), the root `reportedUsers/{reportedId}` document (`totalReceivedCount`, every report the person received from anyone, and `lastReportedAt`; written only by `hideCallHistory` in the same transaction as each new report, started from that person's existing reports the first time, and created for older data by `tool/backfill_report_totals/` (dry run by default, `--write` to apply, only creates missing totals); the Received Total Report Count column shows it, read fresh for every loaded page with one `whereIn` query on the page's reported people, `—` when a person has no total), `reportedAt`, plus the call's `callId`, `callType`, `customerId`, `customerName`, `customerUserId`, `hostId`, `hostName`, `hostUserId` and avatars); browsing loads 10 at a time by newest `reportedAt` through `CursorPager`, with the date (Today by default), report type and reporter filters in the Firestore query (composite indexes in `firestore.indexes.json`) and a count query for the footer total; like Calls, `ReportsCubit` loads fresh data each time the page opens and resets its one `CursorPager` and count whenever a filter or the search changes (there is no refresh button); search (debounced, at least 2 characters) runs "starts with" range queries from `ReportSearch` (names as typed, lowercase and capitalized on `reportedByName` / `reportedName`, uppercase user ID on `customerUserId` / `hostUserId`, or for phone-like text the digits with and without `+` / `+91` on the phone fields; up to 50 results each), merges them, and applies the date, type and reporter filters and paging locally; `ReportsRepository` (a factory, so its cache lasts one page visit) caches each term's results and, when an earlier term's results were complete and cover the new term, narrows them locally instead of querying again), and `/packages` is Packages (`lib/features/packages/`; only the Package List tab is built; it lists 10 at a time by ascending `rechargeAmount` through `CursorPager`, with count queries for the summary, and a Package-wise Total Recharge Count column showing the package's stored `totalRechargeCount` (completed recharges, gateway and admin alike: the calling app's `creditRecharge` and `addAdminRecharge` add 1 to it in the same transaction that credits the wallet, so a repeated verify, webhook or admin request counts once; new packages are created with 0; `tool/backfill_package_recharge_counts/` (dry run by default, `--write` to apply, safe to re-run) sets it on existing packages to the number of `transactions` with that `packageId`, `type` `recharge` and `status` `success`; a package without the field falls back to one equality-only count query on those `transactions`, fetched once per page visit for the rows shown, `—` until loaded or on failure), and adds and edits documents in the Firestore `packages` collection, whose fields are `coins`, `createdAt`, `updatedAt`, `offerPercentage`, `offerTag`, `packageStatus` (`active` / `inactive`; the user app shows only active packages), `rechargeAmount`, `receivableAmount`, `isGstEnabled` and `totalRechargeCount` (written only by the calling app's recharge functions after creation; the dashboard's edits never touch it), and `tool/migrate_packages/` migrates older documents to that schema; amounts are doubles limited to 2 decimal places through `DecimalInputFormatter` and shown with 2 decimals by `NumberFormatter.rupeesAmount` / `groupedAmount`; Receivable Coin is read-only, a whole number, and always receivable amount × `PackagePlan.coinsPerRupee` (15) rounded to the nearest coin; by default the payable and receivable amounts fill each other in through the GST setting (`PackagePlan.payableFor` / `receivableFor`), and the sheet's Enter receivable manually switch unlinks them so the receivable amount is typed in and never recalculated (turning it off recalculates it from the payable amount); no flag is stored, an edited package opens in manual mode when `PackagePlan.hasManualReceivable` (the stored receivable differs from the GST formula by half a paisa or more); the receivable must be above 0 and not above the payable amount (`PackagePlan.isReceivableValid`), because the calling app's recharge functions credit the package's `receivableAmount`, record `rechargeAmount - receivableAmount` as `gstAmount` and refuse a package where that is negative), and `/recharge` is Recharge (`lib/features/recharge/`; lists the Firestore `transactions` collection (only documents where `RechargeTransaction.isListed` is true, i.e. `type` is `recharge` / `adminCredit` / `adminDebit`; the user app's welcome bonus is a `transactions` document with `type` `welcomeBonus` and is never listed or counted as a recharge; the same rule applies to every source filter, the search pool, User Details' recharge history and totals, and the dashboard's Recent Recharge Activity, and it filters on the client so no new index is needed), whose documents have random Firestore IDs (gateway payments are looked up by `razorpayOrderId`) and exactly these fields on every document: `userId`, `type` (`recharge` / `adminCredit` / `adminDebit`), `status` (`pending` / `success` / `failed`, shown as Created / Completed / Failed), `packageId`, `isRechargedByAdmin` (true for admin recharges, credits and debits), `rechargeAmount` (the package's `rechargeAmount`, GST included, on gateway and admin recharges), `adminCreditAmount`, `adminDebitAmount`, `gstAmount`, `amountFromOffer` (`offerPercentage` of `rechargeAmount - gstAmount`), `receivedTotalAmount` (what reached the wallet: `rechargeAmount - gstAmount + amountFromOffer` for recharges, the amount for credits, 0 for debits and until credited), `currency` (`INR`), `razorpayOrderId`, `razorpayPaymentId`, `failureReason`, `adminUid`, `description`, `createdAt`, `creditedAt` (null until credited and on debits); unused fields are null or 0; coins are not stored and are `receivedTotalAmount` (or the debit amount) × 15; `tool/clear_transactions/` backs up and deletes the whole collection, joined to `users` by `userId` for name and phone; browsing loads 10 at a time with cursors through `CursorPager`, with the date, status and source filters in the Firestore query (the source filter opens on All, which has no `type` condition; admin versus gateway recharges are separated in the app), while the debounced search (name, phone, recharge amount, order or payment ID) downloads the selected date range once and pages through the matches locally; documents with a `razorpayOrderId` are gateway payments and the others admin recharges, and `adminCredit` / `adminDebit` types are admin credit and debit; the stat cards total completed transactions with Firestore count and sum queries on `rechargeAmount`, `adminCreditAmount` and `adminDebitAmount` and follow the date filter only), and `/payment` is Payment (`lib/features/payment/`; lists the root Firestore `hostPayouts` collection, one document per host per payout cycle with the ID `{hostId}_{cycle}` (`hostId`, `cycle`, `withdrawId` `WD-{userID}-{cycle}`, `status` `open` / `pending` / `success`, `callCount`, `callDurationSeconds`, `callEarnings` (base host earnings), `surgeEarnings`, `adminCreditAmount`, `adminDebitAmount`, `bonusAmount` (always 0 for now), `totalAmount`, `hostName`, `hostUserId`, `hostCountryCode`, `hostPhoneNumber`, `periodStartDay`, `createdAt`, `updatedAt`; an `open` record also has `days` (one entry of the same count and amount fields per IST day, `YYYY-MM-DD`), `withdrawable` (the same fields for everything before today), `rolledDay` and `withdrawableThroughDay`; a `pending` record has `periodEndDay`, `pendingAt`, `pendingBy` and `pendingByName`; a paid one adds `paidAt`, `paidBy`, `paidByName`, `tdsPercent`, `tdsAmount`, `receivableAmount` and a `bankAccount` snapshot (`accountHolderName`, `branchName`, `accountNo`, `ifscCode`, `panNumber`, copied from the approved `bankAccounts` document at payment and never changed afterwards; `pending` and `failed` records carry the same `bankAccount` map, written by `movePayoutsToPending` and refreshed by `retryHostPayouts` from the account they already re-check, and kept current by the calling app's `onBankAccountWritten` trigger (which rewrites it on that host's `pending` / `failed` records only, never `success` or `forfeited`, when the approved details differ, sets it to `null` when the account is no longer approved or is deleted, and leaves `updatedAt` alone so the lists keep their order); `Withdrawal.hasStoredBankAccount` / `needsBankAccountLookup` decide the source: open rows, and `pending` / `failed` records written before the copy existed (no `bankAccount` key; `tool/backfill_payout_bank_accounts/`, dry run by default, `--write` to apply, only fills missing copies), still read `bankAccounts` live, a stored `null` means no approved account, and the details sheet shows PAN Number, `—` when missing)); amounts are rupee doubles stored unrounded (only the UI rounds, to 2 decimals, so expected-amount checks compare with a 0.000001 tolerance, `PayoutSettings.amountTolerance`); a payout covers earnings from the last payout day 00:00 to yesterday 23:59:59 IST, and earnings from the day the admin acts wait for the next payout; the records are written only by the calling app's Cloud Functions (`functions/payouts/`): call settlement and admin credits add to the host's one `open` record (`hostDetails.pendingPayoutId`) and to that day's `days` entry, admin debits go to the totals and `withdrawable` immediately, `adjustHostEarnings` (Host Details Credit / Debit Wallet, admin `hostManagement` module, refuses a debit above the host's Available Wallet Amount, `hostDetails.hostEarnings.availableBalance`; a debit larger than the open record's total leaves that record negative, which later earnings fill before the host can withdraw again, while records already in Pending are paid unchanged) does credits and debits, and `rollHostPayoutDays` (scheduled every 10 minutes from 00:00 to 00:50 IST) recomputes `withdrawable` once a day; `movePayoutsToPending` (admin `payment` module, up to 50 records a call, one transaction each) re-checks each record's withdrawable amount against the reviewed one, `settings/app.minimumPayoutAmount` and an approved `bankAccounts` document, turns the record into `pending` with the withdrawable part, and moves today's entry to the next cycle's `open` record; `completeHostPayouts` (same module) re-checks the reviewed amount and the bank account, marks the record `success` with 2% TDS, moves `totalAmount` from `hostDetails.availableBalance` to `hostDetails.totalWithdrawn` and writes a `host_payout` `ledger` entry; `failHostPayouts` (same module, called with `reason` (`invalidAccount` / `accountClosed` / `nameMismatch` / `bankRejected` / `other`, which needs a `note` of up to 200 characters, modelled by `PayoutFailureReason`)) marks a `pending` record whose `totalAmount` still equals the reviewed amount `failed` with `failureReason`, `failureNote`, `failureCount` (+1), `failedAt`, `failedBy` and `failedByName`, needs no approved bank account and changes nothing else (no wallet, `hostEarnings` or `ledger` change, because only Mark as Success takes money from `availableBalance`); a repeat returns the stored result; `retryHostPayouts` (same module) re-checks the amount, that the host exists and is not deleted, the amount is above 0 and an approved `bankAccounts` document, then returns the record to `pending` with `retriedAt` / `retriedBy` / `retriedByName` (the failure fields stay as history); success and moving to pending still refuse a `failed` record; the account-deletion sweep forfeits `failed` records with `open` / `pending` ones and counts them as pending money; the Withdrawal List tab lists `open` records whose `withdrawable.totalAmount` is at or above the minimum (a missing or invalid minimum counts as none) largest first, keeping only hosts with an approved `bankAccounts` document, checked live (the stored `bankReady` flag is not used in the query because older approved accounts may lack it); `PaymentRepository.fetchOpenPage` uses `RecordPages.untilMatch`, so a batch whose rows all lack an approved account is skipped and the next batch is read instead of ending the list (no extra reads when every row qualifies; a page can hold fewer than 10 rows), the Pending tab lists `pending` records newest `updatedAt` first, the Success tab lists paid records newest `paidAt` first, filtered by `paidAt` through its `AppDateFilterButton` (All, Today (the default), Last Week (last 7 days), Last 30 Days, Custom Date Range; `PaymentState.successDateOptions`; `DateRangeFilter.all` has no bounds and is offered only here), with the range also applied to the tab's count query, the paid host search and the existing `status` + `paidAt` / `hostId` + `status` + `paidAt` indexes, and the Failed tab (sidebar Failed Withdrawals) lists `failed` records newest `updatedAt` first (the existing `status` + `updatedAt` index), each 10 at a time through `CursorPager`, with the overview card and the Withdrawal List count built from the same rows the list shows (`PaymentRepository.fetchOpenOverview`: `fetchAll(open)`, up to 1000 open records with an approved bank account, summed by `PayoutSummary.of` into count and `withdrawable.callEarnings`, `surgeEarnings`, `callDurationSeconds` and `totalAmount`, no Firestore aggregation; the Upcoming Withdrawal Overview shows, in order, Total Host Revenue = callEarnings + surgeEarnings (`PayoutSummary.hostRevenue`), Total Host Credit = totalAmount − callEarnings, Duration = total seconds ÷ 60 rounded once, and Total Withdraw = the sum over the same rows (`fetchOpenOverview`'s `netTotal`) of `withdrawable.totalAmount` less that row's TDS: 2% when its bank details have a PAN number, 5% (`PayoutSettings.tdsPercentWithoutPan`) when the PAN is missing or blank (`Withdrawal.panTdsPercent` / `netAfterPanTds`; open rows read the PAN from the approved `bankAccounts` document, other rows from their `bankAccount` copy); this card, and the TDS Cut Amount / Applied TDS % / Total Receivable Amount columns of unpaid rows in the Withdrawal List and Pending tables, which share one column set with the Success table (`WithdrawalTableColumns`; paid rows show their stored TDS values) — the review, Mark as Success, export and the calling app's `completeHostPayouts` still deduct a flat 2%) and count queries for the tab counts; open rows, and pending or failed rows without a stored copy, join the host's approved `bankAccounts` document by ID, the Withdrawal List shows no bank column, and only rows with an approved account can be selected; the Withdrawal List, Pending and Failed tables have checkboxes (`AppTableCheckbox`, page select in the header); only the Failed tab has an `AppSelectionBar` (Select all, every matching row up to 1000 loaded once, Retry Payout for rows with an approved account, and Clear); the Withdrawal List and Pending tabs have no selection bar (rows are selected with the checkboxes, page select in the header), and once a row is selected the toolbar shows Move to Pending (Withdrawal List) or Mark as Success, each with the selected count in brackets (`AppStrings.withSelectedCount`), after Export Withdrawal Sheet (Pending, sends only `pending` records); these confirm first, send the selection in chunks of 50 and show a result dialog listing any host that failed and why; the details sheet has these actions for one record, including Mark as Failed (its dialog takes the reason and note); the debounced search uses the host search (`UsersRemoteDataSource.searchUsers`) with each host's `pendingPayoutId` (Withdrawal List), the hosts' `pending` or paid records, or an exact `withdrawId`, and pages locally; moving and paying update the lists locally and then refresh the counts; TDS is 2% (`PayoutSettings.tdsPercent`, mirrored by `PAYOUT_TDS_PERCENT` in the calling app); on the Pending tab, Export Beneficiary Sheet and Export Withdrawal Sheet download `.xlsx` files (built by `PayoutSheetExporter` with the `excel` package, downloaded through `lib/core/utils/file_download.dart`) for the selected rows, or every pending record (up to 1000) when none is selected; the Withdrawal List tab has the same Export Beneficiary Sheet and Export Withdrawal Sheet buttons; on both tabs Export Withdrawal Sheet stays disabled (with a tooltip) until a beneficiary sheet covering the same payouts was downloaded on the page (`PaymentState.canExportWithdrawals`: every selected payout is in `beneficiaryExportedIds`, or, with nothing selected, the tab is in `beneficiaryExportedTabs`, set by a whole-tab beneficiary export, cleared by Refresh and when payouts that were not in a beneficiary sheet move into the tab); the Withdrawal List's withdrawal sheet exports the selected rows or every open record at or above the minimum with an approved bank account (up to 1000), using each record's withdrawable amount (`PaymentState.exportTabs`, `PaymentCubit.loadSheetRows`), skipping rows without an approved bank account; every cell is text; exporting the beneficiary sheet first registers each host (`PayoutBeneficiary`, `PaymentRemoteDataSource.registerBeneficiaries`, transactions of up to 100 `users` documents, no `updatedAt` change): `hostDetails.beneficiaryId` (a uniqid-style ID: microsecond time in hex plus 4 random hex digits, uppercase) is created when missing or when the approved bank account changed, detected through `hostDetails.beneficiaryBankHash` (SHA-256 of host ID, account number, IFSC and holder name, so no bank details are copied into `users`), and `hostDetails.isBeneficiary` is set true with `beneficiaryUpdatedAt`; the beneficiary sheet uses that `beneficiaryId` as Beneficiary Code, the bank account holder name, account number and IFSC, `SAVINGS`, the 10-digit phone and `hostDetails.district` / `state` as ADDRESS3 / ADDRESS4; the withdrawal sheet is NEFT only, with the amount after TDS (2 decimals), today's date as Value Date (`dd/MM/yyyy`), the host's `hostDetails.beneficiaryId` as Beneficiary ID (only when `isBeneficiary` is true and `beneficiaryBankHash` matches the current approved account; other rows are left out and counted in the result dialog, and a snackbar asks for the beneficiary sheet first when no row qualifies; when no row has an approved bank account the snackbar says so (`AppStrings.noExportableWithdrawals`), and `nothingToExport` is only for an empty tab), the payout's `host_admin_credit` / `host_admin_debit` `ledger` descriptions (joined by `payoutId`; credits after `periodEndDay` IST belong to the next cycle and are left out) as Credit / Debit Remarks and `withdrawId` as the reference number (`Withdrawal.bankReference` adds `-R{failureCount}` once a payout has failed, so a retried transfer gets a new reference); Customer ID and Debit Account Number are hardcoded constants in `PayoutSheetExporter`; the dashboard has no mock data generator (the Withdrawal Workflow Testing card was removed), but `hostPayouts` flagged `isMock: true` (left on staging by the calling app's `seedMockWithdrawals`) still read as `Withdrawal.isMock`, show a Mock badge (`MockWithdrawalBadge`) in the normal tabs and the details sheet, and are left out of both sheets by `PaymentRepository.fetchSheetRows` on any environment except staging), and `/settings` is Settings (`lib/features/settings/`; the Maintenance Mode, Admin Management, Notification Management and Banner Image Management tabs are built; banners are stored in the single Firestore document `settings/bannerImages` as map fields keyed by banner ID (each map has `role` (`user` / `host`), `screen` (`home` / `recharge`, modelled by `BannerScreen`; a missing `screen` means `home`), `createdAt`, `status` (`active` / `inactive`), `imageName`, `imageUrl`) loaded and added through `BannerImagesRemoteDataSource`; Add Banner and the Add banner image tile open the add dialog for Home banners directly (the Home Banner / Recharge Banner options menu in `openAddBannerDialog` is commented out, and Recharge was already disabled there); the add dialog, whose subtitle names the screen and whose User / Host switch offers only User for recharge banners because hosts have no recharge screen (`BannerScreen.audiences`); the calling app's `BannerSlider` shows only active banners whose `screen` and `role` match it (user and host Home, user Recharge on the coin package page); the dialog picks a PNG or JPG of up to 5 MB from the gallery with `image_picker`, uploads it to Firebase Storage at `bannerImages/{role}/{documentId}.{ext}`, then merges the banner's map field into that document (the uploaded file is removed if the write fails); Delete asks for confirmation, then removes the banner's field and its Storage file (a failure shows a snackbar); the maintenance switch asks for confirmation, then writes `isMaintenanceMode` to the Firestore `settings/app` document (merged, with `updatedAt`) through `SettingsRemoteDataSource`, and shows a top-bar badge through `AdminShell.topBarNotice` on the Settings page only; the Maintenance Mode tab also edits `settings/app.minimumPayoutAmount` (rupees, 2 decimals, read with the maintenance flag in one `fetchGeneralSettings` read; parsed by `PayoutSettings` in `lib/core/data/payout_settings.dart`), the minimum pending total for a host to appear on the Payment page; `settings/app` also holds `appVersion` (`android` / `ios` maps with `minimumVersion`, `currentVersion`, `minimumBuildNumber`, `currentBuildNumber`, `forceUpdate`, `storeUrl`, plus `updateMessage`), which `tool/seed_settings/` creates without overwriting existing values; `settings/app` also holds `setHostPrice`, a map with `audio` and `video` maps, each with per-minute `adminAmount` and `hostAmount`, and a `message` map with only `adminAmount` (rupee doubles, 2 decimals; saving deletes any old `message.hostAmount`), modelled by `HostPricing` in `lib/core/data/host_pricing.dart` for reuse by the calling, wallet and messaging modules, edited in Host Management's Set call & message price dialog (Admin / Host tabs) through `CallPricingCubit` and `SettingsRepository`, merged into the document on save, and seeded with zeros by `tool/seed_settings/`; `setHostPrice.surgeCharge` is a list of maps (`sessionName`, `startTime` / `endTime` as Firestore Timestamps whose time of day is the daily window, stored on the date the times were last changed with the end moved to the next day for overnight sessions, untouched entries keeping their stored Timestamps, older whole-minute values still read, `surgeCharge` as a whole-number percent, `status` `enabled` / `disabled`) mapped by `SurgeSession`, listed and edited on the Surge Charge Sessions page through `SurgeSessionsCubit` and `SettingsRepository`; every add, edit, delete or status toggle merges the whole list into `settings/app` in one write (other `setHostPrice` fields are untouched) and updates the page without a refetch; list position is the entry's identity, there is no stored ID; Add admin and Edit open the admin side sheet and save to the Firestore `admin` collection through `lib/core/data/admins_remote_data_source.dart` (random Firestore document ID, looked up by the lowercased `email` field, which must stay unique; fields `name`, `email`, `phoneNumber`, `role` (`AdminRole` name), `permissions` (`AdminNavItem` names), `createdAt`, `updatedAt`), and every admin with the Settings module sees Add admin and Edit; every module route is wrapped in `AdminAccessGate` for its `AdminNavItem`, the sidebar lists only the signed-in admin's permitted modules through the app-wide `AdminSessionCubit`, Add admin and Edit save through the `saveAdminAccount` callable (`functions/src/admin_accounts.js`, Admin SDK, so Firestore rules are not involved), which re-reads the caller's `admin` document and requires the Settings module, validates the fields again (name required, valid email, `phoneNumber` exactly 10 digits, known role and modules, at least one module unless super admin), and creates the doc and the Firebase Auth email/password login (password required on add, at least 6 characters; an email that already has a login keeps its password); only super admins can change an existing admin's password (the Edit sheet shows the password field only to them) or grant or remove the Super Admin role, and the last super admin cannot be demoted; the sheet's Select all checkbox toggles every module, and choosing Super Admin selects and locks all modules; sign-in admits any account with an `admin` document that has at least one module, and the `admin` claim is only needed for the first admin, the first claimed admin to sign in while the collection is empty becomes a super admin automatically; the notification audience counts come from Firestore `users` documents that are not deleted (count by `role` minus those with `isAccountDeleted` true), with hosts optionally narrowed by `hostDetails.motherTongue`, and the mother tongue selection is cleared when Send to is User; Send notification validates the form and opens a confirmation dialog, and Send now calls the `sendAdminNotification` callable Cloud Function (`functions/`, codebase `admin`, region `asia-south1`) through `NotificationsRemoteDataSource`; the function checks the caller has an `admin` document with the `settings` permission and sends to FCM topics instead of querying `users`: `users_all` for users, `hosts_all` for all hosts, or one `hosts_{code}` topic per selected mother tongue (`hosts_en`, `hosts_ml`, `hosts_ta`, `hosts_hi`, `hosts_kn`, `hosts_te`, mapped from the `HostLanguage` names in `functions/src/topics.js`, mirrored in the calling app's `functions/src/topics.js` and `fcm_topics.dart`, so change all three together), combining topics into FCM conditions of at most 5 so a device subscribed to several gets one message; each device's topics are kept in sync by the calling app's single `onUserWritten` trigger on `users/{uid}` (`syncUserTopics`: none when deleted or blocked, `users_all` for users, `hosts_all` plus the `hostDetails.motherTongue` topic for hosts, moved when `fcmToken` changes), backed up by the app's own sign-in and logout sync, and `functions/scripts/backfill_fcm_topics.js` there subscribes existing tokens once; admin sends are not stored in Firestore (only logged); the root `notifications` collection holds per-user app notifications (`userId`, `title`, `body`, `type`, `isRead`, `createdAt`, `data`), written only by the calling app's Cloud Functions, never by the dashboard: Add Recharge creates `admin_recharge` inside `addAdminRecharge`, Credit / Debit Wallet on User Details creates `admin_credit` / `admin_debit` through the calling app's `onTransactionCreated` trigger on the `transactions` document, and approving a host request creates `host_approved` through its `onUserWritten` trigger (the `userId` + `createdAt` index is in both repos' `firestore.indexes.json`), and the success dialog shows only its title and Done button; the Settings sidebar sub-items switch tabs). The sidebar navigates to any `AdminNavItem` or `AdminSubNavItem` that has a route; a selected item's sub-items show beneath it. Editing, blocking, and deleting a user or host use the shared `AppActionMenu` / `AppTakeActionButton`, plus the side sheet, confirm dialog, and success dialog from `lib/core/widgets/`. Add Recharge on User Details lists the active Firestore `packages` and calls the `addAdminRecharge` Cloud Function (in the calling app's `functions/index.js`), which checks the caller's `admin` document, re-reads the package and, in one transaction, adds `receivedTotalAmount` to `walletBalance`, the amount without GST to `walletSources.adminRechargeAmount` and the offer to `walletSources.bonus`, and creates a `transactions` document with `isRechargedByAdmin: true` and the package cost in `rechargeAmount`, whose random Firestore ID is generated per confirmation so a repeat is applied once; gateway recharges have `isRechargedByAdmin: false`. On User Details, Available Coins is the user's exact `walletBalance` (rupees, up to six decimals after billing; coins are never stored) converted by `CoinConverter.rupeesToCoins` (`lib/core/utils/coin_converter.dart`: `floor(walletBalance × 15 + 1e-6)`, the same as the calling app's `CoinConverter` and the Cloud Functions' `coinsFor`), and Available Coins Amount is that `walletBalance` in rupees; `AdminUser.walletAmount` keeps the exact balance (`walletBalance` is only the rounded-down text for the user list), and opening the page re-reads the user document through `UserManagementRepository.fetchUser` because the list's copy goes stale. Total Recharge, Receivable Top-up, Total Credit From Admin and Total Debit From Admin come from all of the user's completed `transactions` through `UserRechargeSummary`: `rechargeAmount` on recharges, `rechargeAmount - gstAmount` on recharges (older documents without `gstAmount` use `receivedTotalAmount - amountFromOffer`), and `adminCreditAmount` / `adminDebitAmount` on admin credits and debits. They are not read from `walletSources`, because billing spends the `bonus`, `rechargeExtra`, `adminCredit` and `topUp` buckets down, so those hold what is left of each source, not what was ever added. Credit / Debit Wallet on User Details changes the user's `walletBalance` and adds to `walletSources.adminCredit` or `walletSources.adminDebit` and creates a `transactions` document with the full schema (`type` `adminCredit` / `adminDebit`, `status` `success`, `isRechargedByAdmin: true`, `adminCreditAmount` or `adminDebitAmount`, `receivedTotalAmount`, `description`, `adminUid`, `createdAt`, `creditedAt` on credits) in one transaction that refuses a debit above the current balance and any credit or debit on a deleted account (`isAccountDeleted`, `AppStrings.walletAccountDeleted`; the Credit / Debit Wallet and Add Recharge buttons are hidden for deleted users through `AdminUser.hasActions`, blocked users keep them), so admin adjustments never change Deleted Account Profit; the same dialog on Host Details calls `adjustHostEarnings`, which changes the host's `open` `hostPayouts` record (see Payment) and `hostDetails.availableBalance`, and writes a `host_admin_credit` / `host_admin_debit` `ledger` entry; its debit limit is the Available Wallet Amount, and the button is hidden for deleted hosts (`AdminHost.isDeleted`; `adjustHostEarnings` also refuses them); on Host Details only (`showWalletAdjustmentDialog(allowIncentive: true)`), the Credit side shows an Is this an Incentive? checkbox that sends `isIncentive: true` to `adjustHostEarnings`, which credits it exactly like any other credit (same `host_admin_credit` ledger type, so the admin credit totals, payouts and sheets count it) but adds `isIncentive: true` to the ledger entry and sends a `host_incentive` notification ("Incentive Added!") instead of `admin_credit`; the function refuses an incentive debit, and Wallet History adds an Incentive badge (`WalletTransaction.isIncentive`); Host Details' Withdrawal History tab lists the host's `hostPayouts` (open, pending, paid and failed, with the period) newest `createdAt` first (the query is only `hostId` ordered by `createdAt`, served by the `hostId` + `createdAt` index; forfeited records, and an `open` cycle whose `withdrawable.totalAmount` is ₹0 (within `PayoutSettings.amountTolerance`; a new cycle whose earnings are all from today until the next daily roll, or an old open record without `withdrawable`; negative amounts stay listed), are dropped in the app through `Withdrawal.isListed`, because a `status` filter would need a `hostId` + `status` + `createdAt` index that is not deployed; the tab count adds one `hostId` + `status` count for pending, success and failed and reads the host's open records to count only the listed ones), its Wallet History tab lists the host's `ledger` entries (`uid` is the host's document ID; `call_earning`, `host_admin_credit`, `host_admin_debit`, `host_payout`; zero amounts are skipped), both loading 10 at a time when the tab first opens, and its stat cards come from aggregations: Total Successful Withdrawals is the host's stored `hostDetails.hostEarnings.totalWithdrawel` (which `completeHostPayouts` adds each paid payout's `totalAmount`, before TDS, to once), falling back to `hostDetails.totalWithdrawn` and then to the sum of `totalAmount` on `success` `hostPayouts` (`HostDetailsState.successfulWithdrawals`); the payout totals are added up by status in the app from one `hostId` equality read of `hostPayouts` (`HostEarningsRemoteDataSource.fetchTotals`), because `sum()` with `hostId` + `status` filters needs a `hostId` + `status` + `totalAmount` index that is not deployed, Total Revenue is `hostDetails.hostEarnings.totalEarnings` on the host's `users` document (falling back to `totalCallsEarnings`, and to the misspelled `hostEarings` map on older hosts; `HostManagementRepository.hostEarningsOf`), and Total Pending Withdrawals sums `totalAmount` on the host's `pending` and `failed` `hostPayouts` (moved to payment but not paid yet; `HostEarningsTotals.awaitingPaymentTotal`, read by `HostDetailsState.pendingWithdrawals`; not Total Revenue − Successful, because `totalEarnings` counts call earnings only while payouts include admin credits and debits; the Available Wallet Amount, which also covers the open cycle, is the Credit / Debit dialog's debit limit), and Total Credit / Debit From Admin add up the host's `host_admin_credit` / `host_admin_debit` `ledger` entries every time the page loads and after every credit / debit (`HostEarningsRepository.fetchLedgerAdjustments`, the same query as the Wallet History tab; debits are stored negative and shown positive; a just-made adjustment shows at once, and a failed reload keeps the figures shown), because every adjustment has a ledger entry while the stored `hostEarnings.totalAdminCredit` / `totalAdminDebit` only cover adjustments since the backend update unless its backfill has run; the stored values are shown only until the ledger total loads; Available Wallet Amount is `hostDetails.hostEarnings.availableBalance` from the same map (settlement and admin credits add to it, admin debits and paid payouts take from it, and it is 0 once a deleted host's balance is forfeited), rupee amounts the calling app writes unrounded. The page re-reads the host document (`HostEarningsRepository.fetchHost`) and reloads the totals when it opens and after every credit / debit, passing the fresh host back to the Host List; a failed reload clears the totals to "—" rather than keeping old figures. The Host List's wallet column also shows `hostDetails.hostEarnings.availableBalance`, not the user-side `walletBalance` coin wallet. The Recharge History tab on User Details lists the selected user's Firestore `transactions` (always filtered by `userId`), 10 at a time with cursors, newest `createdAt` first, loading only when the tab first opens; `RechargeSearch` turns the search text into an exact amount (`rechargeAmount`, `adminCreditAmount` or `adminDebitAmount`), `razorpayOrderId` or `razorpayPaymentId` match, a `status` query, a document ID lookup, or an in-app payment method check. The Call History tab on User Details and Host Details lists the root `calls` documents whose `customerId` (user) or `hostId` (host) is that `users` document ID, through the shared `CallHistoryCubit` and `CallHistoryPanel` in `lib/features/calls/` (`CallParticipant` picks the field), 10 at a time with cursors through `CursorPager`, newest `createdAt` first, loading with the page; the All / Audio / Video filter (`callType`) and the date filter (Single Date, today by default, or Date Range, yesterday to today by default) are in the Firestore query (the `customerId` / `hostId` + `createdAt` and + `callType` + `createdAt` indexes are in `firestore.indexes.json`), a count query gives the filtered total shown in the filter bar and footer, and another gives the tab badge's all-time total; above the filter bar both Call History tabs show `DefaultCallRateCards`, four compact single-line chips ("label  ₹x/min" in `tableFootnote`, `statTileBackground`, wrapping on narrow screens), through `CallHistoryPanel.header`,: Default Host / Admin Audio / Video Call Revenue, the configured per-minute `setHostPrice.audio` / `video` `hostAmount` / `adminAmount` from `settings/app` (surge not included), read through the same `CallPricingCubit` Host Management uses, provided on both details pages and reloaded by their Refresh buttons; the user and host Call History tables show the call's `hostEarnings` / `adminEarnings` as Total Host Revenue / Total Admin Revenue (their per-minute Host Revenue / Admin Revenue columns were removed; `CallLog.hostRatePerMinute` / `adminRatePerMinute` are kept), while the Calls list still shows the per-minute rates as Host Revenue / Admin Revenue; all three end with Call ID (no Session ID column; `CallLog.sessionId` is the call's `channelId`, falling back to the call ID like the calling app's `CallModel`). Sign-in uses Firebase email/password through `lib/features/auth/` and only admits accounts with the `admin` custom claim, which `tool/create_admin/` grants, and the top-bar profile chip opens a Logout menu; User Management and Host Management list real records from the Firestore `users` collection by `role` through `lib/core/data/`, 10 at a time with cursors through `lib/core/data/cursor_pager.dart`, newest `createdAt` first, with search and filters in the Firestore query (search is a "starts with" match on the name (`hostDetails.userName` for hosts, top-level `userName` for users; lowercase or as typed), `userID` (uppercase) or `phoneNumber` (digits, also the last 10 digits): `UsersRemoteDataSource.searchUsers` runs one range query per prefix from `lib/core/data/user_search.dart` (up to 100 results each) with the status filters, merges and sorts them newest `createdAt` first, and the repositories page through them locally with `LocalPageCursor`; this needs the `role` + filter fields + searched field composite indexes in `firestore.indexes.json`; `searchKeywords` is no longer used by these two lists), User Management's Recharges column is each listed user's number of completed recharges (`transactions` with that `userId`, `type` `recharge` and `status` `success`, gateway and admin alike, never `welcomeBonus` or admin credits / debits), one equality-only count query per user on the page shown through `RechargeRemoteDataSource.fetchCompletedRechargeCounts` (served by the existing `userId` + `type` + `status` + `createdAt` index; `UserManagementRepository` takes it as the optional `recharges` parameter), shown as `—` when counting fails without failing the list, and User Details passes its `UserRechargeSummary.rechargeCount` back to the row once its totals load, so an admin recharge updates the column, and their edit, block, unblock and delete actions update those documents by ID, with delete being a soft delete (`isAccountDeleted` plus `deletedBy: "admin"`); the other modules are not built yet.

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
- Wherever a user or host avatar sits beside their name, show their profile picture (the `users` document's `avatharImage`, read through `UserRecord.profileImageUrl`), falling back to initials. When the user record is already loaded, pass the URL to `AppInitialsAvatar.imageUrl` (or `AppAvatarNameCell.imageUrl` / `AppProfileHeader.imageUrl`); when only the ID is known, use `AppUserPhotoAvatar` (or `AppAvatarNameCell.photoUserId`), which batches lookups through `ProfilePhotoLookup` and caches them for the session. Admin accounts have no picture and keep initials.

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
- Show every user or host ID and phone number in `AppTextStyles.identifier` (tables, detail panels, profile fields; `identifier: true` on `AppDetailItem` / `AppMetaField`) or `AppTextStyles.identifierSmall` (the line under a person's name). Other technical values (order, payment, call and withdrawal IDs, account numbers, IFSC) stay in `mono` / `monoSmall`. The bundled DM Sans has no tabular figures, so `identifier`'s `tabularFigures` feature takes effect only after the font files are updated.
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
- A system or browser back gesture never leaves the app or returns to the login page: `AppRoutes.onGenerateInitialRoutes` builds the stack for the browser URL without the login route underneath (`/users/details` opens as User Management plus User Details, and a query string such as `?id=…` stays on the last route, read with `AppRoutes.recordIdOf`; routes are matched by path; `/` or an unknown URL opens login), `AppPageRoute.popDisposition` turns the first route's `bubble` into `doNotPop`, and `AdminAccessGate` sends a back gesture on the first route to the admin's `homeRoute` (the Dashboard), doing nothing when already there. Pushed pages still pop normally. The login page is reached only by logging out or by a signed-out session (`AdminAccessGate`'s redirect).
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
