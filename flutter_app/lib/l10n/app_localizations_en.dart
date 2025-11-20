// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mini Task Tracker';

  @override
  String get home => 'Home';

  @override
  String get tasks => 'Tasks';

  @override
  String get myTasks => 'My Tasks';

  @override
  String get teamTasks => 'Team Tasks';

  @override
  String get completedTasks => 'Completed';

  @override
  String get admin => 'Admin Mode';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get login => 'Sign In';

  @override
  String get email => 'Email';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get usernameOrEmail => 'Username';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get rememberMe => 'Remember Me';

  @override
  String get taskTitle => 'Task Title';

  @override
  String get taskNote => 'Note';

  @override
  String get taskPriority => 'Priority';

  @override
  String get taskStatus => 'Status';

  @override
  String get taskDueDate => 'Due Date';

  @override
  String get taskAssignee => 'Assignee';

  @override
  String get taskTopic => 'Topic';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityNormal => 'Normal';

  @override
  String get priorityHigh => 'High';

  @override
  String get statusTodo => 'To Do';

  @override
  String get statusInProgress => 'In Progress';

  @override
  String get statusDone => 'Done';

  @override
  String get createTask => 'Create Task';

  @override
  String get editTask => 'Edit Task';

  @override
  String get deleteTask => 'Delete Task';

  @override
  String get updateTask => 'Update Task';

  @override
  String get assignTask => 'Assign Task';

  @override
  String get createUser => 'Create User';

  @override
  String get editUser => 'Edit User';

  @override
  String get deleteUser => 'Delete User';

  @override
  String get users => 'Users';

  @override
  String get userManagement => 'User Management';

  @override
  String get taskManagement => 'Task Management';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleMember => 'Member';

  @override
  String get roleGuest => 'Guest';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get create => 'Create';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get refresh => 'Refresh';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get emptyTasksTitle => 'No Tasks Found';

  @override
  String get emptyTasksMessage => 'You don\'t have any tasks yet';

  @override
  String get emptyUsersTitle => 'No Users Found';

  @override
  String get emptyUsersMessage => 'No users have been added yet';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get errorNetworkTitle => 'Connection Error';

  @override
  String get errorNetworkMessage => 'Please check your internet connection';

  @override
  String get errorUnauthorizedTitle => 'Session Expired';

  @override
  String get errorUnauthorizedMessage => 'Please login again';

  @override
  String get errorServerTitle => 'Server Error';

  @override
  String get errorServerMessage => 'An error occurred, please try again later';

  @override
  String get errorUnknownTitle => 'Unexpected Error';

  @override
  String get errorUnknownMessage => 'Something went wrong';

  @override
  String get taskCreatedSuccess => 'Task created';

  @override
  String get taskUpdatedSuccess => 'Task updated';

  @override
  String get taskDeletedSuccess => 'Task deleted';

  @override
  String get userCreatedSuccess => 'User created';

  @override
  String get userUpdatedSuccess => 'User updated';

  @override
  String get userDeletedSuccess => 'User deleted';

  @override
  String get confirmDeleteTask => 'Are you sure you want to delete this task?';

  @override
  String get confirmDeleteUser => 'Are you sure you want to delete this user?';

  @override
  String get confirmLogout => 'Are you sure you want to logout?';

  @override
  String get validation_required => 'This field is required';

  @override
  String get validation_email => 'Please enter a valid email address';

  @override
  String validation_minLength(int min) {
    return 'Must be at least $min characters';
  }

  @override
  String validation_maxLength(int max) {
    return 'Must be at most $max characters';
  }

  @override
  String daysRemaining(int count) {
    return '$count days remaining';
  }

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get syncInProgress => 'Syncing...';

  @override
  String get syncCompleted => 'Sync completed';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get offlineMode => 'Offline Mode';

  @override
  String get loginErrorTitle => 'Login Error';

  @override
  String get loginErrorMessage => 'Invalid username or password';

  @override
  String get companyName => 'Company Name';

  @override
  String get teamName => 'Team Name';

  @override
  String get yourName => 'Your Name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get createYourTeam => 'Create Your Team';

  @override
  String get createTeam => 'Create Team';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get dontHaveTeam => 'Don\'t have a team? Register here';

  @override
  String get teamCreatedSuccess => 'Team created successfully! Welcome aboard!';

  @override
  String get emailAlreadyRegistered =>
      'This email is already registered. Please login instead.';

  @override
  String get registrationFailed => 'Registration failed. Please try again.';

  @override
  String get weak => 'Weak';

  @override
  String get fair => 'Fair';

  @override
  String get good => 'Good';

  @override
  String get strong => 'Strong';

  @override
  String get allTasks => 'All';

  @override
  String get highPriority => 'High Priority';

  @override
  String get overdue => 'Overdue';

  @override
  String get tryChangingFilters => 'Try changing filters';

  @override
  String get taskDeleted => 'Task deleted';

  @override
  String get failedToUpdateTask => 'Failed to update task';

  @override
  String get failedToDeleteTask => 'Failed to delete task';

  @override
  String get taskMovedToActive => 'Task moved back to Active';

  @override
  String get failedToUndo => 'Failed to undo';

  @override
  String get appearance => 'Appearance';

  @override
  String get language => 'Language';

  @override
  String get account => 'Account';

  @override
  String get about => 'About';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get systemDefault => 'System Default';

  @override
  String get english => 'English';

  @override
  String get turkish => 'Türkçe';

  @override
  String get appVersion => 'App Version';

  @override
  String get license => 'License';

  @override
  String get mitLicense => 'MIT License';

  @override
  String get signOutOfYourAccount => 'Sign out of your account';

  @override
  String get avatarUpdateComingSoon => 'Avatar update coming soon!';

  @override
  String get chooseTheme => 'Choose Theme';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get adminPanel => 'Admin Panel';

  @override
  String get exitAdminMode => 'Exit Admin Mode';

  @override
  String get userManagementTab => 'Users';

  @override
  String get taskManagementTab => 'Tasks';

  @override
  String get topicsManagementTab => 'Topics';

  @override
  String get organizationTab => 'Org';

  @override
  String get userUpdated => 'User updated';

  @override
  String get userCreated => 'User created';

  @override
  String get topicUpdated => 'Topic updated';

  @override
  String get topicCreated => 'Topic created';

  @override
  String get allTopics => 'All Topics';

  @override
  String get allStatuses => 'All Statuses';

  @override
  String get noProjects => 'No Projects';

  @override
  String get noVisibleProjects => 'No visible projects assigned.';

  @override
  String get noActiveProjects => 'No active projects found.';

  @override
  String get addTaskToMyself => 'Add Task to Myself';

  @override
  String get noTasksInProject => 'No tasks in this project';

  @override
  String get noAccess => 'No Access';

  @override
  String get noAccessMessage =>
      'You don\'t have access to any task groups yet.\\nContact your admin.';

  @override
  String get assignedTo => 'Assigned';

  @override
  String get unassigned => 'Unassigned';

  @override
  String get confirmTitle => 'Confirm';

  @override
  String get confirmMessage => 'Are you sure?';

  @override
  String get confirm => 'Confirm';

  @override
  String deleteConfirmation(Object item) {
    return 'Are you sure you want to delete $item? This action cannot be undone.';
  }

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get pleasSelectDueDate => 'Please select a due date';

  @override
  String get taskAddedSuccess => 'Task added successfully';

  @override
  String get loadingFailed => 'Failed to load data';

  @override
  String get dataLoadedSuccess => 'Data loaded successfully';

  @override
  String get pullToRefresh => 'Pull to refresh';

  @override
  String get releaseToRefresh => 'Release to refresh';

  @override
  String get refreshing => 'Refreshing...';

  @override
  String get lastUpdated => 'Last updated';

  @override
  String get filterBy => 'Filter by';

  @override
  String get sortBy => 'Sort by';

  @override
  String get ascending => 'Ascending';

  @override
  String get descending => 'Descending';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get noFiltersApplied => 'No filters applied';

  @override
  String get sortByDate => 'Date';

  @override
  String get sortByPriority => 'Priority';

  @override
  String get sortByStatus => 'Status';

  @override
  String get sortByTitle => 'Title';

  @override
  String get filterByPriority => 'Filter by Priority';

  @override
  String get filterByStatus => 'Filter by Status';

  @override
  String get filterByAssignee => 'Filter by Assignee';

  @override
  String get filterByTopic => 'Filter by Topic';

  @override
  String get viewOptions => 'View Options';

  @override
  String get listView => 'List View';

  @override
  String get gridView => 'Grid View';

  @override
  String get compactView => 'Compact View';

  @override
  String get markAsRead => 'Mark as Read';

  @override
  String get markAsUnread => 'Mark as Unread';

  @override
  String get archive => 'Archive';

  @override
  String get unarchive => 'Unarchive';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get share => 'Share';

  @override
  String get advancedFilters => 'Advanced Filters';

  @override
  String get quickFilters => 'Quick Filters';

  @override
  String get savedFilters => 'Saved Filters';

  @override
  String get createFilter => 'Create Filter';

  @override
  String get saveFilter => 'Save Filter';

  @override
  String get filterName => 'Filter Name';
}
