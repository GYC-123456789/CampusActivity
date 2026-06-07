<template>
  <view class="user-info-container">
    <view v-if="!isLogin" class="not-login">
      <view class="app-top compact">
        <text class="page-title">个人中心</text>
      </view>
      <view class="login-card">
        <view class="login-illustration">
          <view class="user-outline"></view>
        </view>
        <text class="not-login-title">请先登录</text>
        <text class="not-login-text">登录后可以查看个人资料、活动和动态。</text>
        <button class="login-btn" @click="toLogin">立即登录</button>
      </view>
    </view>

    <view v-else class="user-content">
      <view class="app-top">
        <view class="title-row">
          <view>
            <text class="page-title">个人中心</text>
            <text class="page-subtitle">管理资料、活动和动态</text>
          </view>
        </view>
      </view>

      <view class="profile-card">
        <view class="avatar-wrap">
          <image
            v-if="avatarUrl"
            :src="avatarUrl"
            class="avatar"
            mode="aspectFill"
            @click="changeAvatar"
          />
          <view v-else class="avatar-placeholder" @click="changeAvatar">
            <text class="avatar-text">{{ userInitial }}</text>
          </view>
          <view class="camera-badge" @click="changeAvatar">
            <view class="camera-icon"></view>
          </view>
        </view>
        <view class="profile-main">
          <text class="nickname">{{ userInfo ? userInfo.nickname : '未设置昵称' }}</text>
          <text v-if="userInfo && userInfo.email" class="email">{{ userInfo.email }}</text>
          <text v-if="userInfo && userInfo.signature" class="signature">{{ userInfo.signature }}</text>
          <text v-else class="signature placeholder">点击编辑资料完善个性签名</text>
        </view>
      </view>

      <view class="shortcut-row">
        <view class="shortcut-card" @click="toMyOrders">
          <text class="shortcut-title">我的活动</text>
          <text class="shortcut-desc">查看发布记录</text>
        </view>
        <view class="shortcut-card" @click="toMyContents">
          <text class="shortcut-title">我的动态</text>
          <text class="shortcut-desc">管理分享内容</text>
        </view>
      </view>

      <view class="menu-list">
        <view class="menu-item" @click="toEdit">
          <view class="menu-icon edit-icon"></view>
          <text class="menu-text">编辑资料</text>
          <view class="menu-arrow"></view>
        </view>
        <view class="menu-item" @click="toChangePassword">
          <view class="menu-icon lock-icon"></view>
          <text class="menu-text">修改密码</text>
          <view class="menu-arrow"></view>
        </view>
        <view class="menu-item" @click="toMyOrders">
          <view class="menu-icon list-icon"></view>
          <text class="menu-text">我发布的活动</text>
          <view class="menu-arrow"></view>
        </view>
        <view class="menu-item" @click="toMyContents">
          <view class="menu-icon note-icon"></view>
          <text class="menu-text">我发布的动态</text>
          <view class="menu-arrow"></view>
        </view>
      </view>

      <button class="logout-btn" @click="handleLogout">退出登录</button>
    </view>
  </view>
</template>

<script setup>
import { computed } from 'vue'
import { onShow } from '@dcloudio/uni-app'
import { useStore } from 'vuex'
import { showLoading, hideLoading, showSuccess, showError, resolveFileUrl } from '@/utils/util.js'

const store = useStore()

const userInfo = computed(() => {
  return store.getters['user/userInfo'] || null
})

const isLogin = computed(() => {
  return store.getters['user/isLogin'] || false
})

const avatarUrl = computed(() => {
  return userInfo.value && userInfo.value.avatarUrl ? resolveFileUrl(userInfo.value.avatarUrl) : ''
})

const userInitial = computed(() => {
  const name = userInfo.value && userInfo.value.nickname ? userInfo.value.nickname : '用户'
  return String(name).slice(0, 1)
})

onShow(() => {
  if (isLogin.value) {
    store.dispatch('user/refreshUserInfo').catch(() => {})
  }
})

const changeAvatar = () => {
  if (!isLogin.value) return

  uni.chooseImage({
    count: 1,
    success: async (res) => {
      const tempFilePath = res.tempFilePaths[0]
      try {
        showLoading('上传中...')
        await store.dispatch('user/uploadAvatar', tempFilePath)
        hideLoading()
        showSuccess('上传成功')
      } catch (error) {
        hideLoading()
        showError(error.message || '上传失败')
      }
    }
  })
}

const toEdit = () => {
  uni.navigateTo({ url: '/pages/user/edit' })
}

const toChangePassword = () => {
  uni.navigateTo({ url: '/pages/user/change-password' })
}

