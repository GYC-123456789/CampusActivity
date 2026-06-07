<template>
  <view class="content-detail-container">
    <view v-if="contentDetail" class="detail-content">
      <view class="user-section">
        <image
          v-if="contentDetail.user && contentDetail.user.avatarUrl"
          :src="contentDetail.user.avatarUrl"
          class="user-avatar"
          mode="aspectFill"
        />
        <view v-else class="avatar-placeholder">{{ getInitial(contentDetail.user) }}</view>
        <view class="user-info">
          <text class="user-nickname">{{ contentDetail.user ? contentDetail.user.nickname : '匿名用户' }}</text>
          <text class="content-time">{{ formatRelativeTime(contentDetail.createdAt) }}</text>
        </view>
        <button v-if="canDeleteContent" class="delete-content-btn" @click="handleDeleteContent">删除</button>
      </view>

      <text class="content-text">{{ contentDetail.content }}</text>

      <view v-if="contentDetail.media && contentDetail.media.length > 0" class="media-section">
        <image
          v-for="(media, index) in contentDetail.media"
          :key="index"
          :src="media.url"
          class="media-image"
          mode="widthFix"
          @click="previewImage(media.url, contentDetail.media)"
        />
      </view>

      <view class="action-bar">
        <view class="action-item" @click="handleLike">
          <view :class="['action-icon', 'like-icon', contentDetail.liked ? 'active' : '']"></view>
          <text>{{ contentDetail.likeCount || 0 }}</text>
        </view>
        <view class="action-item" @click="showCommentInput = true">
          <view class="action-icon comment-icon"></view>
          <text>{{ contentDetail.commentCount || 0 }}</text>
        </view>
      </view>

      <view v-if="showCommentInput" class="comment-input-section">
        <textarea
          v-model="commentText"
          class="comment-input"
          placeholder="写评论..."
          maxlength="500"
        />
        <view class="comment-actions">
          <button class="cancel-btn" @click="showCommentInput = false">取消</button>
          <button class="submit-btn" @click="handleComment">发布</button>
        </view>
      </view>

      <view class="comments-section">
        <view class="section-title-row">
          <text class="section-title">评论</text>
          <text class="section-count">{{ comments.length }}</text>
        </view>
        <view v-if="comments.length > 0" class="comments-list">
          <view
            v-for="comment in comments"
            :key="comment.pid || comment.id"
            class="comment-item"
          >
            <image
              v-if="comment.user && comment.user.avatarUrl"
              :src="comment.user.avatarUrl"
              class="comment-avatar"
              mode="aspectFill"
            />
            <view v-else class="comment-avatar placeholder-avatar">{{ getInitial(comment.user) }}</view>
            <view class="comment-content">
              <view class="comment-title-row">
                <text class="comment-nickname">{{ comment.user ? comment.user.nickname : '匿名用户' }}</text>
                <text v-if="canDeleteComment(comment)" class="comment-delete" @click.stop="handleDeleteComment(comment)">删除</text>
              </view>
              <text class="comment-text">{{ comment.content }}</text>
              <text class="comment-time">{{ formatRelativeTime(comment.createdAt) }}</text>
            </view>
          </view>
        </view>
        <view v-else class="empty-state">
          <text class="empty-text">暂时还没有评论</text>
        </view>
      </view>
    </view>

    <view v-else-if="loading" class="loading-state">
      <text class="loading-text">加载中...</text>
    </view>
  </view>
</template>

<script setup>
import { computed, ref } from 'vue'
import { onLoad } from '@dcloudio/uni-app'
import { useStore } from 'vuex'
import { contentApi } from '@/api/index.js'
import { formatRelativeTime, showLoading, hideLoading, showSuccess, showError, normalizeMediaList, resolveFileUrl } from '@/utils/util.js'

const store = useStore()

const contentDetail = ref(null)
const comments = ref([])
const loading = ref(false)
const showCommentInput = ref(false)
const commentText = ref('')
const contentId = ref(null)

const currentUserId = computed(() => store.getters['user/userId'])
const isLogin = computed(() => store.getters['user/isLogin'])
const isAdmin = computed(() => store.getters['user/isAdmin'])

const getUserId = (user) => {
  return user ? (user.uid || user.id) : null
}

const getInitial = (user) => {
  const name = user && user.nickname ? user.nickname : '用户'
  return String(name).slice(0, 1)
}

const canDeleteContent = computed(() => {
  if (!contentDetail.value || !isLogin.value) return false
  const ownerId = getUserId(contentDetail.value.user)
  return isAdmin.value || String(ownerId || '') === String(currentUserId.value || '')
})

