# The Cloud Functions for Firebase SDK to create Cloud Functions and set up triggers.
from firebase_functions import https_fn
from firebase_functions.firestore_fn import (
  on_document_created,
  on_document_deleted,
  on_document_updated,
  Event,
  Change,
  DocumentSnapshot
)

import firebase_admin
from firebase_admin import messaging
from google.cloud.firestore import AsyncClient
from google.cloud import exceptions

# 비동기 병렬처리를 위한 비동기 I/O 표준 라이브러리 import
import asyncio

# 코드 배포
# firebase deploy --only functions

firebase_admin.initialize_app()

db = AsyncClient()

# 게시글 업로드
# root collection인 posts에 post가 업로드됐을 때
@on_document_created(document="posts/{post_id}")
async def upload_new_post(event: Event[DocumentSnapshot]) -> None:
    post_id = event.params["post_id"] # 새 포스트의 ID 추출
    post_document_ref = event.reference # 새 포스트 문서의 참조
    post_field_data = event.data.to_dict() # 새 포스트 데이터 추출

    # drinkTags 컬렉션을 순회하여 각 drinkTag 문서에 대해 포스트 업로드
    drinkTags_collection_ref = post_document_ref.collection("drinkTags")
    async for drinkTag_doc in drinkTags_collection_ref.stream():
        # drink ID 추출
        drink_id = drinkTag_doc.id
        # taggedPosts 컬렉션에 포스트 업로드
        await upload_taggedPosts_post(drink_id=drink_id, 
                                      post_id=post_id, 
                                      post_field_data=post_field_data)
    
    # 포스트 작성자의 ID 추출
    user_data = post_field_data["user"]
    user_id = user_data["userID"]

    # users 컬렉션에 포스트 업로드
    await upload_users_post(user_id=user_id, 
                            post_id=post_id, 
                            post_field_data=post_field_data)

# drinks 컬렉션의 taggedPosts 하위 컬렉션에 포스트 업로드
async def upload_taggedPosts_post(drink_id, post_id, post_field_data):
    try:
        drink_document_ref = db.collection("drinks").document(drink_id)
        taggedPosts_collection_ref = drink_document_ref.collection("taggedPosts")
        await taggedPosts_collection_ref.document(post_id).set(post_field_data)

    except exceptions.FirestoreError as e:
        print(f"Firestore 오류: {e}")
        print(f"error :: upload_taggedPosts_post(), drink_id:{drink_id}, post_id:{post_id}")

# users 컬렉션의 posts 하위 컬렉션에 포스트 업로드
async def upload_users_post(user_id, post_id, post_field_data):
    try:
        user_document_ref = db.collection("users").document(user_id)
        posts_collection_ref = user_document_ref.collection("posts")
        await posts_collection_ref.document(post_id).set(post_field_data)

    except exceptions.FirestoreError as e:
        print(f"Firestore 오류: {e}")
        print(f"error :: upload_users_post(), user_id:{user_id}, post_id:{post_id}")

# 게시글 업데이트
@on_document_updated(document="posts/{post_id}")
async def update_posts_post(event: Event[Change[DocumentSnapshot]]):
    # 업데이트된 포스트 데이터 가져오기
    updated_post_field_data = event.data.after.to_dict()

    # 포스트에 연결된 사용자 데이터 추출
    user_data = updated_post_field_data["user"]
    user_id = user_data["userID"]
    post_id = event.params["post_id"]
    
    await asyncio.gather(
        # 사용자의 'posts' 컬렉션 내 해당 포스트 업데이트
        await update_user_post(user_id, post_id, updated_post_field_data),
        # 사용자의 'likedPosts' 컬렉션 내 해당 포스트 업데이트
        await update_user_liked_post(user_id, post_id, updated_post_field_data),
        # 사용자의 notification 중 'likedPosts' 컬렉션 내 해당 포스트 업데이트
        await update_user_notifications_for_liked_post(user_id, post_id, updated_post_field_data),
        # 'drinks' 컬렉션 내 'taggedPosts'에서 해당 포스트 업데이트
        await update_tagged_posts_in_drinks(post_id, updated_post_field_data)
    )

