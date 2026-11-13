abstract final class AppStrings {
  static const String appName = 'Zuno';
  static const String adminPanel = 'Admin Panel';

  static const String loginHeadingLead = 'Run calls, hosts and\n';
  static const String loginHeadingHighlight = 'coins';
  static const String loginHeadingTail = ' from one place.';
  static const String loginDescription =
      'Manage users and hosts, review approvals, track recharges and process '
      'host withdrawals.';
  static const String secureAdminLogin = 'Secure admin login';
  static const String approvedAdminsOnly = 'Approved admins only';

  static const String adminSignIn = 'Admin sign in';
  static const String welcomeBack = 'Welcome back';
  static const String email = 'Email';
  static const String emailHint = 'name@company.com';
  static const String password = 'Password';
  static const String passwordHint = 'Enter your password';
  static const String show = 'Show';
  static const String hide = 'Hide';
  static const String dashboard = 'Dashboard';
  static const String userManagement = 'User Management';
  static const String hostManagement = 'Host Management';
  static const String calls = 'Calls';
  static const String approval = 'Approval';
  static const String reports = 'Reports';
  static const String packages = 'Packages';
  static const String recharge = 'Recharge';
  static const String payment = 'Payment';
  static const String settings = 'Settings';
  static const String signedInAs = 'Signed in as';

  static const String today = 'Today';
  static const String customDateRange = 'Custom Date Range';
  static const String dateRangeSeparator = 'to';
  static const String apply = 'Apply';
  static const String selectStartDate = 'Select a start date';
  static const String selectEndDate = 'Select an end date';
  static const String previousMonth = 'Previous month';
  static const String nextMonth = 'Next month';
  static const String previousYear = 'Previous year';
  static const String nextYear = 'Next year';

  static String dateRangeSummary(String range, int days) =>
      '$range · $days ${days == 1 ? 'day' : 'days'}';
  static const String revenueSummary = 'Revenue Summary';
  static const String userStatistics = 'User Statistics';
  static const String callStatistics = 'Call Statistics';
  static const String recentRechargeActivity = 'Recent Recharge Activity';
  static const String viewAllRecharges = 'View all recharges';
  static const String userName = 'User Name';
  static const String userId = 'User ID';
  static const String rechargeAmount = 'Recharge Amount';
  static const String rechargeTime = 'Recharge Time';

  static const String topUpRevenue = 'Top-up Revenue';
  static const String hostAudioCallRevenue = 'Host Audio Call Revenue';
  static const String hostVideoCallRevenue = 'Host Video Call Revenue';
  static const String adminCallRevenue = 'Admin Call Revenue';
  static const String deletedAccountProfit = 'Deleted Account Profit';
  static const String totalAdminRevenue = 'Total Admin Revenue';
  static const String totalUsers = 'Total Users';
  static const String totalHosts = 'Total Hosts';
  static const String deletedUsers = 'Deleted Users';
  static const String deletedHosts = 'Deleted Hosts';
  static const String freeBonusReceivedUsers = 'Free Bonus Received Users';
  static const String freeBonusAmount = 'Free Bonus Amount';
  static const String incomingCalls = 'Incoming Calls';
  static const String answeredCalls = 'Answered Calls';
  static const String rejectedCalls = 'Rejected Calls';
  static const String missedCalls = 'Missed Calls';
  static const String totalTalkingMinutes = 'Total Talking Minutes';

  static const String searchUsersHint = 'Search mobile, name or user ID';
  static const String allUsers = 'All Users';
  static const String newUsers = 'New Users';
  static const String blockedUsers = 'Blocked Users';
  static const String deletedByAdminFilter = 'Deleted by admin';
  static const String deletedByUserFilter = 'Deleted by user';
  static const String createdDate = 'Created Date';
  static const String name = 'Name';
  static const String phoneNumber = 'Phone Number';
  static const String recharges = 'Recharges';
  static const String walletBalance = 'Wallet Balance';
  static const String takeAction = 'Take Action';
  static const String coins = 'coins';
  static const String noActions = 'No actions';
  static const String newUser = 'New user';
  static const String blocked = 'Blocked';
  static const String deletedByAdmin = 'Deleted by Admin';
  static const String deletedByUser = 'Deleted by User';
  static const String deletedByHost = 'Deleted by Host';
  static const String edit = 'Edit';
  static const String block = 'Block';
  static const String delete = 'Delete';
  static const String noUsersFound = 'No users found';

  static String showingRange(int start, int end, int total) =>
      'Showing $start–$end of $total';

  static String showingWindow(int start, int end) => 'Showing $start–$end';

  static const String editUserDetails = 'Edit user details';
  static const String userNameField = 'User name';
  static const String registeredMobileNumber = 'Registered mobile number';
  static const String userIdCannotBeChanged = 'User ID cannot be changed.';
  static const String cancel = 'Cancel';
  static const String saveChanges = 'Save changes';
  static const String userDetailsUpdated = 'User details updated';
  static const String done = 'Done';

  static String editUserSubtitle(String userId, String createdDate) =>
      '$userId · Created $createdDate';

  static String userDetailsSaved(String name) =>
      "$name's details have been saved.";

  static const String blockUserAction = 'Block user';
  static const String blockUserMessage =
      'Blocked users cannot sign in, call or message hosts.';
  static const String deleteAccountAction = 'Delete account';
  static const String deleteAccountMessageLead = 'The account moves to ';
  static const String deleteAccountMessageTail = '. This cannot be undone.';

  static String blockUserTitle(String name) => 'Block $name?';

  static String deleteAccountTitle(String name) => "Delete $name's account?";

  static const String userDetails = 'User Details';
  static const String backToUsers = 'Back to users';
  static const String active = 'Active';
  static const String accountCreatedDate = 'Account Created Date';
  static const String lastOnline = 'Last Online';
  static const String totalRecharge = 'Total Recharge';
  static const String availableCoins = 'Available Coins';
  static const String availableCoinsAmount = 'Available Coins Amount';
  static const String receivableTopUp = 'Receivable Top-up';
  static const String totalCreditFromAdmin = 'Total Credit Amount From Admin';
  static const String totalDebitFromAdmin = 'Total Debit Amount From Admin';
  static const String deletedAccountAdminProfit =
      'Deleted Account Admin Profit';
  static const String callHistory = 'Call History';
  static const String rechargeHistory = 'Recharge History';
  static const String all = 'All';
  static const String audio = 'Audio';
  static const String video = 'Video';
  static const String singleDate = 'Single date';
  static const String dateRange = 'Date range';
  static const String scrollSidewaysHint = 'Scroll sideways for revenue fields';
  static const String date = 'Date';
  static const String hostName = 'Host Name';
  static const String type = 'Type';
  static const String callInitiatedTime = 'Call Initiated Time';
  static const String callStartTime = 'Call Start Time';
  static const String callEndTime = 'Call End Time';
  static const String callEndedBy = 'Call Ended By';
  static const String callStatus = 'Call Status';
  static const String callDuration = 'Call Duration';
  static const String userSpendCoinsAmount = 'User Spend Coins Amount';
  static const String totalUserSpendAmount = 'Total User Spend Amount';
  static const String hostRevenue = 'Host Revenue';
  static const String completed = 'Completed';
  static const String rejected = 'Rejected';
  static const String notAnswered = 'Not Answered';
  static const String lowBalance = 'Low Balance';
  static const String searchRechargesHint =
      'Search ID, amount, method or status';
  static const String searchRechargeTransactionsHint =
      'Search name, phone or recharge amount';
  static const String creditDebitWallet = 'Credit / Debit Wallet';
  static const String addRecharge = 'Add Recharge';
  static const String time = 'Time';
  static const String adminCreditAmount = 'Admin Credit Amount';
  static const String adminDebitAmount = 'Admin Debit Amount';
  static const String receivedCoins = 'Received Coins';
  static const String paymentId = 'Payment ID';
  static const String orderId = 'Order ID';
  static const String status = 'Status';
  static const String emptyValue = '—';
  static const String noRecordsFound = 'No records found';

  static String callsCount(int count) => '$count calls';

  static String showingOf(int shown, int total) => 'Showing $shown of $total';

  static const String choosePackage = 'Choose a package';
  static const String continueAction = 'Continue';
  static const String confirmRecharge = 'Confirm recharge';
  static const String addRechargeAction = 'Add recharge';
  static const String package = 'Package';
  static const String coinsLabel = 'Coins';
  static const String offer = 'Offer';
  static const String coinsAdded = 'Coins added';
  static const String rechargeAdded = 'Recharge added';
  static const String confirmRechargeLead = 'Add this recharge to ';
  static const String confirmRechargeTail = "'s wallet?";

  static String rechargeSubtitle(String name, String userId) =>
      '$name · $userId';

  static String packageLabel(String price, String name) => '$price · $name';

  static const String adminRechargeFailed =
      'Could not add this recharge. Try again.';

  static String coinsWithBonus(String coins, String? bonus) =>
      bonus == null ? '$coins coins' : '$coins coins · +$bonus Bonus';

  static String bonusLabel(String bonus) => '+$bonus Bonus';

  static String coinsAddedToWallet(String coins, String name) =>
      "$coins coins were added to $name's wallet.";

  static const String hostList = 'Host List';
  static const String surgeChargeSessions = 'Surge Charge Sessions';
  static const String setCallMessagePrice = 'Set call & message price';
  static const String searchHostsHint = 'Search mobile, name or host ID';
  static const String allHosts = 'All Hosts';
  static const String newHosts = 'New Hosts';
  static const String blockedHosts = 'Blocked Hosts';
  static const String hostId = 'Host ID';
  static const String inactive = 'Inactive';
  static const String newLabel = 'New';
  static const String noHostsFound = 'No hosts found';
  static const String editHostDetails = 'Edit host details';
  static const String hostDetailsUpdated = 'Host details updated';
  static const String blockHostAction = 'Block host';
  static const String blockHostMessage =
      'Blocked hosts cannot sign in, receive calls or reply to messages.';

  static const String pricingSubtitle =
      'Set the admin and host amounts for audio and video calls, and the admin amount for messages.';
  static const String audioCallRateField = 'Audio call (₹ per minute)';
  static const String videoCallRateField = 'Video call (₹ per minute)';
  static const String messageRateField = 'Message (₹ per message)';
  static const String savePrices = 'Save prices';

  static String audioRateSummary(String amount) => 'Audio $amount/min';

  static String videoRateSummary(String amount) => 'Video $amount/min';

  static String messageRateSummary(String amount) => 'Message $amount';

  static const String hostDetails = 'Host Details';
  static const String backToHosts = 'Back to hosts';
  static const String online = 'Online';
  static const String offline = 'Offline';
  static const String hostUploadedDocuments = 'Host Uploaded Documents';
  static const String aadhaarCard = 'Aadhaar card';
  static const String aadhaarCardFront = 'Aadhaar card · Front';
  static const String selfie = 'Selfie';
  static const String totalRevenue = 'Total Revenue';
  static const String totalSuccessfulWithdrawals =
      'Total Successful Withdrawals';
  static const String totalPendingWithdrawals = 'Total Pending Withdrawals';
  static const String availableWalletAmount = 'Available Wallet Amount';
  static const String withdrawalHistory = 'Withdrawal History';
  static const String walletHistory = 'Wallet History';
  static const String busy = 'Busy';

  static const String credit = 'Credit';
  static const String debit = 'Debit';
  static const String amount = 'Amount';
  static const String description = 'Description';
  static const String typeHint = 'Type';
  static const String save = 'Save';
  static const String enterAmount = 'Enter an amount.';

  static const String withdrawDate = 'Withdraw Date';
  static const String callCount = 'Call Count';
  static const String amountEarned = 'Amount Earned';
  static const String surgeChargeSession = 'Surge Charge Session';
  static const String withdrawAmount = 'Withdraw Amount';
  static const String branchName = 'Branch Name';
  static const String accountHolderName = 'Account Holder Name';
  static const String accountNumber = 'Account Number';
  static const String ifscCode = 'IFSC Code';
  static const String withdrawId = 'Withdraw ID';
  static const String pending = 'Pending';
  static const String success = 'Success';
  static const String creditDebit = 'Credit / Debit';
  static const String walletBalanceTooLow =
      "This debit is more than the user's current wallet balance.";
  static const String adminCredit = 'Admin credit';
  static const String adminDebit = 'Admin debit';

  static String minutes(int count) => '$count min';

  static const String close = 'Close';
  static const String fullNameField = 'Full name';
  static const String nickNameField = 'Nick name';
  static const String mobileNumberField = 'Mobile number';
  static const String dateOfBirthField = 'Date of birth';
  static const String districtField = 'District';
  static const String stateField = 'State';
  static const String genderField = 'Gender';
  static const String motherTongueField = 'Mother tongue';
  static const String speakLanguagesField = 'Speak languages';
  static const String selectHint = 'Select';
  static const String female = 'Female';
  static const String male = 'Male';
  static const String otherGender = 'Other';
  static const String english = 'English';
  static const String malayalam = 'Malayalam';
  static const String tamil = 'Tamil';
  static const String hindi = 'Hindi';
  static const String kannada = 'Kannada';
  static const String telugu = 'Telugu';

  static String documentPreviewTitle(String document, String name) =>
      '$document · $name';

  static const String peakHourSurgeCharges = 'Peak-hour surge charges';
  static const String surgeIntro =
      'Set a start and end time for each session. During an active session '
      'the surge charge applies automatically, and users see it before they '
      'start a call. Changes go live without an app update.';
  static const String createSession = 'Create session';
  static const String session = 'Session';
  static const String startTime = 'Start Time';
  static const String endTime = 'End Time';
  static const String surgeCharge = 'Surge Charge';
  static const String shownToUsersBeforeCall = 'Shown to users before a call';
  static const String actions = 'Actions';
  static const String enabled = 'Enabled';
  static const String disabled = 'Disabled';
  static const String noSurgeSessions = 'No surge sessions yet';
  static const String createSurgeSession = 'Create surge session';
  static const String editSurgeSession = 'Edit surge session';
  static const String surgeSheetSubtitle = 'Peak-hour start and end time';
  static const String startTimeField = 'Start time';
  static const String endTimeField = 'End time';
  static const String surgeChargeField = 'Surge charge (%)';
  static const String surgeChargeHint = 'e.g. 20';
  static const String surgeChargeHelper =
      'Added on top of the call price during this session.';
  static const String saveSession = 'Save session';
  static const String enterSurgeCharge = 'Enter a surge charge.';
  static const String endTimeMustDiffer =
      'End time must be different from the start time.';
  static const String surgePreviewLead = 'Users will see ';
  static const String removeSurgeSessionTitle = 'Remove this surge session?';
  static const String removeSession = 'Remove session';

  static const String sessionNameField = 'Session name';
  static const String sessionNameHint = 'e.g. Peak Hours';
  static const String enterSessionName = 'Enter a session name.';
  static const String selectTime = 'Select a time.';
  static const String sessionNameTaken =
      'Another surge session already uses this name.';
  static const String surgeSessionsBusy =
      'Surge sessions are still loading or saving. Try again in a moment.';

  static const String yesterday = 'Yesterday';
  static const String day = 'Day';
  static const String week = 'Week';
  static const String month = 'Month';
  static const String completedCalls = 'Completed Calls';
  static const String busyCalls = 'Busy Calls';
  static const String notAnsweredCalls = 'Not Answered Calls';
  static const String lowBalanceCalls = 'Low Balance Calls';
  static const String callsType = 'Calls Type';
  static const String audioCall = 'Audio Call';
  static const String videoCall = 'Video Call';
  static const String totalCalls = 'Total Calls';
  static const String number = 'Number';
  static const String spendInrChat = 'Spend INR Chat';
  static const String adminRevenue = 'Admin Revenue';
  static const String missed = 'Missed';
  static const String noCallsFound = 'No calls found';
  static const String searchCallsHint =
      'Search user or host name, user mobile or host ID';
  static const String callNotFound =
      'Open a call from the Calls list to see its details.';
  static const String ringing = 'Ringing';
  static const String ongoing = 'Ongoing';
  static const String systemRole = 'System';
  static const String noAnswerReason = 'no answer';
  static const String hostUnreachableReason = 'host unreachable';
  static const String connectionFailedReason = 'connection failed';
  static const String connectionLostReason = 'connection lost';
  static const String timeLimitReason = 'time limit reached';

  static String endedByReason(String party, String reason) =>
      '$party – $reason';

  static String scrollSidewaysForFields(int count) =>
      'Scroll sideways to see all $count call fields';

  static String perMinute(String amount) => '$amount/min';

  static String hostWithCallType(String type) => ' · $type';

  static const String callDetails = 'Call Details';
  static const String backToCalls = 'Back to calls';
  static const String audioCallTitle = 'Audio call';
  static const String videoCallTitle = 'Video call';
  static const String callTimeline = 'Call timeline';
  static const String userSpend = 'User spend';
  static const String revenueSplit = 'Revenue split';
  static const String callId = 'Call ID';
  static const String sessionId = 'Session ID';
  static const String callTypeField = 'Call type';
  static const String totalHostRevenue = 'Total Host Revenue';
  static const String userRole = 'User';
  static const String hostRole = 'Host';
  static const String metaSeparator = ' · ';

  static String coinsAmount(String coins) => '$coins coins';

  static const String hostRequests = 'Host Requests';
  static const String payoutReview = 'Payout Review';
  static const String profilePhotoReview = 'Profile Photo Review';
  static const String filters = 'Filters';
  static const String allDates = 'All Dates';
  static const String last7Days = 'Last 7 Days';
  static const String last30Days = 'Last 30 Days';
  static const String realName = 'Real Name';
  static const String nickName = 'Nick Name';
  static const String mobileNumber = 'Mobile Number';
  static const String dateOfBirth = 'Date of Birth';
  static const String city = 'City';
  static const String gender = 'Gender';
  static const String speakLanguages = 'Speak Languages';
  static const String review = 'Review';
  static const String approved = 'Approved';
  static const String noHostRequests = 'No host requests found';
  static const String hostRequest = 'Host request';
  static const String reject = 'Reject';
  static const String approve = 'Approve';
  static const String view = 'View';
  static const String hostRequestApproved = 'Host request approved';
  static const String statusNowSuffix = '.';

  static String statusNowLead(String name) => 'Status for $name is now ';

  static const String accountHolderNameField = 'Account Holder Name';
  static const String noPayoutRequests = 'No payout requests found';
  static const String payoutChanged =
      'This account was already reviewed or changed. Reload the page to see '
      'the latest request.';
  static const String payoutReviewTitle = 'Payout review';
  static const String hostBasicInfo = 'Host basic info';
  static const String bankAccount = 'Bank account';
  static const String realNameField = 'Real name';
  static const String location = 'Location';
  static const String viewHost = 'View host';
  static const String accept = 'Accept';
  static const String accepted = 'Accepted';
  static const String acceptPayoutTitle = 'Accept payout request?';
  static const String rejectPayoutTitle = 'Reject payout request?';

  static String acceptPayoutMessage(String name, String lastDigits) =>
      "$name's payout to the account ending $lastDigits will be accepted.";

  static String rejectPayoutMessage(String name) =>
      "$name's payout request will be rejected.";

  static const String noProfilePhotos = 'No profile photos to review';
  static const String profilePhotoChanged =
      'This photo was already reviewed or replaced. Reload the page to see '
      'the latest request.';
  static const String acceptPhotoTitle = 'Accept profile photo?';
  static const String rejectPhotoTitle = 'Reject profile photo?';

  static String acceptPhotoMessage(String name) =>
      "The new photo will appear on $name's profile.";

  static String rejectPhotoMessage(String name) =>
      "$name's new photo will be rejected and the current photo stays.";

  static String languagesSubmitted(String languages, String date) =>
      [if (languages.isNotEmpty) languages, 'Submitted $date'].join(' · ');

  static const String allReportTypes = 'All report types';
  static const String askingPersonalDetails = 'Asking personal details';
  static const String offensiveLanguage = 'Offensive or abusive language';
  static const String inappropriateBehavior = 'Inappropriate behavior';
  static const String requestingPersonalDetails = 'Requesting personal details';
  static const String notResponding = 'Not responding during call';
  static const String moneyRequests = 'Money requests or scam';
  static const String otherReason = 'Other';
  static const String reportedByName = 'Reported by Name';
  static const String reported = 'Reported';
  static const String reportType = 'Report Type';
  static const String receivedTotalReportCount = 'Received Total Report Count';
  static const String noReportsFound = 'No reports found';

  static const String packageList = 'Package List';
  static const String couponList = 'Coupon List';
  static const String addPackage = 'Add Package';
  static const String addPackageTitle = 'Add package';
  static const String editPackageTitle = 'Edit package';
  static const String packageSheetSubtitle =
      'Show on the recharge screen in the user app';
  static const String payableAmount = 'Payable Amount';
  static const String receivableAmount = 'Receivable Amount';
  static const String receivableCoin = 'Receivable Coin';
  static const String offerTag = 'Offer Tag';
  static const String offerPercentage = 'Offer %';
  static const String offerPercentageField = 'Offer Percentage (%)';
  static const String offerPercentageTooHigh = 'Enter 100 or less.';
  static const String packageActiveTitle = 'Active';
  static const String packageActiveHelper =
      'Only active packages are shown in the user app';
  static const String payableAmountField = 'Payable Amount (₹)';
  static const String receivableAmountField = 'Receivable Amount (₹)';
  static const String gstToggleTitle = 'GST (18%)';
  static const String gstToggleHelper =
      'Enter either amount and the other one is calculated for you';
  static const String offerHelper =
      'Optional. The offer tag is shown on the pack.';
  static const String preview = 'Preview';
  static const String refreshPreview = 'Refresh preview';
  static const String savePackage = 'Save package';
  static const String previewBlank = '__';
  static const String enterValue = 'Enter a value.';
  static const String noPackages = 'No packages yet';
  static const String noPackagesMessage =
      'Add a package to show it on the recharge screen in the user app.';

  static const String previewOfferBlank = '+__ Bonus';
  static const String packageUpdated = 'Package updated';

  static const String totalRechargeCount = 'Total Recharge Count';
  static const String totalRechargeAmount = 'Total Recharge Amount';
  static const String totalCreditAmount = 'Total Credit Amount';
  static const String totalDebitAmount = 'Total Debit Amount';
  static const String paymentGateway = 'Payment Gateway';
  static const String adminRecharges = 'Admin Recharges';
  static const String admin = 'Admin';
  static const String razorpay = 'Razorpay';
  static const String withdrawalList = 'Withdrawal List';
  static const String pendingWithdrawals = 'Pending Withdrawals';
  static const String successfulWithdrawals = 'Successful Withdrawals';
  static const String pendingTab = 'Pending';
  static const String successTab = 'Success';
  static const String upcomingWithdrawalOverview =
      'Upcoming Withdrawal Overview';
  static const String duration = 'Duration';
  static const String minutesUnit = 'min';
  static const String totalHostCredit = 'Total Host Credit';
  static const String totalHostRevenueStat = 'Total Host Revenue';
  static const String totalWithdraw = 'Total Withdraw';
  static const String searchWithdrawalsHint =
      'Search host, host ID or withdraw ID';
  static const String exportWithdrawalSheet = 'Export Withdrawal Sheet';
  static const String totalCallsCount = 'Total Calls Count';
  static const String callDurationMinutes = 'Call Duration (min)';
  static const String totalAmount = 'Total Amount';
  static const String withdraw = 'Withdraw';
  static const String noWithdrawals = 'No withdrawals found';
  static const String withdrawalDetails = 'Withdrawal details';
  static const String earnings = 'Earnings';
  static const String bank = 'Bank';
  static const String reviewWithdrawalTitle = 'Review withdrawal';
  static const String reviewWithdrawalPrefix = 'Confirm the withdrawal for ';
  static const String totalReceivableAmount = 'Total Receivable Amount';
  static const String confirmWithdrawal = 'Confirm withdrawal';
  static const String withdrawalCompleted = 'Withdrawal completed';
  static const String withdrawalAmount = 'Withdrawal Amount';
  static const String tdsCutAmount = 'TDS Cut Amount';
  static const String appliedTdsPercent = 'Applied TDS %';
  static const String withdrawStatus = 'Withdraw Status';
  static const String exportComplete = 'Export complete';
  static const String ready = 'Ready';
  static const String exportScopeAll = 'all';
  static const String exportScopePending = 'pending';
  static const String exportScopeSuccess = 'success';

  static String withdrawalOverviewNote(int hosts, String minimum) =>
      '$hosts hosts waiting · minimum withdrawal $minimum';

  static String dotSeparated(String first, String second) => '$first · $second';

  static String minutesValue(String minutes) => '$minutes min';

  static String reviewWithdrawalSuffix(String hostId) => ' ($hostId).';

  static String ifscSuffix(String ifscCode) => ' ·$ifscCode';

  static String percentValue(int percent) => '$percent%';

  static String withdrawalsExported(int count) =>
      '$count withdrawals were exported.';

  static String withdrawalSheetRows(int count) =>
      'Withdrawal sheet · $count rows';

  static String withdrawalSheetFileName(String scope, String date) =>
      'withdrawal-sheet-$scope-$date.xlsx';

  static String tdsLabel(int percent) => 'TDS ($percent%)';

  static String deduction(String amount) => '– $amount';

  static String withdrawalCompletedMessage(String amount, String hostName) =>
      '$amount has been sent to $hostName\'s account. You can find it under '
      'Success.';

  static const String adminCreditDebit = 'Admin Credit & Debit';
  static const String gatewayPayments = 'Payment Gateway Payments';
  static const String failed = 'Failed';
  static const String created = 'Created';
  static const String rechargeDetails = 'Recharge details';
  static const String viewUser = 'View user';
  static const String creditAmount = 'Credit Amount';
  static const String debitAmount = 'Debit Amount';
  static const String noRechargesFound = 'No recharges found';
  static const String noRecentRechargesMessage =
      'Successful recharges will appear here as soon as they are completed.';
  static const String maintenanceMode = 'Maintenance Mode';
  static const String adminManagement = 'Admin Management';
  static const String notificationManagement = 'Notification Management';
  static const String bannerImageManagement = 'Banner Image Management';
  static const String maintenanceModeIs = 'Maintenance mode is ';
  static const String maintenanceOff = 'off';
  static const String maintenanceOn = 'on';
  static const String maintenanceAvailableTail =
      '. The user and host apps are available.';
  static const String maintenanceUnavailableTail =
      '. The user and host apps are unavailable.';
  static const String maintenanceNote =
      'Turn this on during planned updates. A banner in the top bar shows '
      'while maintenance mode is on.';
  static const String turnOnMaintenanceTitle = 'Turn on maintenance mode?';
  static const String turnOnMaintenanceMessage =
      'The user and host apps will be unavailable until you turn it off.';
  static const String turnOffMaintenanceTitle = 'Turn off maintenance mode?';
  static const String turnOffMaintenanceMessage =
      'The user and host apps will be available again.';
  static const String turnOn = 'Turn on';
  static const String turnOff = 'Turn off';
  static const String maintenanceModeIsOn = 'Maintenance mode is on';
  static const String maintenanceOnMessage =
      'The apps are now unavailable to users and hosts.';
  static const String addAdmin = 'Add admin';
  static const String role = 'Role';
  static const String permissions = 'Permissions';
  static const String allModules = 'All modules';
  static const String superAdmin = 'Super Admin';
  static const String financeAdmin = 'Finance Admin';
  static const String supportAdmin = 'Support Admin';
  static const String moderator = 'Moderator';

  static const String addAdminSubtitle =
      'Give a team member access to the admin panel';
  static const String editAdmin = 'Edit admin';
  static const String editAdminSubtitle =
      "Update this team member's access to the admin panel";
  static const String saveAdmin = 'Save admin';
  static const String permissionsHelper =
      'Choose which modules this admin can open.';
  static const String enterName = 'Enter a name.';
  static const String enterValidEmail = 'Enter a valid email.';
  static const String enterValidPhone = 'Enter a valid phone number.';
  static const String chooseModule = 'Choose at least one module.';
  static const String adminEmailExists =
      'An admin with this email already exists.';
  static const String adminPasswordHelper =
      'At least 6 characters. Share it with the admin so they can sign in. '
      'If this email already has a login, its current password is kept.';
  static const String editAdminPasswordHelper =
      'Optional. Creates a login with this password if the admin does not '
      'have one yet. Leave blank to keep their current login.';
  static const String adminLoginExists =
      'This admin already has a login, and its password cannot be changed '
      'here. Clear the password field to save the other changes.';
  static const String passwordTooShort = 'Use at least 6 characters.';
  static const String adminLoginWeakPassword =
      'This password was rejected. Choose a stronger one.';
  static const String adminLoginsDisabled =
      'Email and password sign-in is turned off for this project.';
  static const String adminLoginCreateFailed =
      'Could not create the login for this admin. Try again.';
  static const String noAdminsTitle = 'No admins yet';
  static const String noAdminsMessage =
      'Add a team member to give them access to the admin panel.';
  static const String superAdminsManageAdmins =
      'Only super admins can add or edit admins.';
  static const String noModuleAccessTitle = 'No access to this module';
  static const String noModuleAccessMessage =
      'Your account does not have permission to open this module. Ask a '
      'super admin to update your permissions in Settings.';
  static const String loginNoAccess =
      'This account has not been given access to the admin panel. Ask a '
      'super admin to add you in Settings > Admin Management.';
  static const String sendTo = 'Send to';
  static const String userAudience = 'User';
  static const String hostAudience = 'Host';
  static const String bothAudience = 'Both';
  static const String hostMotherTongue = 'Host mother tongue';
  static const String hostMotherTongueHelper =
      'Send only to hosts whose mother tongue matches. Leave empty to send to '
      'all hosts.';
  static const String notificationTitle = 'Title';
  static const String notificationTitleHint = 'e.g. New bonus packs are live';
  static const String notificationMessage = 'Message';
  static const String notificationMessageHint =
      'Write the notification message';
  static const String sendNotification = 'Send notification';
  static const String clear = 'Clear';
  static const String audience = 'Audience';
  static const String usersLabel = 'Users';
  static const String hostsLabel = 'Hosts';
  static const String totalRecipients = 'Total recipients';
  static const String audienceNote =
      'Recipients are counted from all accounts that are not deleted. Type '
      'the title and message, then send to see the confirmation step.';
  static const String enterTitle = 'Enter a title.';
  static const String enterMessage = 'Enter a message.';
  static const String sendNotificationTitle = 'Send this notification?';
  static const String sendNotificationPrefix = 'It will be sent to ';
  static const String sendNotificationSuffix = ' recipients right away.';
  static const String sendNow = 'Send now';
  static const String sendingNotification = 'Sending...';
  static const String notificationSentTitle = 'Notification sent';
  static const String notificationSendFailed =
      'The notification could not be sent. Try again.';
  static const String notificationSendDenied =
      'Your account is not allowed to send notifications.';

  static String notificationSentMessage(String topics) =>
      'Sent to every device subscribed to $topics.';

  static String hostsForLanguages(String languages) => 'Hosts ($languages)';

  static const String screenPlacement = 'Screen placement';
  static const String homeScreen = 'Home Screen';
  static const String rechargeScreen = 'Recharge Screen';
  static const String homeBanner = 'Home Banner';
  static const String rechargeBanner = 'Recharge Banner';
  static const String addBanner = 'Add Banner';
  static const String addBannerImage = 'Add banner image';
  static const String addBannerAction = 'Add banner';
  static const String bannerFormatHint = 'PNG or JPG, wide format';
  static const String bannerDropTitle = 'Click to choose an image';
  static const String bannerDropHint =
      'PNG or JPG up to 5 MB, wide format works best. Click again to change '
      'the image.';
  static const String bannerInvalidType = 'Choose a PNG or JPG image.';
  static const String bannerTooLarge = 'Choose an image of 5 MB or less.';
  static const String bannerPickFailed =
      'Could not open the chosen image. Try another file.';
  static const String bannerUploadFailed =
      'Could not upload the image. Try again.';
  static const String bannerUploadDenied =
      'You do not have permission to upload banner images.';
  static const String addingBanner = 'Adding...';
  static const String deleteBannerTitle = 'Delete this banner?';
  static const String deleteBannerAction = 'Delete banner';
  static String deleteBannerMessageTail(String screen) =>
      ' will be removed from the $screen.';

  static String screenPlacementOf(String screen) => '$screenPlacement: $screen';

  static String bannerScreenCount(String screen, int count) =>
      '$screen · $count';

  static String bannerName(int number) => 'Banner $number';

  static String bannerMeta(
    String fileName,
    String role,
    String screen,
    String? addedOn,
  ) => [
    fileName,
    role,
    screen,
    if (addedOn != null) 'Added $addedOn',
  ].join(' · ');

  static String bannersSummary(int count) =>
      '$count ${count == 1 ? 'banner' : 'banners'} · auto-sliding on each '
      'screen';

  static String adminsCount(int count) => '$count admins';

  static const String couponListPendingTitle =
      'Coupon List fields are not confirmed yet';
  static const String couponListPendingMessage =
      'The proposal lists a Coupon List but not its fields. This tab will '
      'show the coupons once the fields are confirmed.';

  static String packagePriceAndCoins(String price, String coins) =>
      '$price · $coins coins';

  static String packageSaved(String price, String coins) =>
      '$price for $coins coins is saved.';

  static String packagesSummary(int packages, int active) =>
      '$packages packages · $active active';

  static String offerPercentValue(String percent) => '$percent%';

  static String hostRequestSubtitle(String id, String date) =>
      '$id · Submitted $date';

  static String nameAndCity(String nickName, String city) =>
      '$nickName · $city';

  static String dateRangeLabel(String start, String end) => '$start – $end';

  static String participantRole(String role, String id) => '$role · $id';

  static String surgePercent(int percent) => '+$percent%';

  static String surgeUserLabel(int percent) =>
      'Peak hours · +$percent% surge charge';

  static String surgePreviewTail(String start, String end) =>
      ' before starting a call between $start and $end.';

  static String removeSurgeSessionMessage(
    String name,
    String start,
    String end,
    int percent,
  ) => '$name ($start – $end, +$percent%) will stop applying and be removed.';

  static String signedAmount(String amount, {required bool isCredit}) =>
      isCredit ? '+$amount' : '−$amount';

  static String debitExceedsBalance(String balance) =>
      'Debit cannot be more than the wallet balance of $balance.';

  static const String signInSecurely = 'Sign in securely';
  static const String loginFailed =
      'Email or password is incorrect. Check your details and try again. '
      'Only approved admins can sign in.';
  static const String aadhaarFront = 'Aadhaar Front';
  static const String aadhaarBack = 'Aadhaar Back';
  static const String documentAlreadyReviewed =
      'This document has already been reviewed.';
  static const String hostRequestNotReady =
      'This request has changed. Close it and review it again.';
  static const String approveRequestTitle = 'Approve host request?';
  static const String rejectRequestTitle = 'Reject host request?';

  static String approveRequestMessage(String name) =>
      '$name will become an approved host and can sign in to the host app.';

  static String rejectRequestMessage(String name) =>
      "$name's request to become a host will be rejected.";

  static String approveDocumentTitle(String document) => 'Approve $document?';

  static String rejectDocumentTitle(String document) => 'Reject $document?';

  static String approveDocumentMessage(String document, String name) =>
      "$name's $document will be marked as approved. This cannot be changed "
      'here afterwards.';

  static String rejectDocumentMessage(String document, String name) =>
      "$name's $document will be marked as rejected. This cannot be changed "
      'here afterwards.';

  static const String unblock = 'Unblock';
  static const String unblockUserAction = 'Unblock user';
  static const String unblockHostAction = 'Unblock host';
  static const String unblockUserMessage =
      'This user will be able to use their account again.';
  static const String unblockHostMessage =
      'This host will be able to use their account again.';
  static const String saving = 'Saving...';
  static const String recordsSaveFailed =
      'Could not save this change. Try again.';
  static const String recordsWriteDenied =
      'You do not have permission to change this record.';
  static const String recordNotFound = 'This record no longer exists.';

  static String unblockUserTitle(String name) => 'Unblock $name?';

  static const String retry = 'Retry';
  static const String recordsLoadFailed =
      'Could not load these records. Try again.';
  static const String recordsNetworkError =
      'Could not reach the server. Check your connection and try again.';
  static const String recordsAccessDenied =
      'You do not have permission to view these records. Sign in again or '
      'contact your administrator.';
  static const String signingIn = 'Signing in...';
  static const String logout = 'Logout';
  static const String logoutFailed = 'Could not log out. Try again.';
  static const String enterPassword = 'Enter your password.';
  static const String loginAccountDisabled =
      'This account has been disabled. Contact your administrator.';
  static const String loginTooManyAttempts =
      'Too many attempts. Wait a few minutes and try again.';
  static const String loginNetworkError =
      'Could not reach the server. Check your connection and try again.';
  static const String loginSecondFactorRequired =
      'This account needs a second verification step that this sign-in page '
      'does not support yet. Contact your administrator.';
  static const String loginUnavailable =
      'Sign-in is unavailable right now. Try again in a moment.';
}
