import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecam_flutter/models/post.dart';
import 'package:ecam_flutter/models/user.dart';
import 'package:ecam_flutter/providers/user_provider.dart';
import 'package:ecam_flutter/resources/firestore_methods.dart';
import 'package:ecam_flutter/screens/comments_screen.dart';
import 'package:ecam_flutter/utils/colors.dart';
import 'package:ecam_flutter/utils/utils.dart';
import 'package:ecam_flutter/widgets/like_animation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;
  int commentLen = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getComments();
  }

  void getComments() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      commentLen = snap.docs.length;
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;
    return Container(
      color: mobileBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(children: [
        // HEADER SECTION
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16)
              .copyWith(right: 0),
          child: Row(children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(widget.snap['porfImage']),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.snap['username'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),

            // OPTION MENU "..."
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => Dialog(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shrinkWrap: true,
                            children: [
                              'delete',
                            ]
                                .map(
                                  (e) => InkWell(
                                    onTap: () async {
                                      FirestoreMethods()
                                          .deletePost(widget.snap['postId']);
                                      Navigator.of(context)
                                          .pop(); // doesn't work--> supposed to disapear
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 16),
                                      child: Text(e),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ));
              },
              icon: const Icon(Icons.more_vert),
            ),
          ]),
        ),

        // IMAGE SECTION
        GestureDetector(
          onDoubleTap: () async {
            await FirestoreMethods().likePost(
                widget.snap['postId'], user.uid, widget.snap['likes']);
            setState(() {
              isLikeAnimating = true;
            });
          },
          child: Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                width: double.infinity,
                child: Image.network(
                  widget.snap['postUrl'],
                  fit: BoxFit.cover,
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isLikeAnimating ? 1 : 0,
                child: LikeAnimation(
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 200,
                  ),
                  isAnimating: isLikeAnimating,
                  duration: const Duration(
                    milliseconds: 400,
                  ),
                  onEnd: () {
                    setState(() {
                      isLikeAnimating = false;
                    });
                  },
                ),
              )
            ],
          ),
        ),

        // BOTTOM BUTTONS
        Row(
          children: [
            LikeAnimation(
              isAnimating: widget.snap['likes'].contains(user.uid),
              smallLike: true,
              child: IconButton(
                  onPressed: () async {
                    await FirestoreMethods().likePost(
                        widget.snap['postId'], user.uid, widget.snap['likes']);
                  },
                  icon: widget.snap['likes'].contains(user.uid)
                      ? const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        )
                      : const Icon(
                          Icons.favorite_border_outlined,
                          color: Colors.red,
                        )),
            ),
            IconButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CommentsScreen(
                          snap: widget.snap['postId'].toString(),
                        ))),
                icon: const Icon(
                  Icons.comment,
                  color: Colors.blue,
                )),
            IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.share,
                  color: Colors.orange,
                )),
            Expanded(
                child: Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                  onPressed: () {}, icon: const Icon(Icons.bookmark_border)),
            ))
          ],
        ),

        // DESCRIPTION AND NUMBER OF COMMENTS
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultTextStyle(
                style: Theme.of(context).textTheme.subtitle2!.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                child: Text(
                  '${widget.snap['likes'].length} likes', //string interpolation
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
                  child: RichText(
                    text: TextSpan(
                        style: const TextStyle(color: primaryColor),
                        children: [
                          TextSpan(
                            text: widget.snap['username'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '  ${widget.snap['description']}',
                          ),
                        ]),
                  )),
              InkWell(
                onTap: () {},
                child: Container(
                  child: Text(
                    '$commentLen comments',
                    style: const TextStyle(fontSize: 16, color: secondaryColor),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  DateFormat.yMMMd().format(
                    widget.snap['datePublished'].toDate(),
                  ),
                  style: const TextStyle(fontSize: 12, color: secondaryColor),
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }
}