const toMyOrders = () => {
  uni.setStorageSync('orderListFilter', { mode: 'mine' })
  uni.switchTab({ url: '/pages/order/list' })
}

const toMyContents = () => {
  uni.setStorageSync('contentListFilter', { mode: 'mine' })
  uni.switchTab({ url: '/pages/content/list' })
}

const toLogin = () => {
  uni.navigateTo({ url: '/pages/auth/login' })
}

const handleLogout = () => {
  uni.showModal({
    title: '退出登录',
    content: '确定要退出当前账号吗？',
    success: (res) => {
      if (res.confirm) {
        store.dispatch('user/logout')
      }
    }
  })
}
</script>

<style scoped>
.user-info-container {
  min-height: 100vh;
  background: #f3f5f9;
}

.app-top {
  padding: 44rpx 30rpx 70rpx;
  background: #1f447a;
  color: #ffffff;
}

.app-top.compact {
  padding-bottom: 108rpx;
}

.title-row {
  margin-top: 0;
}

.title-row view {
  display: flex;
  flex-direction: column;
  gap: 8rpx;
}

.page-title {
  display: block;
  margin-top: 0;
  font-size: 42rpx;
  font-weight: 800;
  line-height: 1.15;
}

.title-row .page-title {
  margin-top: 0;
}

.page-subtitle {
  font-size: 24rpx;
  color: rgba(255, 255, 255, 0.78);
}

.not-login {
  min-height: 100vh;
}

.login-card {
  margin: -76rpx 30rpx 0;
  padding: 70rpx 42rpx;
  border-radius: 12rpx;
  background: #ffffff;
  box-shadow: 0 12rpx 28rpx rgba(23, 42, 79, 0.14);
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 22rpx;
  text-align: center;
}

.login-illustration {
  width: 142rpx;
  height: 142rpx;
  border-radius: 50%;
  background: #edf4ff;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 8rpx;
}

.user-outline {
  position: relative;
  width: 78rpx;
  height: 78rpx;
}

.user-outline::before {
  content: "";
  position: absolute;
  left: 22rpx;
  top: 4rpx;
  width: 34rpx;
  height: 34rpx;
  border: 4rpx solid #1f447a;
  border-radius: 50%;
  box-sizing: border-box;
}

.user-outline::after {
  content: "";
  position: absolute;
  left: 8rpx;
  bottom: 4rpx;
  width: 62rpx;
  height: 34rpx;
  border: 4rpx solid #1f447a;
  border-radius: 36rpx 36rpx 12rpx 12rpx;
  box-sizing: border-box;
}

.not-login-title {
  color: #172033;
  font-size: 36rpx;
  font-weight: 800;
}

.not-login-text {
  color: #667085;
  font-size: 26rpx;
  line-height: 1.5;
}

.login-btn {
  width: 300rpx;
  height: 84rpx;
  line-height: 84rpx;
  margin-top: 18rpx;
  border: none;
  border-radius: 999rpx;
  background: #1f447a;
  color: #ffffff;
  font-size: 29rpx;
  font-weight: 700;
  padding: 0;
}

.user-content {
  min-height: 100vh;
}

.profile-card {
  position: relative;
  margin: -44rpx 30rpx 18rpx;
  padding: 26rpx;
  border-radius: 12rpx;
  background: #ffffff;
  box-shadow: 0 12rpx 28rpx rgba(23, 42, 79, 0.14);
  display: flex;
  gap: 22rpx;
  align-items: center;
}

.avatar-wrap {
  position: relative;
  width: 142rpx;
  height: 142rpx;
  flex: 0 0 142rpx;
}

.avatar,
.avatar-placeholder {
  width: 142rpx;
  height: 142rpx;
  border-radius: 50%;
  border: 6rpx solid #edf4ff;
  box-sizing: border-box;
}

.avatar-placeholder {
  display: flex;
  align-items: center;
  justify-content: center;
  background: #1f447a;
}

.avatar-text {
  color: #ffffff;
  font-size: 54rpx;
  font-weight: 800;
}

.camera-badge {
  position: absolute;
  right: 0;
  bottom: 4rpx;
  width: 48rpx;
  height: 48rpx;
  border-radius: 50%;
  background: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 6rpx 16rpx rgba(15, 23, 42, 0.18);
}

.camera-icon {
  position: relative;
  width: 26rpx;
  height: 20rpx;
  border: 3rpx solid #1f447a;
  border-radius: 5rpx;
  box-sizing: border-box;
}

.camera-icon::before {
  content: "";
  position: absolute;
  left: 6rpx;
  top: -7rpx;
  width: 11rpx;
  height: 5rpx;
  border-radius: 4rpx 4rpx 0 0;
  background: #1f447a;
}

