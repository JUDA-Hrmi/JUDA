// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const {logger} = require("firebase-functions");
const {onRequest} = require("firebase-functions/v2/https");

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();
const fieldValue = admin.firestore.FieldValue;

exports.helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

const usersString = "users"; // users collection name
const postsString = "posts"; // posts collection name
const drinksString = "drinks"; // drinks collection name
const taggedPostsString = "taggedPostsString"; // taggedPosts collection name
const likedUsersIDString = "likedUsersID"; // likedUSersID collection name
const likedPostsString = "likedPosts"; // likedPosts collection name
const likedDrinksString = "likedDrinks"; // likedDrinks collection name

// post 업로드
// root collection인 posts에 post가 업로드됐을 때
exports.onPostCreate = functions.firestore
  .document("posts/{postId}")
  .onCreate(async (snapshot, context) =>{
    const postId = context.params.postId; // new post id 추출
    const postFieldData = snapshot.data(); // new post document field data
    const postRef = snapshot.ref; // new post document ref

    const drinkTagsString = "drinkTags"; // drinkTags collection name
    const drinkTagsRef = postRef.collection(drinkTagsString); // drinkTags collection ref
    const drinkTagsSnapshot = await drinkTagsRef.get(); // drinkTags documents snapshot

    // drinkTags collection 순회하여 각 drinkTag document에 post 업로드
    for await (const drinkTagDoc of drinkTagsSnapshot.docs) {
      const drinkId = drinkTagDoc.id; // drink id 추출
      await uploadPostIdToTaggedPost(drinkId, postId, postFieldData);
    }

    // post 작성한 user 및 user id 추출
    const user = postFieldData.user;
    const userId = user.userID;

    // users collection에 post upload
    await uploadPostToUsers(userId, postId, postFieldData);
  });

// drinks 컬렉션의 taggedPosts 하위 컬렉션에 포스트 필드 데이터 업로드
async function uploadPostIdToTaggedPost(drinkId, postId, postFieldData) {
  const drinkRef = db.collection(drinksString).doc(drinkId);

  if ((await drinkRef.get()).exists) {
    const taggedPostRef = drinkRef.collection(taggedPostsString).doc(postId);
    try {
      await taggedPostRef.set(postFieldData);
      console.log(`success upload post :: uploadPostIdToTaggedPost(), drinkId: ${drinkId}, postId: ${postId}`);
    } catch (error) {
      console.error(`error :: uploadPostIdToTaggedPost(), drinkId: ${drinkId}, postId: ${postId}`, error);
    }
  } else {
    console.log(`drink document not exist for drinkId: ${drinkId}`);
  }
}

// users 컬렉션의 posts 하위 컬렉션에 포스트 필드 업로드
async function uploadPostToUsers(userId, postId, postFieldData) {
  const userRef = db.collection(usersString).doc(userId);
  const postRef = userRef.collection(postsString).doc(postId);

  try {
    await postRef.set(postFieldData);
    console.log(`success upload post :: uploadPostToUsers(), userId: ${userId}, postId: ${postId}`);
  } catch (error) {
    console.error(`error :: uploadPostToUsers(), userId: ${userId}, postId: ${postId}`, error);
  }
}

// post 업데이트
// root collection인 posts에 post가 업데이트됐을 때
exports.onPostUpdate = functions.firestore
  .document("posts/{postId}")
  .onUpdate(async (snapshot, context) => {
    // 업데이트 된 post의 id와 field data 추출
    const postId = context.params.postId;
    const postFieldData = snapshot.after.data();

    // post 작성한 user 및 user id 추출
    const user = postFieldData.user;
    const userId = user.userId;

    await Promise.all(
      // # 사용자의 'posts' 컬렉션 내 해당 포스트 업데이트
      updateUserPost(userId, postId, postFieldData),
      // # 사용자의 'likedPosts' 컬렉션 내 해당 포스트 업데이트
      updateUserLikedPosts(userId, postId, postFieldData),
      // # 사용자의 notification 중 'likedPosts' 컬렉션 내 해당 포스트 업데이트
      updateNotificationLikedPosts(userId, postId, postFieldData),
      // # 'drinks' 컬렉션 내 'taggedPosts'에서 해당 포스트 업데이트
      updateTaggedPostDrinks(postId, postFieldData),
    );
  });

