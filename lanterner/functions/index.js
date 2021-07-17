const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
/* eslint-disable */
exports.onCreateFollower = functions.firestore
  .document("/users/{uid}/followers/{followerId}")
  .onCreate((snapshot, context) => {
    console.log("Follower Created", snapshot.data());
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
