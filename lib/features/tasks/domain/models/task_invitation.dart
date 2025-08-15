class TaskInvitation {
  final String id;
  final String taskId;
  final String taskTitle;
  final String fromUserId;
  final String fromUserEmail;
  final String toUserEmail;
  final DateTime createdAt;
  final bool isAccepted;
  final bool isDeclined;

  TaskInvitation({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.fromUserId,
    required this.fromUserEmail,
    required this.toUserEmail,
    required this.createdAt,
    this.isAccepted = false,
    this.isDeclined = false,
  });

  factory TaskInvitation.fromJson(Map<String, dynamic> json) {
    return TaskInvitation(
      id: json['id'],
      taskId: json['task_id'],
      taskTitle: json['task_title'],
      fromUserId: json['from_user_id'],
      fromUserEmail: json['from_user_email'],
      toUserEmail: json['to_user_email'],
      createdAt: DateTime.parse(json['created_at']),
      isAccepted: json['is_accepted'] ?? false,
      isDeclined: json['is_declined'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'task_title': taskTitle,
      'from_user_id': fromUserId,
      'from_user_email': fromUserEmail,
      'to_user_email': toUserEmail,
      'created_at': createdAt.toIso8601String(),
      'is_accepted': isAccepted,
      'is_declined': isDeclined,
    };
  }

  TaskInvitation copyWith({
    String? id,
    String? taskId,
    String? taskTitle,
    String? fromUserId,
    String? fromUserEmail,
    String? toUserEmail,
    DateTime? createdAt,
    bool? isAccepted,
    bool? isDeclined,
  }) {
    return TaskInvitation(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      taskTitle: taskTitle ?? this.taskTitle,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserEmail: fromUserEmail ?? this.fromUserEmail,
      toUserEmail: toUserEmail ?? this.toUserEmail,
      createdAt: createdAt ?? this.createdAt,
      isAccepted: isAccepted ?? this.isAccepted,
      isDeclined: isDeclined ?? this.isDeclined,
    );
  }
}