// # 사용자의 'posts' 컬렉션 내 해당 포스트 업데이트
async function updateUserPost(userId, postId, postFieldData) {
  const userRef = db.collection(usersString).doc(userId);
  const userPostRef = userRef.collection(postsString).doc(postId);

  if ((await userPostRef.get()).exists) { // user의 하위 posts collection에 해당 post 존재 O
    try {
      await userPostRef.update(postFieldData);
      console.log(`success update post :: updateUserPost(), userId: ${userId}, postId: ${postId}`);
    } catch (error) {
     console.error(`error :: updateUserPost(), userId: ${userId}, postId: ${postId}`, error);
    }
  } else { // user의 하위 collection에 해당 post 존재 X
    console.log(`user(userId: ${userId})'s sub collection(posts) not exist post(postId: ${postId})`);

    try {
      await userPostRef.set(postFieldData);
      console.log(`success upload post :: updateUserPost(), userId: ${userId}, postId: ${postId}`);
    } catch (error) {
      console.error(`error :: upload post user's posts, userId: ${userId}, postId: ${postId}`, error);
    }
  }
}

// # 사용자의 'likedPosts' 컬렉션 내 해당 포스트 업데이트
async function updateUserLikedPosts(userId, postId, postFieldData) {
  const likedPostsString = "likedPosts";
  const userRef = db.collection(usersString).doc(userId);
  const userLikedPostRef = userRef.collection(likedPostsString).doc(postId);

  if ((await userLikedPostRef.get()).exists) { // user의 하위 likedPosts collection에 해당 post 존재 O
    try {
      await userLikedPostRef.update(postFieldData);
      console.log(`success update post :: updateUserLikedPosts(), userId: ${userId}, postId: ${postId}`);
    } catch (error) {
      console.error(`error :: updateUserLikedPosts(), userId: ${userId}, postId: ${postId}`, error);
    }
  } else { // user의 하위 likedPosts collection에 해당 post 존재 X
    console.log(`user(userId: ${userId})'s sub collection(likedPosts) not exist post(postId: ${postId})`);

    try {
      await userLikedPostRef.set(postFieldData);
      console.log(`success upload post :: updateUserLikedPosts(), userId: ${userId}, postId: ${postId}`);
    } catch (error) {
      console.error(`error :: upload post likedPosts, userId: ${userId}, postId: ${postId}`, error);
    }
  }
}

// # 사용자의 notification 중 'likedPosts' 컬렉션 내 해당 포스트 업데이트
async function updateNotificationLikedPosts(userId, postId, postFieldData) {
  const notificationsString = "notifications";
  const notificationId = userId + postId; // notification document id

  const userRef = db.collection(usersString).doc(userId);
  const notificationRef = userRef.collection(notificationsString).doc(notificationId);
  if ((await notificationRef.get()).exists) { // user의 하위 notification collection에 해당 post 존재 O
    try {
      await notificationRef.update(postFieldData);
      console.log(`success update post :: updateNotificationLikedPosts(), userId: ${userId}, postId: ${postId}`);
    } catch (error) {
      console.error(`error :: updateNotificationLikedPosts(), userId: ${userId}, postId: ${postId}`), error;
    }
  } else { // user의 하위 notifications collection에 해당 post 존재 X
    console.log(`user(userId: ${userId})'s sub collection(${notificationsString}) not exist post(postId: ${postId})`);

    try {
      await notificationRef.set(postFieldData);
      console.log(`success upload post :: updateNotificationLikedPosts(), userId: ${userId}, postId: ${postId}`);
    } catch (error) {
      console.error(`error :: upload post ${notificationsString}, userId: ${userId}, postId: ${postId}`, error);
    }
  }
}

