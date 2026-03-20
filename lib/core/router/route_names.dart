// lib/core/router/route_names.dart
class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String classrooms = '/classrooms';
  static const String createClassroom = '/classrooms/create';
  static const String joinClassroom = '/classrooms/join';
  static const String classroomDetail = '/classrooms/:classroomId';
  static const String classroomMembers = '/classrooms/:classroomId/members';
  static const String resources = '/classrooms/:classroomId/resources';
  static const String addResource = '/classrooms/:classroomId/resources/add';
  static const String resourceDetail = '/classrooms/:classroomId/resources/:resourceId';
  static const String pdfViewer = '/pdf-viewer';
  static const String assignments = '/classrooms/:classroomId/assignments';
  static const String createAssignment = '/classrooms/:classroomId/assignments/create';
  static const String assignmentDetail = '/classrooms/:classroomId/assignments/:assignmentId';
  static const String submitAssignment = '/classrooms/:classroomId/assignments/:assignmentId/submit';
  static const String submissionsReview = '/classrooms/:classroomId/assignments/:assignmentId/submissions';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
}
