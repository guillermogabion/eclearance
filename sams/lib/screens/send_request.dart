import '../api_service.dart';
import 'package:flutter/material.dart';

class AddRequest extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final String? accessToken;

  const AddRequest({Key? key, this.userData, this.accessToken})
      : super(key: key);

  @override
  State<AddRequest> createState() => _AddRequestState();
}

class _AddRequestState extends State<AddRequest> {
  final ApiService _apiService = ApiService();
  String? _selectedInstructorId;
  List<Map<String, dynamic>> _instructors = [];
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  final FocusNode _focusNodeSubject = FocusNode();
  final FocusNode _focusNodeMessage = FocusNode();

  bool _isFocusedSubject = false;
  bool _isFocusedMessage = false;
  bool _isLoading = false;

  void _handleFocusChange() {
    setState(() {
      _isFocusedSubject = _focusNodeSubject.hasFocus;
      _isFocusedMessage = _focusNodeMessage.hasFocus;
    });
  }

  @override
  void initState() {
    super.initState();
    _focusNodeSubject.addListener(_handleFocusChange);
    _focusNodeMessage.addListener(_handleFocusChange);
    _fetchInstructors();
  }

  @override
  void dispose() {
    _focusNodeSubject.removeListener(_handleFocusChange);
    _focusNodeSubject.dispose();
    _focusNodeMessage.removeListener(_handleFocusChange);
    _focusNodeMessage.dispose();
    super.dispose();
  }

  void _addRequest() async {
    final String? accessToken = widget.accessToken;
    final String subject = _subjectController.text;
    final String message = _messageController.text;

    Map<String, dynamic> requestData = {
      'user_id': widget.userData?['user']?['id'],
      'subject': subject,
      'requested_id': _selectedInstructorId,
      'message': message,
    };

    if (subject.isEmpty || _selectedInstructorId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Subject and Instructor cannot be empty')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (accessToken != null) {
        await _apiService.addRequest(accessToken, requestData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Request submitted successfully')),
          );

          _subjectController.text = "";
          _selectedInstructorId = null;
          _messageController.text = "";
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Access token is missing')),
          );
        }
      }
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit the request')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchInstructors() async {
    final String? accessToken = widget.accessToken;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getEntities(accessToken);

      if (response != null && response is List<dynamic>) {
        print('API Response: $response'); // Debugging line

        setState(() {
          _instructors = response.map((item) {
            // Handle potential null values and type casting
            return {
              'id': (item['id'] ?? '')
                  .toString(), // Convert ID to String or use default value
              'name': (item['name'] ?? 'Unknown')
                  as String, // Use default value if name is null
            };
          }).toList();

          print('Instructors: $_instructors'); // Debugging line

          if (_instructors.isNotEmpty) {
            _selectedInstructorId = null; // Ensure default is 'Please select'
          } else {
            _selectedInstructorId =
                null; // Set to null if no instructors available
          }
        });
      } else {
        print('Unexpected API response format: $response');
      }
    } catch (e) {
      print('Failed to fetch instructors: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 150.0, 16.0, 0.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24.0),
                TextField(
                  focusNode: _focusNodeSubject,
                  controller: _subjectController,
                  decoration: InputDecoration(
                    labelText: 'Subject',
                    labelStyle: TextStyle(
                      color: _isFocusedSubject
                          ? const Color(0xFF4B49AC)
                          : Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 255, 255, 255),
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 255, 255, 255),
                        width: 2.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Color(0xFF4B49AC),
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<String?>(
                        value: _selectedInstructorId,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedInstructorId = newValue;
                            print(
                                'Selected instructor ID: $_selectedInstructorId'); // Debugging line
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Instructor',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 255, 255, 255),
                              width: 2.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Color.fromARGB(255, 255, 255, 255),
                              width: 2.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Color(0xFF4B49AC),
                              width: 2.0,
                            ),
                          ),
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Please select'),
                          ),
                          ..._instructors.map((instructor) {
                            final id = instructor['id']?.toString() ?? '';
                            final name = instructor['name'] ?? 'Unknown';
                            return DropdownMenuItem<String?>(
                              value: id,
                              child: Text(name),
                            );
                          }).toList(),
                        ],
                      ),
                const SizedBox(height: 24.0),
                TextFormField(
                  focusNode: _focusNodeMessage,
                  controller: _messageController,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    labelText: 'Message',
                    labelStyle: TextStyle(
                      color: _isFocusedMessage
                          ? const Color(0xFF4B49AC)
                          : Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 255, 255, 255),
                        width: 2.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 255, 255, 255),
                        width: 2.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(
                        color: Color(0xFF4B49AC),
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: _addRequest,
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xFF4B49AC), // Background color
                      onPrimary: Colors.white, // Text color
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
