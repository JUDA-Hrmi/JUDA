// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const {logger} = require("firebase-functions");
const {onRequest} = require("firebase-functions/v2/https");
// const {onDocumentCreated} = require("firebase-functions/v2/firestore");

// The Firebase Admin SDK to access Firestore.
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

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

const drinksString = "drinks"; // drinks collection name
const drinkTagsString = "drinkTags"; // drinkTags collection name
const taggedPostsString = "taggedPostsString"; // taggedPosts collection name
const usersString = "users" // users collection name

// post 업로드
// root collection인 posts에 post가 업로드됐을 때
exports.onPostCreate = onDocumentCreated("posts/{postId}", async (event) => {
  const postId = event.params.postId; // new post id 추출
  const postFieldData = event.data; // new post document field data
  const postDocRef = postFieldData.ref; // new post document ref

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
});

// drinks 컬렉션의 taggedPosts 하위 컬렉션에 포스트 필드 데이터 업로드
async function uploadPostIdToTaggedPost(drinkId, postId, postFieldData) {
  drinkDocRef = db.collection(drinksString).doc(drinkId);
  taggedPostRef = drinkDocRef.collection(taggedPostsString).doc(postId);
  const res = await taggedPostRef.doc(postId).set(postFieldData);
}

// users 컬렉션의 posts 하위 컬렉션에 포스트 필드 업로드
async function uploadPostToUsers(userId, postId, postFieldData) {
  userDocRef = db.collection(usersString).doc(userId);
}