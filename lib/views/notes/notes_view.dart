import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/extensions/buildcontext/loc.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
import 'package:mynotes/services/cloud/firebase_cloud_storage.dart';
import 'package:mynotes/utilities/dialogs/delete_dialog.dart';
import 'package:mynotes/utilities/dialogs/logout_dialog.dart';

extension Count <T extends Iterable> on Stream<T>{
  Stream<int>get getLength => map((event)=>event.length);
}

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> with TickerProviderStateMixin {
  late final FirebaseCloudStorage _notesService;
  late AnimationController _animationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _fabRotationAnimation;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));

    _fabRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Color _getCardColor(int index) {
    final colors = [
      const Color(0xFFFFE4E1), // Light pink
      const Color(0xFFE1F5FE), // Light blue
      const Color(0xFFF3E5F5), // Light purple
      const Color(0xFFE8F5E8), // Light green
      const Color(0xFFFFF3E0), // Light orange
      const Color(0xFFEDE7F6), // Light indigo
      const Color(0xFFF1F8E9), // Light lime
      const Color(0xFFFCE4EC), // Light pink 2
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: StreamBuilder(
          stream: _notesService.allNotes(ownerUserId: userId).getLength,
          builder: (context, AsyncSnapshot<int> snapshot) {
            if (snapshot.hasData) {
              final noteCount = snapshot.data ?? 0;
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.elasticOut,
                )),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.loc.my_notes,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '$noteCount ${noteCount == 1 ? context.loc.note : context.loc.notes_title}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Text('');
            }
          }
        ),
        actions: [
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.elasticOut,
            )),
            child: PopupMenuButton<MenuAction>(
              icon: const Icon(Icons.more_vert, color: Colors.black87),
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                    final shouldLogout = await showLogOutDialog(context);
                    if (shouldLogout) {
                      context.read<AuthBloc>().add(
                        const AuthEventLogOut(),
                      );
                    }
                }
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem<MenuAction>(
                    value: MenuAction.logout,
                    child: Row(
                      children: [
                        const Icon(Icons.logout, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          context.loc.logout_button,
                          style: const TextStyle(color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _notesService.allNotes(ownerUserId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                if (allNotes.isEmpty) {
                  return _buildEmptyState();
                }
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: FloatingNotesListView(
                    notes: allNotes,
                    onDeleteNote: (note) async {
                      await _notesService.deleteNote(documentId: note.documentId);
                    },
                    onTap: (note, color, index) {
                      // Pass both note and color to the editor
                      Navigator.of(context).pushNamed(
                        createUpdateNotesRoute,
                        arguments: {
                          'note': note,
                          'color': color,
                          'heroTag': 'note_${note.documentId}',
                        },
                      );
                    },
                    getCardColor: _getCardColor,
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabScaleAnimation.value,
            child: Transform.rotate(
              angle: _fabRotationAnimation.value,
              child: FloatingActionButton.extended(
                onPressed: () async {
                  _fabAnimationController.forward().then((_) {
                    _fabAnimationController.reverse();
                  });
                  
                  final currentUser = AuthService.firebase().currentUser!;
                  final userId = currentUser.id;

                  // Create new empty note and navigate
                  final newNote = await FirebaseCloudStorage().createNewNote(
                    ownerUserId: userId,
                  );
                  
                  // Navigate with a default color for new notes
                  Navigator.of(context).pushNamed(
                    createUpdateNotesRoute,
                    arguments: {
                      'note': newNote,
                      'color': _getCardColor(0),
                      'heroTag': 'note_${newNote.documentId}',
                    },
                  );
                },
                backgroundColor: const Color(0xFF6C63FF),
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  context.loc.new_note_button,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                elevation: 8,
                extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.note_alt_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _animationController,
                curve: Curves.bounceOut,
              )),
              child: Column(
                children: [
                  Text(
                    context.loc.no_notes_title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.loc.tap_to_add,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FloatingNotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final Function(CloudNote) onDeleteNote;
  final Function(CloudNote, Color, int) onTap;
  final Color Function(int) getCardColor;

  const FloatingNotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
    required this.getCardColor,
  });

  @override
  Widget build(BuildContext context) {
    final notesList = notes.toList();
    
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final note = notesList[index];
                final cardColor = getCardColor(index);
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  curve: Curves.easeOutBack,
                  child: FloatingNoteCard(
                    note: note,
                    index: index,
                    onTap: () => onTap(note, cardColor, index),
                    onDelete: () => onDeleteNote(note),
                    cardColor: cardColor,
                  ),
                );
              },
              childCount: notesList.length,
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }
}

class FloatingNoteCard extends StatefulWidget {
  final CloudNote note;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Color cardColor;

  const FloatingNoteCard({
    super.key,
    required this.note,
    required this.index,
    required this.onTap,
    required this.onDelete,
    required this.cardColor,
  });

  @override
  State<FloatingNoteCard> createState() => _FloatingNoteCardState();
}

class _FloatingNoteCardState extends State<FloatingNoteCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 4.0,
      end: 12.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    // Start with a delayed animation based on index
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _hoverController.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'note_${widget.note.documentId}',
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: Listenable.merge([_scaleAnimation, _elevationAnimation, _rotationAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: _elevationAnimation.value,
                          offset: Offset(0, _elevationAnimation.value / 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _formatDate(widget.note.createdAt),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          final shouldDelete = await showDeleteDialog(context);
                                          if (shouldDelete) {
                                            widget.onDelete();
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.delete_outline,
                                            size: 35,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Expanded(
                                    child: Text(
                                      widget.note.text.isEmpty
                                          ? context.loc.empty_note_title
                                          : widget.note.text,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: widget.note.text.isEmpty
                                            ? Colors.grey[500]
                                            : Colors.black87,
                                        fontWeight: FontWeight.w500,
                                        height: 1.4,
                                      ),
                                      maxLines: 8,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.edit_note,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${widget.note.text.length} ${context.loc.characters}}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Animated floating decoration circles
                          AnimatedBuilder(
                            animation: _hoverController,
                            builder: (context, child) {
                              return Positioned(
                                top: -20 + (_hoverController.value * 5),
                                right: -20 + (_hoverController.value * 5),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2 + (_hoverController.value * 0.1)),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            },
                          ),
                          AnimatedBuilder(
                            animation: _hoverController,
                            builder: (context, child) {
                              return Positioned(
                                bottom: -30 - (_hoverController.value * 5),
                                left: -30 - (_hoverController.value * 5),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1 + (_hoverController.value * 0.05)),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 30) {
      return '${dateTime.day}/${dateTime.month}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ${context.loc.ago}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${context.loc.ago}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ${context.loc.ago}';
    } else {
      return context.loc.now;
    }
  }
}