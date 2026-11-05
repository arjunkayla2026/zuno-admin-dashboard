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

  static const String signInSecurely = 'Sign in securely';
  static const String loginFailed =
      'Email or password is incorrect. Check your details and try again. '
      'Only approved admins can sign in.';
}