# 사용자의 게시글을 업데이트하는 함수입니다.
async def update_user_post(user_id, post_id, updated_post_field_data):
    try:
        # 사용자의 'posts' 컬렉션 내 특정 게시글 문서 참조를 얻습니다.
        user_post_document_ref = db.collection("users").document(user_id).collection("posts").document(post_id)
        # 문서의 존재 여부를 확인합니다.
        post_document = await user_post_document_ref.get()
        if post_document.exists:
            # 문서가 존재하면 업데이트된 데이터로 문서를 업데이트합니다.
            await user_post_document_ref.update(updated_post_field_data)

    except exceptions.FirestoreError as e:
        print(f"Firestore 오류: {e}")
        print(f"error :: update_user_post(), user_id:{user_id}, post_id:{post_id}")

# 사용자의 'likedPosts' 컬렉션 내 특정 게시글을 업데이트하는 함수입니다.
async def update_user_liked_post(user_id, post_id, updated_post_field_data):
    try:
        # 사용자의 'likedPosts' 컬렉션 내 특정 게시글 문서 참조를 얻습니다.
        user_likedPosts_document_ref = db.collection("users").document(user_id).collection("likedPosts").document(post_id)
        # 문서의 존재 여부를 확인합니다.
        liked_post_document = await user_likedPosts_document_ref.get()
        if liked_post_document.exists:
            # 문서가 존재하면 업데이트된 데이터로 문서를 업데이트합니다.
            await user_likedPosts_document_ref.update(updated_post_field_data)

    except exceptions.FirestoreError as e:
        print(f"Firestore 오류: {e}")
        print(f"error :: update_user_liked_post(), user_id:{user_id}, post_id:{post_id}")

# 사용자의 알림 중 'likedPosts' 컬렉션 내 특정 게시글을 업데이트하는 함수입니다.
async def update_user_notifications_for_liked_post(user_id, post_id, updated_post_field_data):
    try:
        # 사용자의 'notifications' 컬렉션을 순회하며 각 알림 문서에 대해 처리합니다.
        user_notifications_ref = db.collection("users").document(user_id).collection("notifications")
        async for notification_document in user_notifications_ref.stream():
            # 각 알림 문서 내 'likedPosts' 컬렉션의 특정 게시글 문서 참조를 얻습니다.
            liked_post_document_ref = notification_document.reference.collection("likedPosts").document(post_id)
            # 문서의 존재 여부를 확인합니다.
            liked_post_document = await liked_post_document_ref.get()
            if liked_post_document.exists:
                # 문서가 존재하면 업데이트된 데이터로 문서를 업데이트합니다.
                await liked_post_document_ref.update(updated_post_field_data)

    except exceptions.FirestoreError as e:
        print(f"Firestore 오류: {e}")
        print(f"error :: update_user_notifications_for_liked_post(), user_id:{user_id}, post_id:{post_id}")

# 'drinks' 컬렉션 내 'taggedPosts'에서 특정 게시글을 업데이트하는 함수입니다.
async def update_tagged_posts_in_drinks(post_id, updated_post_field_data):
    try:
        # 'drinks' 컬렉션을 순회하며 각 음료 문서에 대해 처리합니다.
        drinks_ref = db.collection("drinks")
        async for drink_document in drinks_ref.stream():
            # 각 음료 문서 내 'taggedPosts' 컬렉션의 특정 게시글 문서 참조를 얻습니다.
            tagged_post_document_ref = drink_document.reference.collection("taggedPosts").document(post_id)
            # 문서의 존재 여부를 확인합니다.
            tagged_post_document = await tagged_post_document_ref.get()
            if tagged_post_document.exists:
                # 문서가 존재하면 업데이트된 데이터로 문서를 업데이트합니다.
                await tagged_post_document_ref.update(updated_post_field_data)

    except exceptions.FirestoreError as e:
        print(f"Firestore 오류: {e}")
        print(f"error :: update_tagged_posts_in_drinks(), post_id:{post_id}")

# 게시글 삭제
@https_fn.on_call()
async def posts_single_post_delete(req: https_fn.CallableRequest):
    # 요청 데이터를 비동기적으로 파싱
    request_data = await req.data.to_dict()

    # 'userID'와 'postID' 값을 추출
    user_id = request_data["userID"]
    post_id = request_data["postID"]

    # post와 관련된 document 삭제
    await delete_related_post_documents_parallel(user_id, post_id)