function canDeleteComment(comment) {
  if (!comment || !isLogin.value) return false
  const ownerId = getUserId(comment.user)
  return isAdmin.value || String(ownerId || '') === String(currentUserId.value || '')
}

const normalizeUser = (user) => {
  if (!user) return user
  return {
    ...user,
    avatarUrl: resolveFileUrl(user.avatarUrl)
  }
}

const loadContentDetail = async () => {
  if (!contentId.value) {
    showError('缺少动态 ID')
    return
  }

  loading.value = true
  showLoading('加载中...')

  try {
    const detail = await contentApi.getContentDetail(contentId.value)
    contentDetail.value = {
      ...detail,
      user: normalizeUser(detail.user),
      media: normalizeMediaList(detail)
    }

    const result = await contentApi.getComments(contentId.value, 1, 50)
    comments.value = (result.list || []).map(comment => ({
      ...comment,
      user: normalizeUser(comment.user)
    }))
  } catch (error) {
    showError(error.message || '加载失败')
  } finally {
    loading.value = false
    hideLoading()
  }
}

const handleLike = async () => {
  if (!isLogin.value) {
    uni.navigateTo({ url: '/pages/auth/login' })
    return
  }

  try {
    const result = await contentApi.likeContent(contentId.value)
    contentDetail.value.liked = result.liked
    contentDetail.value.likeCount = result.count || result.likeCount || contentDetail.value.likeCount
  } catch (error) {
    showError(error.message || '操作失败')
  }
}

const handleComment = async () => {
  if (!commentText.value.trim()) {
    showError('请输入评论内容')
    return
  }

  if (!isLogin.value) {
    uni.navigateTo({ url: '/pages/auth/login' })
    return
  }

  try {
    await contentApi.createComment(contentId.value, {
      content: commentText.value.trim()
    })
    showSuccess('评论成功')
    commentText.value = ''
    showCommentInput.value = false
    await loadContentDetail()
  } catch (error) {
    showError(error.message || '评论失败')
  }
}

const handleDeleteContent = () => {
  uni.showModal({
    title: '删除动态',
    content: '确定删除这条动态吗？此操作不可撤销。',
    success: async (res) => {
      if (!res.confirm) return

      try {
        showLoading('删除中...')
        await contentApi.deleteContent(contentId.value)
        hideLoading()
        showSuccess('已删除')
        setTimeout(() => {
          uni.navigateBack()
        }, 800)
      } catch (error) {
        hideLoading()
        showError(error.message || '删除失败')
      }
    }
  })
}

const handleDeleteComment = (comment) => {
  const commentId = comment.pid || comment.id
  if (!commentId) return

  uni.showModal({
    title: '删除评论',
    content: '确定删除这条评论吗？',
    success: async (res) => {
      if (!res.confirm) return

      try {
        await contentApi.deleteComment(commentId)
        comments.value = comments.value.filter(item => (item.pid || item.id) !== commentId)
        if (contentDetail.value && contentDetail.value.commentCount > 0) {
          contentDetail.value.commentCount -= 1
        }
        showSuccess('已删除')
      } catch (error) {
        showError(error.message || '删除失败')
      }
    }
  })
}

const previewImage = (current, mediaList) => {
  const urls = mediaList.map(item => item.url)
  uni.previewImage({ current, urls })
}

onLoad((options = {}) => {
  if (options.id) {
    contentId.value = options.id
    loadContentDetail()
  } else {
    showError('缺少动态 ID')
  }
})
</script>

<style scoped>
.content-detail-container {
  min-height: 100vh;
  background: #f5f7fb;
  padding: 28rpx;
  box-sizing: border-box;
}

.detail-content {
  background: #ffffff;
  border: 1rpx solid #e8edf5;
  border-radius: 8rpx;
  padding: 30rpx;
  box-shadow: 0 10rpx 28rpx rgba(18, 38, 63, 0.06);
}

.user-section {
  display: flex;
  align-items: center;
  gap: 16rpx;
  margin-bottom: 26rpx;
}

.user-avatar,
.avatar-placeholder {
  width: 84rpx;
  height: 84rpx;
  border-radius: 50%;
  flex: 0 0 84rpx;
}

.avatar-placeholder,
.placeholder-avatar {
  display: flex;
  align-items: center;
  justify-content: center;
  background: #eef3f8;
  color: #1d4ed8;
  font-size: 28rpx;
  font-weight: 800;
}

.user-info {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 8rpx;
}

