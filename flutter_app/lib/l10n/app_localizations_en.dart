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
  String get admin => 'Admin';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get login => 'Login';

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
}
