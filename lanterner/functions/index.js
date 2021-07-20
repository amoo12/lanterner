const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

/* eslint-disable */

//* add past posts to the followers feed
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

//* remove posts from the followers feed when the unfollow
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

//* add future post to the followers' feed
exports.onCreatePost = functions.firestore
  .document("/posts/{postId}")
  .onCreate((snapshot, context) => {
    const post = snapshot.data();
    const uid = snapshot.data().user.uid;
    const postId = snapshot.data().postId;
    console.log("postId" + snapshot.data().postId);

    const userFollowersRef = admin.firestore().collection("users").doc(uid).collection("followers");

    return userFollowersRef.get().then((docs) => {
      // add new posts to each follower feed
      console.log(docs.size);
      docs.forEach((doc) => {
        console.log("doc data" + doc.data());
        console.log("doc id" + doc.id);
        admin
          .firestore()
          .collection("timeline")
          .doc(doc.id)
          .collection("timelinePosts")
          .doc(postId)
          .set(post);
      });
    });
  });

//* delete post from the followers' feed when users deletes their posts
exports.onDeletePost = functions.firestore
  .document("/posts/{postID}")
  .onDelete((snapshot, context) => {
    const uid = snapshot.data().user.uid;
    const postId = snapshot.data().postId;

    const userFollowersRef = admin.firestore().collection("users").doc(uid).collection("followers");

    return userFollowersRef.get().then((docs) => {
      // delte posts frome each follower feed
      docs.forEach((doc) => {
        admin
          .firestore()
          .collection("timeline")
          .doc(doc.id)
          .collection("timelinePosts")
          .doc(postId)
          .get()
          .then((doc) => {
            if (doc.exists) {
              doc.ref.delete();
            }
          });
      });
    });
  });

//* update the the number of likes 💗
exports.updatePostLikesCount = functions.firestore
  .document("posts/{postId}/likes/{uid}")
  .onWrite((change, context) => {
    console.log("post Liked" + change.id);
    const uid = context.params.uid;
    const postId = context.params.postId;

    let increment;

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

    psotRef.set({ likeCount: admin.firestore.FieldValue.increment(increment) }, { merge: true });

    var postOwnerId;
    var user;
    return admin
      .firestore()
      .collection("users")
      .doc(uid)
      .get()
      .then((document) => {
        user = document.data();

        psotRef.get().then((doc) => {
          postOwnerId = doc.data().user.uid;
          console.log("post ownerId line 194" + doc.data().user.uid);

          console.log("post ownerIddd line 197" + postOwnerId);
          admin
            .firestore()
            .collection("activity")
            .doc(postOwnerId)
            .collection("userActivity")
            .doc()
            .set({ activityType: "like", postId: postId, user: user });
        });
      });
  });

//* update the the number of comments
exports.updateCommentsCount = functions.firestore
  .document("posts/{postId}/comments/{cid}")
  .onWrite((change, context) => {
    const cid = context.params.cid;
    const postId = context.params.postId;

    let increment;

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
    psotRef.set(
      { commmentCount: admin.firestore.FieldValue.increment(increment) },
      { merge: true }
    );

    var data;
    if (increment == 1) {
      data = change.after.data();
    } else if (increment == -1) {
      data = change.before.data();
    }

    var postOwnerId;
    return psotRef.get().then((doc) => {
      postOwnerId = doc.data().user.uid;
      console.log("post ownerId line 194" + doc.data().user.uid);

      console.log("post ownerIddd line 197" + postOwnerId);
      admin
        .firestore()
        .collection("activity")
        .doc(postOwnerId)
        .collection("userActivity")
        .doc()
        .set({ activityType: "comment", notification: data });
    });
  });