.camera-icon::after {
  content: "";
  position: absolute;
  left: 7rpx;
  top: 4rpx;
  width: 8rpx;
  height: 8rpx;
  border-radius: 50%;
  background: #1f447a;
}

.profile-main {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 8rpx;
}

.nickname {
  color: #172033;
  font-size: 36rpx;
  font-weight: 800;
}

.email {
  color: #667085;
  font-size: 24rpx;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.signature {
  color: #475467;
  font-size: 25rpx;
  line-height: 1.45;
}

.signature.placeholder {
  color: #8a94a6;
}

.shortcut-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 16rpx;
  margin: 0 30rpx 18rpx;
}

.shortcut-card {
  padding: 24rpx;
  border-radius: 12rpx;
  background: #ffffff;
  box-shadow: 0 8rpx 22rpx rgba(22, 34, 51, 0.06);
  display: flex;
  flex-direction: column;
  gap: 8rpx;
  border-left: 6rpx solid #1f447a;
}

.shortcut-title {
  color: #172033;
  font-size: 28rpx;
  font-weight: 800;
}

.shortcut-desc {
  color: #8a94a6;
  font-size: 22rpx;
}

.menu-list {
  margin: 0 30rpx;
  background: #ffffff;
  border-radius: 12rpx;
  overflow: hidden;
  box-shadow: 0 8rpx 22rpx rgba(22, 34, 51, 0.06);
}

.menu-item {
  display: flex;
  align-items: center;
  min-height: 96rpx;
  padding: 0 26rpx;
  border-bottom: 1rpx solid #edf1f6;
  box-sizing: border-box;
}

.menu-item:last-child {
  border-bottom: none;
}

.menu-icon {
  position: relative;
  width: 42rpx;
  height: 42rpx;
  margin-right: 24rpx;
  flex: 0 0 42rpx;
}

.edit-icon {
  border: 3rpx solid #1f447a;
  border-radius: 8rpx;
  box-sizing: border-box;
}

.edit-icon::before {
  content: "";
  position: absolute;
  width: 22rpx;
  height: 4rpx;
  left: 13rpx;
  top: 9rpx;
  background: #1f447a;
  border-radius: 999rpx;
  transform: rotate(-38deg);
}

.edit-icon::after {
  content: "";
  position: absolute;
  width: 11rpx;
  height: 4rpx;
  left: 7rpx;
  top: 25rpx;
  background: #1f447a;
  border-radius: 999rpx;
}

.lock-icon {
  border: 3rpx solid #1f447a;
  border-radius: 8rpx;
  box-sizing: border-box;
  margin-top: 12rpx;
  height: 30rpx;
}

.lock-icon::before {
  content: "";
  position: absolute;
  left: 9rpx;
  top: -17rpx;
  width: 20rpx;
  height: 20rpx;
  border: 3rpx solid #1f447a;
  border-bottom: none;
  border-radius: 18rpx 18rpx 0 0;
  box-sizing: border-box;
}

.lock-icon::after {
  content: "";
  position: absolute;
  left: 17rpx;
  top: 10rpx;
  width: 5rpx;
  height: 12rpx;
  border-radius: 999rpx;
  background: #1f447a;
}

.list-icon,
.note-icon {
  border: 3rpx solid #1f447a;
  border-radius: 8rpx;
  box-sizing: border-box;
}

.list-icon::before,
.list-icon::after,
.note-icon::before {
  content: "";
  position: absolute;
  left: 9rpx;
  width: 21rpx;
  height: 3rpx;
  border-radius: 999rpx;
  background: #1f447a;
}

.list-icon::before {
  top: 9rpx;
  box-shadow: 0 10rpx 0 #1f447a;
}

.list-icon::after {
  top: 29rpx;
}

.note-icon::before {
  top: 10rpx;
  box-shadow: 0 10rpx 0 #1f447a;
}

.note-icon::after {
  content: "";
  position: absolute;
  right: -3rpx;
  bottom: -3rpx;
  border-left: 14rpx solid transparent;
  border-top: 14rpx solid #1f447a;
}

.menu-text {
  flex: 1;
  color: #263244;
  font-size: 28rpx;
  font-weight: 700;
}

.menu-arrow {
  width: 18rpx;
  height: 18rpx;
  border-right: 3rpx solid #8a94a6;
  border-bottom: 3rpx solid #8a94a6;
  transform: rotate(-45deg);
}

.logout-btn {
  width: calc(100% - 60rpx);
  height: 84rpx;
  line-height: 84rpx;
  margin: 28rpx 30rpx 44rpx;
  border: none;
  border-radius: 999rpx;
  background: #fff1f0;
  color: #b42318;
  font-size: 28rpx;
  font-weight: 800;
  padding: 0;
}
</style>