// # 'drinks' 컬렉션 내 'taggedPosts'에서 해당 포스트 업데이트
async function updateTaggedPostDrinks(postId, postFieldData) {
  const drinksRef = db.collection(drinksString);
  const drinkTags = postFieldData.drinkTags;

  for (const drinkTag of drinkTags) {
    const drinkId = drinkTag.drinkID;
    const drinkRef = drinksRef.doc(drinkId);
    const taggedPostRef = drinkRef.collection(taggedPostsString).doc(postId);

    if ((await taggedPostRef.get()).exists) { // drink의 하위 taggedPosts collection에 해당 post 존재 O
      try {
        await taggedPostRef.update(postFieldData);
        console.log(`success update post :: updateTaggedPostDrinks(), drinkId: ${drinkId}, postId: ${postId}`);
      } catch (error) {
        console.error(`error :: updateTaggedPostDrinks(), drinkId: ${drinkId}, postId: ${postId}`, error);
      }
    } else { // drink의 하위 taggedPosts collection에 해당 post 존재 X
      console.log(`drink(drinkId: ${drinkId})'s sub collection(${taggedPostsString}) not exist post(postId: ${postId})`);

      try {
        await taggedPostRef.set(postFieldData);
        console.log(`success upload post :: updateTaggedPostDrinks(), drinkId: ${drinkId}, postId: ${postId}`);
      } catch (error) {
        console.error(`error :: upload post ${taggedPostsString}, drinkId: ${drinkId}, postId: ${postId}`, error);
      }
    }
  }
}

// post 삭제
exports.onPostDelete = functions.https.onCall(async (data, context) => {
  const userId = data.userID;
  const postId = data.postID;

  // post와 관련된 collection document 삭제
  await deleteDocumentsRelatedToPost(userId, postId);
});

// post와 관련된 document 삭제하는 함수 병렬처리
async function deleteDocumentsRelatedToPost(userId, postId) {
  await Promise.all(
    // 사용자의 'posts' 컬렉션 내 해당 post 삭제
    deleteUserPost(userId, postId),
    // post 좋아요 누른 모든 user의 'likedPosts'에서 해당 post 삭제
    deleteOtherUsersLikedPost(postId),
    // 'drinks' 컬렉션의 'taggedPosts'에서 해당 post 삭제
    deleteTaggedPostsInDrinks(postId),
  );
}

// 사용자의 'posts' 컬렉션 내 해당 post 삭제
async function deleteUserPost(userId, postId) {
  const userRef = db.collection(usersString).doc(userId);
  const userPostRef = userRef.collection(postsString).doc(postId);

  if ((await userPostRef.get()).exists) { // user의 하위 posts collection에 해당 post 존재 O
    try {
      await userPostRef.delete();
      console.log(`success post delete :: deleteUserPost(), userId: ${userId}, postId: ${postId}`);
    } catch (error) {
      console.error(`error :: deleteUserPost(), userId: ${userId}, postId: ${postId}`, error);
    }
  } else { // user의 하위 posts collection에 해당 post 존재 X
    console.log(`user(userId: ${userId})'s sub collection(${postsString}) not exist post(postId: ${postId})`);
  }
}

// post 좋아요 누른 모든 user의 'likedPosts'에서 해당 post 삭제
async function deleteOtherUsersLikedPost(postId) {
  const likedUsersIDRef = db.collection(postsString).doc(postId).collection(likedUsersIDString);
  const likedUsersIDSnapshot = await likedUsersIDRef.get();

  likedUsersIDSnapshot.forEach(async (likedUserIdDoc) =>{
    const userId = likedUserIdDoc.id;

    const userRef = db.collection(usersString).doc(userId);
    const likedPostRef = userRef.collection(likedPostsString).doc(postId);

    if ((await likedPostRef.get()).exists) { // user의 하위 likedPosts collection에 해당 post 존재 X
      try {
        await likedPostRef.delete();
        console.log(`success likedPost delete :: deleteOtherUsersLikedPost(), userId: ${userId}, likedPostId: ${postId}`);
      } catch (error) {
        console.error(`error :: deleteOtherUsersLikedPost(), userId: ${userId}, likedPostId: ${postId}`, error);
      }
    } else { // user의 하위 likedPosts collection에 해당 post 존재 X
      console.log(`user(userId: ${userId})'s sub collection(${likedPostsString}) not exist post(postId: ${postId})`);
    }
  });
}