# post와 관련된 document 삭제하는 함수 병렬처리
async def delete_related_post_documents_parallel(user_id, post_id):
    await asyncio.gather(
        # 사용자의 게시글 삭제
        delete_user_post(user_id, post_id),
        # 게시글을 좋아한 모든 사용자의 likedPosts에서 해당 게시글 삭제
        delete_liked_posts(post_id),
        # 모든 관련 drinks 문서의 taggedPosts에서 해당 게시글 삭제
        delete_tagged_posts_in_drinks(post_id)
    )

# users의 posts 하위 collection에서 삭제된 post document 삭제
async def delete_user_post(user_id, post_id):
    try:
        user_document_ref = db.collection("users").document(user_id) # user의 document referece 추출
        user_post_document_ref = user_document_ref.collection("posts").document(post_id) # user의 post document referece 추출
        # 해당 post 삭제
        await user_post_document_ref.delete()

    except exceptions.FirestoreError as e:
        print(f"Firestore 오류: {e}")
        print(f"error :: delete_user_post(), user_id:{user_id}, post_id:{post_id}")

# posts/likedUsersID 돌면서 해당 userID로 users/<userID>/likedPosts/<postID> document 삭제
async def delete_liked_posts(post_id):
    try:
        liked_users_id_ref = db.collection("posts").document(post_id).collection("likedUsersID")
        async for liked_users_id_document in liked_users_id_ref.stream():
            liked_user_id = liked_users_id_document.id
            liked_post_document_ref = db.collection("users").document(liked_user_id).collection("likedPosts").document(post_id)
            liked_post_document = await liked_post_document_ref.get()
            if liked_post_document.exists:
                await liked_post_document_ref.delete()

    except exceptions.FirestoreError as e:
        print(f"Firestore 오류: {e}")
        print(f"error :: delete_liked_posts({post_id})")

# posts/<postID> field data drinkTags 돌면서 얻은 drinkID 갖고 drinks/<drinkID>/taggedPosts/<postID> document 삭제
async def delete_tagged_posts_in_drinks(post_id):
    try:
        post_document = await db.collection("posts").document(post_id).get() # post document field data 추출
        if post_document.exists:
            post_field_data = post_document.to_dict()

            drink_tags = post_field_data.get("drinkTags", [])  # 'drinkTags'가 없는 경우 빈 리스트 반환
            for drink_tag in drink_tags:
                drink_id = drink_tag["drinkID"] # drink ID 추출

                drink_document_ref = db.collection("drinks").document(drink_id)
                tagged_post_document_ref = drink_document_ref.collection("taggedPosts").document(post_id)
                tagged_post_document = await tagged_post_document_ref.get()
                if tagged_post_document.exists:
                    await tagged_post_document_ref.delete() # 태그된 게시글 문서 삭제

    except exceptions.FirestoreError as e:
        print(f"Firestore 오류: {e}")
        print(f"error :: delete_tagged_posts_in_drinks({post_id})")

# 좋아요
# 게시글에 좋아요를 눌렀을 때
# posts/<post_id>/likedUsersID/<user_id> 로 빈 document가 추가됐을 때
@on_document_created(document="posts/{post_id}/likedUsersID/{user_id}")
async def add_liked_to_post(event: Event[DocumentSnapshot]):
    post_id = event.params["post_id"]
    user_id = event.params["user_id"]

    post_document_ref = db.collection("posts").document(post_id)

    # users/<userID>/likedPosts/<postID>에 post upload
    upload_users_likedPosts(user_id=user_id, 
                           post_id=post_id, 
                           post_document_ref=post_document_ref)

async def upload_users_likedPosts(user_id, post_id, post_document_ref):
    try:
        post_document_snapshot = await post_document_ref.get()
        post_field_data = post_document_snapshot.to_dict()

        users_document_ref = db.collection("users").document(user_id)
        users_likedPosts_collection_ref = users_document_ref.collection("likedPosts")

        # likedPosts에 post field data 업로드
        await users_likedPosts_collection_ref.document(post_id).set(post_field_data)

    except exceptions.FirestoreError as e:
        print(f"Firestore 오류: {e}")
        print(f"error :: upload_users_likedPosts(), user_id:{user_id}, post_id:{post_id}")

