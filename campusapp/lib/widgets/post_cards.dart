import 'package:campusapp/pages/post_details.dart';
import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final bool isDetails;
  String postId;
  PostCard({super.key, this.isDetails = false, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: postId,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDetails ? null : () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailPage(postId: postId),));
          },
        
          child: Container(
            padding: EdgeInsets.only(top: 5, bottom: 10, right: 8, left: 10),
            //height: MediaQuery.of(context).size.height * 0.15,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              //color: Colors.white,
              border: isDetails? null : Border.symmetric(
                horizontal: BorderSide(
                  color: const Color.fromARGB(255, 110, 110, 110),
                  width: .5,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 15,
                      // add image
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Aashwin Suresh",
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          Text(
                            "4d",
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.more_vert, color: Colors.white, size: 25),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                const Text(
                  'Arjun as got pregnant',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                SizedBox(height: 2),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Text("Can’t believe I’m finally sharing this news! It’s been a wild journey so far, and honestly, the cravings are already out of control. Thanks for all the support, everyone. Stay tuned for the ultrasound photos next week! #LifeUpdate #ModernMiracle #ArjunUpdate",style: TextStyle(color: Colors.white, fontSize: 15)),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(96, 255, 255, 255),
                      width: 0.5
                    ),
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
                SizedBox(height: 5,),
                Row(
                  children: [
                    _interactionButton(Icons.thumb_up_alt_outlined, '69'),
                    const SizedBox(width: 24),
                    _interactionButton(Icons.comment_outlined, "100"),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
    
  }Widget _interactionButton(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14,vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(
                color: const Color.fromARGB(96, 255, 255, 255),
                width: 0.5
              ),
              borderRadius: BorderRadius.circular(15)
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color:  Colors.white)),
          
        ],
      ),
    );
  }
  
}