.user-nickname {
  color: #1f2937;
  font-size: 29rpx;
  font-weight: 750;
}

.content-time {
  color: #8a94a6;
  font-size: 23rpx;
}

.delete-content-btn {
  width: 96rpx;
  height: 56rpx;
  line-height: 56rpx;
  padding: 0;
  border: none;
  border-radius: 8rpx;
  background: #fef2f2;
  color: #b42318;
  font-size: 24rpx;
}

.content-text {
  display: block;
  color: #263244;
  font-size: 30rpx;
  line-height: 1.75;
  margin-bottom: 24rpx;
  white-space: pre-wrap;
  word-break: break-word;
}

.media-section {
  margin-bottom: 26rpx;
}

.media-image {
  width: 100%;
  border-radius: 8rpx;
  margin-bottom: 12rpx;
  background: #eef3f8;
}

.action-bar {
  display: flex;
  gap: 40rpx;
  padding: 24rpx 0;
  border-top: 1rpx solid #e8edf5;
  border-bottom: 1rpx solid #e8edf5;
  margin-bottom: 26rpx;
}

.action-item {
  display: flex;
  align-items: center;
  gap: 10rpx;
  color: #667085;
  font-size: 27rpx;
}

.action-icon {
  position: relative;
  width: 34rpx;
  height: 34rpx;
  flex: 0 0 34rpx;
}

.like-icon::before,
.like-icon::after {
  content: "";
  position: absolute;
  background: #98a2b3;
}

.like-icon::before {
  width: 16rpx;
  height: 22rpx;
  left: 8rpx;
  top: 7rpx;
  border-radius: 8rpx 8rpx 4rpx 4rpx;
  transform: rotate(-18deg);
}

.like-icon::after {
  width: 22rpx;
  height: 16rpx;
  left: 10rpx;
  top: 13rpx;
  border-radius: 5rpx;
}

.like-icon.active::before,
.like-icon.active::after {
  background: #f04438;
}

.comment-icon {
  border: 3rpx solid #98a2b3;
  border-radius: 10rpx;
  box-sizing: border-box;
}

.comment-icon::after {
  content: "";
  position: absolute;
  left: 7rpx;
  bottom: -7rpx;
  width: 12rpx;
  height: 12rpx;
  border-left: 3rpx solid #98a2b3;
  border-bottom: 3rpx solid #98a2b3;
  background: #ffffff;
  transform: rotate(-35deg);
}

.comment-input-section {
  margin-bottom: 28rpx;
}

.comment-input {
  width: 100%;
  min-height: 190rpx;
  padding: 20rpx;
  border: 1rpx solid #d9e0ea;
  border-radius: 8rpx;
  box-sizing: border-box;
  background: #fbfcfe;
  color: #1f2937;
  font-size: 28rpx;
  line-height: 1.6;
  margin-bottom: 18rpx;
}

.comment-actions {
  display: flex;
  justify-content: flex-end;
  gap: 18rpx;
}

.cancel-btn,
.submit-btn {
  height: 66rpx;
  line-height: 66rpx;
  padding: 0 34rpx;
  border: none;
  border-radius: 8rpx;
  font-size: 26rpx;
}

.cancel-btn {
  background: #eef3f8;
  color: #667085;
}

.submit-btn {
  background: #1d4ed8;
  color: #ffffff;
}

.comments-section {
  margin-top: 10rpx;
}

.section-title-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 22rpx;
}

.section-title {
  color: #172033;
  font-size: 31rpx;
  font-weight: 800;
}

.section-count {
  color: #8a94a6;
  font-size: 24rpx;
}

.comments-list {
  display: flex;
  flex-direction: column;
  gap: 24rpx;
}

.comment-item {
  display: flex;
  gap: 16rpx;
}

.comment-avatar {
  width: 62rpx;
  height: 62rpx;
  border-radius: 50%;
  flex: 0 0 62rpx;
  font-size: 24rpx;
}

.comment-content {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 8rpx;
}

.comment-title-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16rpx;
}

.comment-nickname {
  color: #1f2937;
  font-size: 26rpx;
  font-weight: 750;
}

.comment-delete {
  color: #b42318;
  font-size: 23rpx;
}

.comment-text {
  color: #475467;
  font-size: 27rpx;
  line-height: 1.6;
  word-break: break-word;
}

.comment-time {
  color: #98a2b3;
  font-size: 23rpx;
}

.empty-state,
.loading-state {
  text-align: center;
  padding: 110rpx 0;
}

.empty-text,
.loading-text {
  color: #98a2b3;
  font-size: 27rpx;
}
</style>