# 게시글에 좋아요를 취소했을 때
# posts/<post_id>/likedUsersID/<user_id> document가 삭제됐을 때
@on_document_deleted(document="posts/{post_id}/likedUsersID/{user_id}")
async def cancel_liked_to_post(event: Event[DocumentSnapshot]):
    post_id = event.params["post_id"]
    user_id = event.params["user_id"]

    try:
        users_document_ref = db.collection("users").document(user_id)
        users_likedPosts_collection_ref = users_document_ref.collection("likedPosts")

        # likedPosts에 post document 삭제
        await users_likedPosts_collection_ref.document(post_id).delete()
    except exceptions.FirestoreError as e:
        print(f"Firestore 오류: {e}")
        print(f"error :: cancel_liked_to_post(), user_id:{user_id}, post_id:{post_id}")

# 술 좋아요를 눌렀을 때
# drinks/<drink_id>/likedUsersID/<user_id> 로 빈 document가 추가됐을 때
@on_document_created(document="drinks/{drink_id}/likedUsersID/{user_id}")
async def add_liked_to_drink(event: Event[DocumentSnapshot]):
    drink_id = event.params["drink_id"]
    user_id = event.params["user_id"]

    drink_document_ref = db.collection("drinks").document(drink_id)

    # users/<userID>/likedDrinks/<drinkID>에 drink upload
    await upload_users_likedDrinks(user_id=user_id, 
                             drink_id=drink_id, 
                             drink_document_ref=drink_document_ref)

async def upload_users_likedDrinks(user_id, drink_id, drink_document_ref):
    try:
        drink_document_snapshot = await drink_document_ref.get()
        drink_field_data = drink_document_snapshot.to_dict()

        users_document_ref = db.collection("users").document(user_id)
        users_likedDrinks_collection_ref = users_document_ref.collection("likedDrinks")

        # likedPosts에 drink field data 업로드
        await users_likedDrinks_collection_ref.document(drink_id).set(drink_field_data)

    except exceptions.FirestoreError as e:
        print(f"Firestore 오류: {e}")
        print(f"error :: upload_users_likedDrinks(), user_id:{user_id}, drink_id:{drink_id}")

# 술 좋아요를 취소했을 때
# drinks/<drink_id>/likedUsersID/<user_id> document가 삭제됐을 때
@on_document_deleted(document="drinks/{drink_id}/likedUsersID/{user_id}")
async def cancel_liked_to_drink(event: Event[DocumentSnapshot]):
    drink_id = event.params["drink_id"]
    user_id = event.params["user_id"]

    try:
        users_document_ref = db.collection("users").document(user_id)
        users_likedDrinks_collection_ref = users_document_ref.collection("likedDrinks")

        # likedDrinks에 drink document 삭제
        await users_likedDrinks_collection_ref.document(drink_id).delete()

    except exceptions.FirestoreError as e:
        print(f"Firestore 오류: {e}")
        print(f"error :: cancel_liked_to_drink(), user_id:{user_id}, drink_id:{drink_id}")

# 술 데이터 업데이트

# drink document field data 수정됐을 때
@on_document_updated(document="drinks/{drink_id}")
async def update_users_likedDrinks_rating(event: Event[Change[DocumentSnapshot]]):
    # 업데이트된 drink 데이터 가져오기
    updated_drink_field_data = event.data.after.to_dict()
    updated_drink_rating = updated_drink_field_data["rating"]

    liked_users_id_ref = event.reference.collection("likedUsersID")
    try:
        # 'likedUsersID' 컬렉션에서 모든 liked user 순회
        async for liked_users_id_document in liked_users_id_ref.stream():
            liked_users_id = liked_users_id_document.id # user_id 추출

            user_document_ref = db.collection("users").document(liked_users_id)
            user_document = await user_document_ref.get()
            if user_document.exists:
                await user_document_ref.update({"rating": updated_drink_rating})

    except exceptions.FirestoreError as e:
        print(f"Firestore 오류: {e}")
        print(f"error :: update_users_likedDrinks_rating()")

