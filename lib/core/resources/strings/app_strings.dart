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
  static const String edit = 'Edit';
  static const String block = 'Block';
  static const String delete = 'Delete';
  static const String noUsersFound = 'No users found';

  static String showingRange(int start, int end, int total) =>
      'Showing $start–$end of $total';

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
  static const String searchRechargesHint = 'Search payment ID or amount';
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
  static const String adminRecharge = 'Admin recharge';
  static const String confirmRechargeLead = 'Add this recharge to ';
  static const String confirmRechargeTail = "'s wallet?";

  static String rechargeSubtitle(String name, String userId) =>
      '$name · $userId';

  static String coinsWithBonus(String coins, String? bonus) =>
      bonus == null ? '$coins coins' : '$coins coins · +$bonus Bonus';

  static String bonusLabel(String bonus) => '+$bonus Bonus';

  static String coinsAddedToWallet(String coins, String name) =>
      "$coins coins were added to $name's wallet.";

  static const String signInSecurely = 'Sign in securely';
  static const String loginFailed =
      'Email or password is incorrect. Check your details and try again. '
      'Only approved admins can sign in.';
}