// posts/<postID> field data drinkTags 돌면서 얻은 drinkID 갖고 drinks/<drinkID>/taggedPosts/<postID> document 삭제
async function deleteTaggedPostsInDrinks(postId) {
  const postRef = db.collection(postsString).doc(postId);
  const postDoc = await postRef.get();
  const postFieldData = postDoc.data();
  const drinkTags = postFieldData.drinkTags;

  drinkTags.forEach(async (drinkTag) => {
    const drinkId = drinkTag.drinkID;
    const drinkRef = db.collection(drinksString).doc(drinkId);
    const taggedPostRef = drinkRef.collection(taggedPostsString).doc(postId);

    if ((await taggedPostRef.get()).exists) { // drink의 하위 taggedPosts collection에 해당 post 존재 O
      try {
        await taggedPostRef.delete();
        console.log(`success taggedPost delete :: deleteTaggedPostsInDrinks(), drinkId: ${drinkId}, likedPostId: ${postId}`);
      } catch (error) {
        console.error(`error :: deleteTaggedPostsInDrinks(), drinkId: ${drinkId}, likedPostId: ${postId}`);
      }
    } else { // drink의 하위 taggedPosts collection에 해당 post 존재 X
      console.log(`drink(drinkId: ${drinkId})'s sub collection(${taggedPostsString}) not exist post(postId: ${postId})`);
    }
  });
}

// 좋아요

// 게시글에 좋아요를 눌렀을 때
exports.onAddLikedToPost = functions.firestore
  .document("posts/{postId}/likedUsersID/{userId}")
  .onCreate(async (snapshot, context) => {
    const postId = context.params.postId;
    const userId = context.params.userId;

    // 좋아요 count 1 증가
    const postRef = db.collection(postsString).doc(postId);
    try {
      await postRef.update({
        "likedCount": fieldValue.increment(1),
      });
    } catch (error) {
      console.error(`error :: likedCount increment(1), postId: ${postId}`, error);
    }

    // users/<userID>/likedPosts/<postID>에 post upload
    const postDoc = await postRef.get();
    const postFieldData = postDoc.data();
    await uploadUserLikedPosts(userId, postId, postFieldData);
  });

async function uploadUserLikedPosts(userId, postId, postFieldData) {
  const userRef = db.collection(usersString).doc(userId);
  const likedPostRef = userRef.collection(likedPostsString).doc(postId);

  try {
    await likedPostRef.set(postFieldData);
    console.log(`succress upload likedPost :: uploadUserLikedPosts(), userId: ${userId}, likedPostId: ${postId}`);
  } catch (error) {
    console.error(`error :: uploadUserLikedPosts(), userId: ${userId}, likedPostId: ${postId}`, error);
  }
}

// 게시글에 좋아요를 취소했을 때
exports.onDeleteLikedToPost = functions.firestore
  .document("posts/{postId}/likedUsersID/{userId}")
  .onDelete(async (snapshot, context) => {
    const postId = context.params.postId;
    const userId = context.params.userId;

    // 좋아요 count 1 감소
    const postRef = db.collection(postsString).doc(postId);
    try {
      await postRef.update({
        "likedCount": fieldValue.increment(-1),
      });
    } catch (error) {
      console.error(`error :: likedCount increment(-1), postId: ${postId}`, error);
    }

    // users/<userID>/likedPosts/<postID>에 post delete
    await deleteUserLikedPosts(userId, postId);
  });

async function deleteUserLikedPosts(userId, postId) {
  const userRef = db.collection(usersString).doc(userId);
  const likedPostRef = userRef.collection(likedPostsString).doc(postId);

  try {
    await likedPostRef.delete();
    console.log(`succress delete likedPost :: uploadUserLikedPosts(), userId: ${userId}, likedPostId: ${postId}`);
  } catch (error) {
    console.error(`error :: deleteUserLikedPosts(), userId: ${userId}, likedPostId: ${postId}`, error);
  }
}

