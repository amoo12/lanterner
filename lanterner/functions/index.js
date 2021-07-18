const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

/* eslint-disable */
exports.onCreateFollower = functions.firestore
  .document("/users/{uid}/followers/{followerId}")
  .onCreate((snapshot, context) => {
    // console.log("Follower Created", snapshot.data());
    const uid = context.params.uid;
    const followerId = context.params.followerId;

    //1) get followed user posts
    const followedUserPostsRef = admin.firestore().collection("posts").where("user.uid", "==", uid);

    // 2) create following user's timeline reference
    const timelinePostsRef = admin
      .firestore()
      .collection("timeline")
      .doc(followerId)
      .collection("timelinePosts");

    //   3) get followed user timeline posts
    // const querySanpshot =
    followedUserPostsRef.get().then((docs) => {
      docs.forEach((doc) => {
        if (doc.exists) {
          const postId = doc.id;
          const postData = doc.data();
          timelinePostsRef.doc(postId).set(postData);
        }
      });
    });
  });

exports.onDeleteFollower = functions.firestore
  .document("/users/{uid}/followers/{followerId}")
  .onDelete((snapshot, context) => {
    console.log("followerDeleted " + snapshot.id);

    const uid = context.params.uid;
    const followerId = context.params.followerId;

    const timelinePostsRef = admin
      .firestore()
      .collection("timeline")
      .doc(followerId)
      .collection("timelinePosts")
      .where("user.uid", "==", uid);

    timelinePostsRef.get().then((docs) => {
      docs.forEach((doc) => {
        if (doc.exists) {
          console.log("post deleted from timeline " + doc.id);
          doc.ref.delete();
        }
      });
    });
  });

exports.updatePostLikesCount = functions.firestore
  .document("posts/{postId}/likes/{uid}")
  .onWrite((change, context) => {
    console.log("post Liked" + change.id);
    const uid = context.params.uid;
    const postId = context.params.postId;

    let increment;

    const userRef = admin.firestore().collection("users").doc(uid);

    const psotRef = admin.firestore().collection("posts").doc(postId);

    if (change.after.exists && !change.before.exists) {
      // TODO: set the notification message here
      increment = 1;
    } else if (!change.after.exists && change.before.exists) {
      // TODO: set the notification message here
      increment = -1;
    } else {
      return null;
    }

    //! TODO: remove the return if you want to add code below later
    return psotRef.set(
      { likeCount: admin.firestore.FieldValue.increment(increment) },
      { merge: true }
    );

    // likedUid = psotRef.doc.data("user.uid");
    // console.log("post ownerId" + likedUid);
    // return admin
    //   .firestore()
    //   .collection("activity")
    //   .doc(likedUid)
    //   .collection("userActivity")
    //   .doc()
    //   .set({ activityType: "like", user: userRef.doc.data() });
  });