# drink의 하위 collection인 agePreferenceUID가 수정됐을 때
@on_document_updated(document="drinks/{drink_id}/agePreferenceUID/{age}/usersID/{user_id}")
async def update_users_likedDrinks_agePreferenceUID(event: Event[Change[DocumentSnapshot]]):
    drink_id = event.params["drink_id"] # 업데이트된 drink의 id 추출
    user_id = event.params["user_id"] # 추가된 user의 id 추출
    age = event.params["age"] # 수정된 연령대 추출

    try:
        drink_document_ref = db.collection("drinks").document(drink_id)
        liked_users_id_ref = drink_document_ref.collection("likedUsersID")

        async for liked_users_id_document in liked_users_id_ref.stream():
            liked_users_id = liked_users_id_document.id # user_id 추출

            user_document_ref = db.collection("users").document(liked_users_id)
            user_document = await user_document_ref.get()
            if user_document.exists:
                user_agePreferenceUID_ref = user_document_ref.collection("agePreferenceUID")
                age_ref = user_agePreferenceUID_ref.document(age).collection("usersID")
                # 연령대 document 내 'usersID' 컬렉션에 업데이트된 사용자 ID document 생성
                await age_ref.document(user_id).set({})

    except exceptions.FirestoreError as e:
        print(f"Firestore 오류: {e}")
        print(f"error :: update_users_likedDrinks_agePreferenceUID(), user_id:{user_id}, drink_id:{drink_id}")



# drink의 하위 collection인 genderPreferenceUID가 수정됐을 때
@on_document_updated(document="drinks/{drink_id}/genderPreferenceUID/{gender}/usersID/{user_id}")
async def update_users_likedDrinks_genderPreferenceUID(event: Event[Change[DocumentSnapshot]]):
    drink_id = event.params["drink_id"] # 업데이트된 drink의 id 추출
    user_id = event.params["user_id"] # 추가된 user의 id 추출
    gender = event.params["gender"] # 수정된 연령대 추출

    try:
        drink_document_ref = db.collection("drinks").document(drink_id)
        liked_users_id_ref = drink_document_ref.collection("likedUsersID")

        async for liked_users_id_document in liked_users_id_ref.stream():
            liked_users_id = liked_users_id_document.id # user_id 추출

            user_document_ref = db.collection("users").document(liked_users_id)
            user_document = await user_document_ref.get()
            if user_document.exists:
                user_genderPreferenceUID_ref = user_document_ref.collection("genderPreferenceUID")
                gender_ref = user_genderPreferenceUID_ref.document(gender).collection("usersID")
                # 성별 document 내 'usersID' 컬렉션에 업데이트된 사용자 ID document 생성
                await gender_ref.document(user_id).set({})

    except exceptions.FirestoreError as e:
        print(f"Firestore 오류: {e}")
        print(f"error :: update_users_likedDrinks_genderPreferenceUID(), user_id:{user_id}, drink_id:{drink_id}")

# 회원탈퇴
@https_fn.on_call()
async def delete_user_data(req: https_fn.CallableRequest):
    # 요청 데이터를 비동기적으로 파싱
    request_data = await req.data.to_dict()
    # 'userID' 값을 추출
    user_id = request_data["userID"]
    user_document_ref = db.collection("users").document(user_id)

    asyncio.gather(
        # 사용자의 게시글과 관련된 문서 삭제
        delete_user_posts(ref=user_document_ref, user_id=user_id),
        # 사용자가 좋아요를 누른 게시글의 좋아요 누른 사용자 리스트에서 사용자 id 삭제
        delete_user_id_liked_posts_reference(ref=user_document_ref, user_id=user_id),
        # 사용자가 좋아요를 누른 술의 좋아요 누른 사용자 리스트에서 사용자 id 삭제
        delete_user_id_liked_drinks_references(ref=user_document_ref, user_id=user_id)
    )

# user/posts에 접근하여 postID를 통해 root collection인 posts에서 post delete
async def delete_user_posts(ref, user_id):
    try:
        user_posts_ref = ref.collection("posts")
        async for user_post_document in user_posts_ref.stream():
            post_id = user_post_document.id # post_id 추출
            post_document_ref = db.collection("posts").document(post_id)
            post_document = await post_document_ref.get()
            # 해당 post document가 존재하면 삭제
            if post_document.exists:
                await post_document_ref.delete()
            # post와 관련된 document 삭제
            await delete_related_post_documents_parallel(user_id=user_id, post_id=post_id)

    except exceptions.FirestoreError as e:
        print(f"Firestore 오류: {e}")
        print(f"error :: delete_user_posts(), user_id:{user_id}")

