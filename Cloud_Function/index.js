// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const {logger} = require("firebase-functions");
const {onRequest} = require("firebase-functions/v2/https");

// The Firebase Admin SDK to access Firestore.
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

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
  const taggedPostsString = "taggedPostsString"; // taggedPosts collection name

  const drinkRef = db.collection(drinksString).doc(drinkId);
  const taggedPostRef = drinkRef.collection(taggedPostsString).doc(postId);
  try {
    await taggedPostRef.set(postFieldData);    
  } catch (error) {
    console.error(`error :: uploadPostIdToTaggedPost(), drinkId: ${drinkId}, postId: ${postId}`);
  }
}

// users 컬렉션의 posts 하위 컬렉션에 포스트 필드 업로드
async function uploadPostToUsers(userId, postId, postFieldData) {
  const userRef = db.collection(usersString).doc(userId);
  const postRef = userRef.collection(postsString).doc(postId);
  try {
    await postRef.set(postFieldData); 
  } catch (error) {
    console.error(`error :: uploadPostToUsers(), userId: ${userId}, postId: ${postId}`);
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

  // # 사용자의 'posts' 컬렉션 내 해당 포스트 업데이트
  // # 사용자의 'likedPosts' 컬렉션 내 해당 포스트 업데이트
  // # 사용자의 notification 중 'likedPosts' 컬렉션 내 해당 포스트 업데이트
  // # 'drinks' 컬렉션 내 'taggedPosts'에서 해당 포스트 업데이트
  
});

// # 사용자의 'posts' 컬렉션 내 해당 포스트 업데이트
async function updateUserPost(userId, postId, postFieldData) {
  const userRef = db.collection(usersString).doc(userId);
  const userPostRef = userRef.collection(postsString).doc(postId);
  try {
    await userPostRef.update(postFieldData); 
  } catch (error) {
   console.error(`error :: updateUserPost(), userId: ${userId}, postId: ${postId}`); 
  }
}

// # 사용자의 'likedPosts' 컬렉션 내 해당 포스트 업데이트
async function updateUserLikedPosts(userId, postId, postFieldData) {
  const likedPostsString = "likedPosts";
  const userRef = db.collection(usersString).doc(userId);
  const userLikedPostRef = userRef.collection(likedPostsString).doc(postId);
  try {
    await userLikedPostRef.update(postFieldData); 
  } catch (error) {
    console.error(`error :: updateUserLikedPosts(), userId: ${userId}, postId: ${postId}`);
  }
}

// # 사용자의 notification 중 'likedPosts' 컬렉션 내 해당 포스트 업데이트

// # 'drinks' 컬렉션 내 'taggedPosts'에서 해당 포스트 업데이트