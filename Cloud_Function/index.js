// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const {logger} = require("firebase-functions");
const {onRequest} = require("firebase-functions/v2/https");

// The Firebase Admin SDK to access Firestore.
const {initializeApp} = require("firebase-admin/app");
const {getFirestore, FieldValue} = require("firebase-admin/firestore");

import { event } from "firebase-functions/v1/analytics";
import {
  onDocumentWritten,
  onDocumentCreated,
  onDocumentUpdated,
  onDocumentDeleted,
  Change,
  FirestoreEvent
} from "firebase-functions/v2/firestore";

initializeApp();

const db = getFirestore();

exports.helloWorld = onRequest((request, response) => {
  logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

const usersString = "users"; // users collection name
const postsString = "posts"; // posts collection name
const drinksString = "drinks"; // drinks collection name
const taggedPostsString = "taggedPostsString"; // taggedPosts collection name

// post 업로드
// root collection인 posts에 post가 업로드됐을 때
exports.onPostCreate = onDocumentCreated("posts/{postId}", async (event) => {
  const postId = event.params.postId; // new post id 추출
  const postFieldData = event.data; // new post document field data
  const postDocRef = postFieldData.ref; // new post document ref

  const drinkTagsString = "drinkTags"; // drinkTags collection name
  const drinkTagsRef = postDocRef.collection(drinkTagsString); // drinkTags collection ref
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
exports.onPostUpdate = onDocumentUpdated("posts/{postId}", async (event) => {
  // 업데이트 된 post의 id와 field data 추출
  const postId = event.params.postId;
  const postFieldData = event.data.before;

  // post 작성한 user 및 user id 추출
  const user = postFieldData.user;
  const userId = user.userID;

  await Promise.all(
    // # 사용자의 'posts' 컬렉션 내 해당 포스트 업데이트
    updateUserPost(userId, postId, postFieldData),
    // # 사용자의 'likedPosts' 컬렉션 내 해당 포스트 업데이트
    updateUserLikedPosts(userId, postId, postFieldData),
    // # 사용자의 notification 중 'likedPosts' 컬렉션 내 해당 포스트 업데이트
    updateNotificationLikedPosts(userId, postId, postFieldData),
    // # 'drinks' 컬렉션 내 'taggedPosts'에서 해당 포스트 업데이트
    updateTaggedPostDrinks(postId, postFieldData)
  )
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
  
  if((await userLikedPostRef.get()).exists) { // user의 하위 likedPosts collection에 해당 post 존재 O
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
  if((await notificationRef.get()).exists) { // user의 하위 notification collection에 해당 post 존재 O
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

    if((await taggedPostRef.get()).exists) { // drink의 하위 taggedPosts collection에 해당 post 존재 O
      try {
        await taggedPostRef.update(postFieldData);
        console.log(`success update post :: updateTaggedPostDrinks(), drinkId: ${drinkId}, postId: ${postId}`);
      } catch (error) {
        console.error(`error :: updateTaggedPostDrinks(), drinkId: ${drinkId}, postId: ${postId}`, error);
      }
    } else {  // drink의 하위 taggedPosts collection에 해당 post 존재 X
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