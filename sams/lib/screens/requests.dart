import 'package:flutter/material.dart';
import 'package:e_clearance/api_service.dart';

class Requests extends StatefulWidget {
  final String accessToken;
  final ApiService apiService;
  final String userRole;

  const Requests({
    Key? key,
    required this.accessToken,
    required this.apiService,
    required this.userRole,
  }) : super(key: key);

  @override
  _RequestsState createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = widget.userRole == 'student'
          ? await widget.apiService.getRequests(widget.accessToken)
          : await widget.apiService.getToMeRequests(widget.accessToken);

      if (response is Map<String, dynamic>) {
        final requestsData = response['requests'];

        if (requestsData is List) {
          setState(() {
            _requests = requestsData.map((item) {
              print(item);
              if (item is Map) {
                if (item['status'] is String) {
                  item['status'] = int.tryParse(item['status'] as String) ?? 0;
                }
                return Map<String, dynamic>.from(item);
              } else {
                return <String, dynamic>{};
              }
            }).toList();
          });
        } else {
          print('Unexpected data format for requests: $requestsData');
          _showError('Unexpected data format for requests');
        }
      } else {
        print('Unexpected API response format: $response');
        _showError('Unexpected API response format');
      }
    } catch (e) {
      print('Failed to fetch requests: $e');
      _showError('Failed to fetch requests');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message, {int? errorCode}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            errorCode != null ? '$message (Error Code: $errorCode)' : message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _updateRequestStatus(int index, int newStatus) async {
    final request = _requests[index];
    final requestId = request['id'];

    try {
      final response = await widget.apiService.changeStatus(
        widget.accessToken,
        requestId,
        newStatus,
      );

      // Print response to debug
      print('API Response: $response');

      if (response.containsKey('message') &&
          response['message'] == 'Status updated successfully') {
        setState(() {
          _requests[index]['status'] = newStatus;
        });
        _showSuccess('Status updated successfully');
      } else {
        final errorCode = response['error_code'] ?? 'Unknown';
        final message = response['message'] ?? 'An error occurred';
        _showError(
            'Failed to update status (Error Code: $errorCode) - $message');
      }
    } catch (e) {
      print('Failed to update request status: $e');
      _showError('Failed to update request status');
    }
  }

  void _showRequestDetails(int index) {
    final request = _requests[index];
    final user = request['user'] as Map<String, dynamic>?;
    final approver = request['user'] as Map<String, dynamic>?;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final status = request['status'] ?? 0;
        final statusLabel = _getStatusLabel(status);
        final statusColor = _getStatusColor(status);

        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          title: widget.userRole == 'instructor'
              ? Text(user?['name'] ?? 'Unknown')
              : const SizedBox.shrink(),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subject: ${request['subject'] ?? 'N/A'}',
                  style: const TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                widget.userRole == 'student'
                    ? Text(approver?['name'] ?? 'Unknown')
                    : const SizedBox.shrink(),
                const SizedBox(height: 8.0),
                Text('Message: ${request['message'] ?? 'N/A'}'),
                const SizedBox(height: 8.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    'Status: $statusLabel',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8.0),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.red;
      case 0:
      default:
        return Colors.yellow;
    }
  }

  String _getStatusLabel(int status) {
    switch (status) {
      case 1:
        return 'Approved';
      case 2:
        return 'Declined';
      case 0:
      default:
        return 'Pending';
    }
  }

  void _handleTap(int index) {
    if (widget.userRole == 'instructor') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final request = _requests[index];
          final status = request['status'] ?? 0;

          return AlertDialog(
            contentPadding: const EdgeInsets.all(16.0),
            title: const Text('Change Status'),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatusButton(
                        Icons.check_circle,
                        Colors.green,
                        'Approved',
                        () {
                          _updateRequestStatus(index, 1);
                          Navigator.of(context).pop();
                        },
                      ),
                      _buildStatusButton(
                        Icons.cancel,
                        Colors.red,
                        'Declined',
                        () {
                          _updateRequestStatus(index, 2);
                          Navigator.of(context).pop();
                        },
                      ),
                      _buildStatusButton(
                        Icons.pending,
                        Colors.yellow,
                        'Pending',
                        () {
                          _updateRequestStatus(index, 0);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildStatusButton(
      IconData icon, Color color, String label, VoidCallback onPressed) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(icon, color: color),
            onPressed: onPressed,
          ),
          Text(label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(vertical: 80.0, horizontal: 16.0),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _requests.length,
                itemBuilder: (context, index) {
                  final request = _requests[index];
                  final status = request['status'] ?? 0;
                  final user = request['user'] as Map<String, dynamic>?;
                  final approver =
                      request['request_to'] as Map<String, dynamic>?;

                  IconData statusIcon;
                  Color statusColor;

                  switch (status) {
                    case 1:
                      statusIcon = Icons.check_circle;
                      statusColor = Colors.green;
                      break;
                    case 2:
                      statusIcon = Icons.cancel;
                      statusColor = Colors.red;
                      break;
                    case 0:
                    default:
                      statusIcon = Icons.pending;
                      statusColor = Colors.yellow;
                  }

                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(8.0),
                      title: widget.userRole == 'instructor'
                          ? Text(user?['name'] ?? 'Unknown')
                          : const SizedBox.shrink(),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Subject: ${request['subject'] ?? 'No Subject'}',
                            style: const TextStyle(
                                fontSize: 12.0, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Approver: ${approver?['name'] ?? 'Not Complete'}',
                            style: const TextStyle(
                                fontSize: 12.0, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 200,
                            child: Text(
                              'Message : ${request['message'] ?? 'No message'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            color: statusColor,
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline),
                            onPressed: () {
                              _showRequestDetails(index);
                            },
                          ),
                          // if (widget.userRole == 'instructor')
                        ],
                      ),
                      onTap: () {
                        _handleTap(index);
                      },
                      enabled: widget.userRole == 'instructor',
                    ),
                  );
                },
              ),
            ),
    );
  }
}