// 술에 좋아요를 눌렀을 때
exports.onAddLikedToDrink = functions.firestore
  .document("drinks/{drinkId}/likedUsersId/{userId}")
  .onCreate(async (snapshot, context) => {
    const drinkId = context.params.drinkId;
    const userId = context.params.userId;

    // users/<userID>/likedDrinks/<drinkID>에 drink upload
    const drinkRef = db.collection(drinksString).doc(drinkId);
    const drinkDoc = await drinkRef.get();
    const drinkFieldData = drinkDoc.data();
    await uploadUserLikedDrinks(userId, drinkId, drinkFieldData);
  });

async function uploadUserLikedDrinks(userId, drinkId, drinkFieldData) {
  const userRef = db.collection(usersString).doc(userId);
  const likedDrinkRef = userRef.collection(likedDrinksString).doc(drinkId);

  try {
    await likedDrinkRef.set(drinkFieldData);
    console.log(`success upload likedDrink :: uploadUserLikedDrinks(), userId: ${userId}, drinkId: ${drinkId}`);
  } catch (error) {
    console.error(`error :: uploadUserLikedDrinks() userId: ${userId}, drinkId: ${drinkId}`, error);
  }
}

// 술에 좋아요를 취소했을 때
exports.onDeleteLikedToDrink = functions.firestore
  .document("drinks/{drinkId}/likedUsersId/{userId}")
  .onDelete(async (snapshot, context) => {
    const drinkId = context.params.drinkId;
    const userId = context.params.userId;

    await deleteUserLikedDrinks(userId, drinkId);
  });

async function deleteUserLikedDrinks(userId, drinkId) {
  const userRef = db.collection(usersString).doc(userId);
  const likedDrinkRef = userRef.collection(likedDrinksString).doc(drinkId);

  try {
    await likedDrinkRef.delete();
    console.log(`success delete likedDrink :: deleteUserLikedDrinks(), userId: ${userId}, drinkId: ${drinkId}`);
  } catch (error) {
    console.error(`error :: deleteUserLikedDrinks() userId: ${userId}, drinkId: ${drinkId}`, error);
  }
}

// 술 데이터 업데이트

// drink document field data(rating) 수정됐을 때
exports.onUpdateDrinkRating = functions.firestore
  .document("driks/{drinkId}")
  .onUpdate(async (snapshot, context) => {
    const drinkId = context.params.drinkId;
    const drinkFieldData = snapshot.after.data();
    const drinkRating = drinkFieldData.rating;

    const likedUsersIdRef = snapshot.after.ref.collection(likedUsersIDString);
    const likedUsersIdSnapshot = await likedUsersIdRef.get();

    for (const likedUsersIdDoc of likedUsersIdSnapshot.docs) {
      const likedUserId = likedUsersIdDoc.id;
      await updateUsersLikedDrinkRating(likedUserId, drinkId, drinkRating);
    }
  });

  async function updateUsersLikedDrinkRating(userId, drinkId, rating) {
    const userRef = db.collection(usersString).doc(userId);
    const likedDrinkRef = userRef.collection(likedDrinksString).doc(drinkId);

    if ((await likedDrinkRef.get()).exists) { // user의 하위 likedDrinks collection에 해당 drink 존재 O
      try {
        await likedDrinkRef.update({
          "rating": rating,
        });
        console.log(`success update drink updateUsersLikedDrinkRating(), userId: ${userId}, drinkId: ${drinkId}, rating: ${rating}`);
      } catch (error) {
        console.error(`error :: updateUsersLikedDrinkRating(), userId: ${userId}, drinkId: ${drinkId}, rating: ${rating}`, error);
      }
    } else { // user의 하위 likedDrinks collection에 해당 drink 존재 x
      console.log(`user(userId: ${userId})'s sub collection(${likedDrinksString}) not exist drink(drinkId: ${drinkId})`);

      const drinkRef = db.collection(drinksString).doc(drinkId);
      const drinkSnapshot = await drinkRef.get();
      const drinkFieldData = drinkSnapshot.data();

      try {
        await likedDrinkRef.set(drinkFieldData);
        console.log(`success upload drink :: updateUsersLikedDrinkRating(), userId: ${userId}, drinkId: ${drinkId}`);
      } catch (error) {
        console.error(`error(fail upload drink) :: updateUsersLikedDrinkRating() userId: ${userId}, drinkId: ${drinkId}`, error);
      }
    }
  }