# user/likedPosts에 접근하여 postID를 통해 root collection인 posts에 접근하여 posts/likedUsersID에서 해당 userID를 delete
async def delete_user_id_liked_posts_reference(ref, user_id):
    try :
        user_liked_posts_ref = ref.collection("likedPosts")
        async for liked_post_document in user_liked_posts_ref.stream():
            liked_post_id = liked_post_document.id # 좋아요 누른 post_id 추출
            post_document_ref = db.collection("posts").document(liked_post_id)
            post_document = await post_document_ref.get()
            # 해당 post document가 존재하면
            if post_document.exists:
                liked_users_id_ref = post_document_ref.collection("likedUsersID")
                liked_user_id_document_ref = liked_users_id_ref.document(user_id)
                liked_user_id_document = await liked_user_id_document_ref.get()
                if liked_user_id_document.exists:
                    await liked_user_id_document_ref.delete()
    
    except exceptions.FirestoreError as e:
        print(f"Firestore 오류: {e}")
        print(f"error :: delete_user_id_liked_posts_reference(), user_id:{user_id}")

# user/likedDrinks에 접근하여 drinkID를 통해 root collection인 drinks에 접근하여 drinks/likedUsersID에서 해당 userID를 delete
async def delete_user_id_liked_drinks_references(ref, user_id):
    try:
        user_liked_drinks_ref = ref.collection("likedDrinks")
        async for liked_drink_document in user_liked_drinks_ref.stream():
            liked_drink_id = liked_drink_document.id # 좋아요 누른 drink_id 추출
            drink_document_ref = db.collection("drinks").document(liked_drink_id)
            drink_document = await drink_document_ref.get()
            # 해당 drink document가 존재하면
            if drink_document.exists:
                liked_users_id_ref = drink_document_ref.collection("likedUsersID")
                liked_user_id_document_ref = liked_users_id_ref.document(user_id)
                liked_user_id_document = await liked_user_id_document_ref.get()
                if liked_user_id_document.exists:
                    await liked_user_id_document_ref.delete()
    
    except exceptions.FirestoreError as e:
        print(f"Firestore 오류: {e}")
        print(f"error :: delete_user_id_liked_drinks_references(), user_id:{user_id}")

# user/notifications에 추가가 됐을 떄(즉, 누군가가 사용자의 게시글에 좋아요 눌렀을 때)
@on_document_created(document="users/{user_id}/notifications/{notification_id}")
async def send_fcm_notification(event: Event[DocumentSnapshot]):
    user_id = event.params["user_id"] # 좋아요가 눌린 게시글의 작성자 user_id 추출

    new_notification = event.data.to_dict() # notification 하위 필드 데이터 딕셔너리 형태로 추출
    liked_user_id = new_notification["likedUser"]["userID"] # notification 하위 필드 데이터 중 likedUser의 userID 추출
    liked_user_name = new_notification["likedUser"]["userName"] # notification 하위 필드 데이터 중 likedUser의 userName 추출
    print(f"좋아요 누른 사람 ID: {liked_user_id}, 이름: {liked_user_name}")

    # 유저의 fcm 토큰 추출
    user_fcm_token = await get_user_fcm_token(user_id=user_id)

    # 유저의 fcm 토큰 값을 가져오는 데 성공한 경우
    if user_fcm_token is not None:
        # fcm message
        message = {
            "message":{
                "token":f"{user_fcm_token}",
                "notification":{
                    "title":"주다",
                    "body":f"{liked_user_name}님이 술상에 좋아요를 눌렀어요."
                }
            }
        }
        try:
            await messaging.send_message(message) # fcm message 전송
            print("FCM 메시지 전송 성공")
            print(f"user_id:{user_id}, liked_user_id:{liked_user_id}, liked_user_name:{liked_user_name}")
        except Exception as e: # fcm message 전송 실패
            print(f"FCM 메시지 전송 오류: {e}")
            print(f"user_id:{user_id}, liked_user_id:{liked_user_id}, liked_user_name:{liked_user_name}")

    # 유저의 fcm 토큰 값을 가져오는 데 실패한 경우
    else:
        print(f"error :: get_user_fcm_token({user_id}) -> don't get user fcm token")

# user의 field data 중 fcm token 값 추출
async def get_user_fcm_token(user_id):
    try:
        user_document_ref = db.collection("users").document(user_id) # user document 참조
        user_document = await user_document_ref.get() # user document 추출
        if user_document.exists: # user document 존재 O
            user_field_data = user_document.to_dict() # user document 필드 데이터 딕셔너리 형태로 변환
            user_fcm_token = user_field_data["fcmToken"] # user document 필드 데이터중 fcmToken 추출
            return user_fcm_token
        else: # user document 존재 X
            return None
        
    except exceptions.FirestoreError as e:
        print(f"Firestore 오류: {e}")
        return None