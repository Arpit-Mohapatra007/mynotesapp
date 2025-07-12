import 'package:flutter/material.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/utilities/dialogs/cannot_share_empty_note_dialog.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView>
    with TickerProviderStateMixin {
  CloudNote? _note;
  Color _backgroundColor = const Color(0xFFFFE4E1);
  String _heroTag = '';
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late AnimationController _textFieldController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _textController = TextEditingController();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _textFieldController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _floatingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textFieldController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
    _floatingController.repeat(reverse: true);
    
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get the arguments passed from the previous screen
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      final note = arguments['note'] as CloudNote?;
      final color = arguments['color'] as Color?;
      final heroTag = arguments['heroTag'] as String?;
      
      if (note != null) {
        _note = note;
        _textController.text = note.text;
      }
      if (color != null) {
        _backgroundColor = color;
      }
      if (heroTag != null) {
        _heroTag = heroTag;
      }
    }
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNote = await _notesService.createNewNote(ownerUserId: userId);
    _note = newNote;
    _setupTextControllerListener();
    return newNote;
  }

  void _deleteNoteIfTextEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textController.text;
    await _notesService.updateNote(documentId: note.documentId, text: text);
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
    _textFieldController.forward();
  }

  void _saveNoteIfTextNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (_textController.text.isNotEmpty && note != null) {
      await _notesService.updateNote(documentId: note.documentId, text: text);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    _animationController.dispose();
    _floatingController.dispose();
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: _heroTag,
      child: Material(
        color: Colors.transparent,
        child: Scaffold(
          backgroundColor: _backgroundColor,
          body: Stack(
            children: [
              // Floating animated background elements
              AnimatedBuilder(
                animation: _floatingAnimation,
                builder: (context, child) {
                  return Positioned(
                    top: 100 + (_floatingAnimation.value * 20),
                    right: 50 + (_floatingAnimation.value * 30),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
              AnimatedBuilder(
                animation: _floatingAnimation,
                builder: (context, child) {
                  return Positioned(
                    bottom: 200 - (_floatingAnimation.value * 25),
                    left: 30 - (_floatingAnimation.value * 20),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
              // Main content
              SafeArea(
                child: Column(
                  children: [
                    // Custom AppBar
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Back button
                          AnimatedBuilder(
                            animation: _fadeAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(-_slideAnimation.value, 0),
                                child: Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      icon: const Icon(
                                        Icons.arrow_back_ios_rounded,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          // Title
                          Expanded(
                            child: AnimatedBuilder(
                              animation: _fadeAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, -_slideAnimation.value),
                                  child: Opacity(
                                    opacity: _fadeAnimation.value,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        context.loc.note,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Share button
                          AnimatedBuilder(
                            animation: _fadeAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(_slideAnimation.value, 0),
                                child: Opacity(
                                  opacity: _fadeAnimation.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      onPressed: () async {
                                        final text = _textController.text;
                                        if (_note == null || text.isEmpty) {
                                          await showCannotShareEmptyNoteDialog(context);
                                        } else {
                                          Share.share(text);
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.share,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Text field area
                    Expanded(
                      child: FutureBuilder(
                        future: createOrGetExistingNote(context),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.done:
                              return AnimatedBuilder(
                                animation: _scaleAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _scaleAnimation.value,
                                    child: Container(
                                      margin: const EdgeInsets.all(16),
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: TextField(
                                        controller: _textController,
                                        keyboardType: TextInputType.multiline,
                                        maxLines: null,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          height: 1.5,
                                          color: Colors.black87,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: context.loc.start_typing_your_note,
                                          hintStyle: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 16,
                                          ),
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            default:
                              return Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}