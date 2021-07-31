const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

/* eslint-disable */

//* add past posts to the followers feed
exports.onCreateFollower = functions.firestore
  .document("/users/{uid}/followers/{followerId}")
  .onCreate((snapshot, context) => {
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
    followedUserPostsRef.get().then((docs) => {
      docs.forEach((doc) => {
        if (doc.exists) {
          const postId = doc.id;
          const postData = doc.data();
          timelinePostsRef.doc(postId).set(postData);
        }
      });
    });

    // 4) notifiy followed user
    return admin
      .firestore()
      .collection("users")
      .doc(followerId)
      .get()
      .then((document) => {
        user = document.data();
        var now = new Date();
        var utc = new Date(now.getTime());

        admin.firestore().collection("activity").doc(uid).collection("userActivity").doc().set({
          type: "follow",
          postId: null,
          user: user,
          timestamp: utc.toISOString(),
          seen: false,
        });
      });
  });

//* remove posts from the followers feed when the unfollow
exports.onDeleteFollower = functions.firestore
  .document("/users/{uid}/followers/{followerId}")
  .onDelete((snapshot, context) => {
    const uid = context.params.uid;
    const followerId = context.params.followerId;

    const timelinePostsRef = admin
      .firestore()
      .collection("timeline")
      .doc(followerId)
      .collection("timelinePosts")
      .where("user.uid", "==", uid);

    return timelinePostsRef.get().then((docs) => {
      docs.forEach((doc) => {
        if (doc.exists) {
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

    const userFollowersRef = admin.firestore().collection("users").doc(uid).collection("followers");

    return userFollowersRef.get().then((docs) => {
      // add new posts to each follower feed
      console.log(docs.size);
      docs.forEach((doc) => {
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
    // get the user ID & post ID
    const uid = context.params.uid;
    const postId = context.params.postId;

    let increment;

    // get the post document
    const psotRef = admin.firestore().collection("posts").doc(postId);
    var data;
    // check if the change is like/unlike
    if (change.after.exists && !change.before.exists) {
      // TODO: set the notification message here
      increment = 1;
      data = change.after.data();
    } else if (!change.after.exists && change.before.exists) {
      // TODO: set the notification message here
      increment = -1;
      data = change.before.data();
    } else {
      return null;
    }
    // update the likecount field
    psotRef.set({ likeCount: admin.firestore.FieldValue.increment(increment) }, { merge: true });

    // notify the user
    if (increment == 1) {
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

            if (postOwnerId != uid) {
              admin
                .firestore()
                .collection("activity")
                .doc(postOwnerId)
                .collection("userActivity")
                .doc()
                .set({
                  type: "like",
                  postId: postId,
                  user: user,
                  timestamp: data.timestamp,
                  seen: false,
                });
            }
          });
        });
    }
  });

//* update the the number of comments
exports.updateCommentsCount = functions.firestore
  .document("posts/{postId}/comments/{cid}")
  .onWrite((change, context) => {
    const cid = context.params.cid;
    const postId = context.params.postId;

    let increment;

    const psotRef = admin.firestore().collection("posts").doc(postId);

    var data;

    if (change.after.exists && !change.before.exists) {
      // TODO: set the notification message here
      increment = 1;
      data = change.after.data();
    } else if (!change.after.exists && change.before.exists) {
      // TODO: set the notification message here
      increment = -1;
      data = change.before.data();
    } else {
      return null;
    }

    psotRef.set(
      { commmentCount: admin.firestore.FieldValue.increment(increment) },
      { merge: true }
    );

    if (increment == 1) {
      var postOwnerId;
      return psotRef.get().then((doc) => {
        postOwnerId = doc.data().user.uid;

        if (postOwnerId != data.user.uid) {
          admin
            .firestore()
            .collection("activity")
            .doc(postOwnerId)
            .collection("userActivity")
            .doc()
            .set({
              type: "comment",
              data: data,
              user: data.user,
              timestamp: data.createdAt,
              postId: data.postId,
              seen: false,
            });
        }
      });
    }
  });
