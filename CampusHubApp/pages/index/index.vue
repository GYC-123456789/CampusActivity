<template>
  <view class="container">
    <view class="app-top">
      <view class="hero-row">
        <view class="hero-copy">
          <text class="eyebrow">校内活动预约与分享平台</text>
          <text class="brand">CampusHub</text>
          <text class="hero-subtitle">{{ welcomeText }}</text>
        </view>
        <view class="avatar-box" @click="toUser">
          <image v-if="avatarSrc" :src="avatarSrc" class="avatar" mode="aspectFill" />
          <view v-else class="avatar-placeholder">
            <text>{{ userInitial }}</text>
          </view>
        </view>
      </view>
      <view class="metric-row">
        <view class="metric-card">
          <text class="metric-num">{{ orders.length }}</text>
          <text class="metric-label">推荐活动</text>
        </view>
        <view class="metric-card">
          <text class="metric-num">{{ contents.length }}</text>
          <text class="metric-label">热门动态</text>
        </view>
        <view class="metric-card">
          <text class="metric-num">AI</text>
          <text class="metric-label">校园助手</text>
        </view>
      </view>
    </view>

    <view class="search-box" @click="toSearch">
      <view class="search-icon"></view>
      <text class="search-text">搜索活动、动态或用户</text>
    </view>

    <view class="menu-grid">
      <view class="menu-item" @click="toOrderList">
        <view class="menu-icon icon-calendar">
          <view class="calendar-line"></view>
          <view class="calendar-dot-row">
            <view></view><view></view><view></view>
          </view>
        </view>
        <text class="menu-text">活动广场</text>
      </view>
      <view class="menu-item" @click="toContentList">
        <view class="menu-icon icon-feed">
          <view class="feed-line wide"></view>
          <view class="feed-line"></view>
          <view class="feed-line short"></view>
        </view>
        <text class="menu-text">动态社区</text>
      </view>
      <view class="menu-item" @click="toCreateOrder">
        <view class="menu-icon icon-plus">
          <view class="plus-h"></view>
          <view class="plus-v"></view>
        </view>
        <text class="menu-text">发布活动</text>
      </view>
      <view class="menu-item" @click="toAIChat">
        <view class="menu-icon icon-ai">
          <text>AI</text>
        </view>
        <text class="menu-text">AI助手</text>
      </view>
    </view>

    <view class="section">
      <view class="section-title">
        <view>
          <text class="section-heading">推荐活动</text>
          <text class="section-desc">看看同学们正在约什么</text>
        </view>
        <text class="more" @click="toOrderList">更多</text>
      </view>
      <view v-if="orders.length > 0" class="order-list">
        <view v-for="order in orders" :key="order.id" class="order-item" @click="toOrderDetail(order.id)">
          <view class="order-left">
            <text class="order-type">{{ getActivityType(order.activityType) }}</text>
            <text class="order-location">{{ order.location || '未设置地点' }}</text>
          </view>
          <view class="order-right">
            <text class="status-pill" :class="`status-${order.status || 'UNKNOWN'}`">{{ getStatus(order.status) }}</text>
            <text class="order-time">{{ formatTime(order.startTime, 'MM-DD HH:mm') }}</text>
          </view>
          <view class="order-bottom">
            <text>{{ order.currentPeople || 0 }}/{{ order.maxPeople || 0 }} 人</text>
            <text>{{ getCampus(order.campus) }}</text>
          </view>
        </view>
      </view>
      <view v-else class="empty">暂无推荐活动</view>
    </view>

    <view class="section">
      <view class="section-title">
        <view>
          <text class="section-heading">热门动态</text>
          <text class="section-desc">校园里的即时分享</text>
        </view>
        <text class="more" @click="toContentList">更多</text>
      </view>
      <view v-if="contents.length > 0" class="content-list">
        <view
          v-for="content in contents"
          :key="content.pid || content.id"
          class="content-item"
          @click="toContentDetail(content.pid || content.id)"
        >
          <view class="content-main">
            <view class="content-header">
              <image
                v-if="content.user && content.user.avatarUrl"
                :src="content.user.avatarUrl"
                class="user-avatar"
                mode="aspectFill"
              />
              <view v-else class="small-avatar">
                <text>{{ getUserInitial(content.user) }}</text>
              </view>
              <view class="user-info">
                <text class="user-name">{{ content.user ? content.user.nickname : '匿名用户' }}</text>
                <text class="content-time">{{ formatRelativeTime(content.createdAt) }}</text>
              </view>
            </view>
            <text class="content-text">{{ content.content }}</text>
            <view class="content-footer">
              <text class="count-item">赞 {{ content.likeCount || 0 }}</text>
              <text class="count-item">评 {{ content.commentCount || 0 }}</text>
            </view>
          </view>
          <image
            v-if="content.media && content.media.length"
            :src="content.media[0].url"
            class="content-thumb"
            mode="aspectFill"
          />
        </view>
      </view>
      <view v-else class="empty">暂无热门动态</view>
    </view>
  </view>
</template>

<script>
import { orderApi, contentApi } from '@/api/index.js'
import { formatTime, formatRelativeTime, normalizeMediaList, resolveFileUrl } from '@/utils/util.js'
import { ACTIVITY_TYPE_MAP, ORDER_STATUS_MAP, CAMPUS_MAP } from '@/utils/constants.js'

export default {
  data() {
    return {
      orders: [],
      contents: []
    }
  },
  computed: {
    userInfo() {
      return this.$store.getters['user/userInfo']
    },
    avatarSrc() {
      return this.userInfo && this.userInfo.avatarUrl ? resolveFileUrl(this.userInfo.avatarUrl) : ''
    },
    userInitial() {
      return this.userInfo && this.userInfo.nickname ? this.userInfo.nickname.slice(0, 1) : '我'
    },
    welcomeText() {
      return this.userInfo
        ? `欢迎回来，${this.userInfo.nickname || '同学'}`
        : '找到你的校园搭子'
    }
  },
  onLoad() {
    this.$store.dispatch('user/initUserState')
    this.loadData()
  },
  onShow() {
    this.loadData()
  },
  onPullDownRefresh() {
    this.loadData().finally(() => {
      uni.stopPullDownRefresh()
    })
  },
  methods: {
    async loadData() {
      try {
        const [ordersRes, contentsRes] = await Promise.all([
          orderApi.getOrders({ page: 1, size: 5 }).catch(() => ({ list: [] })),
          contentApi.getContents({ page: 1, size: 5 }).catch(() => ({ list: [] }))
        ])
        this.orders = ordersRes?.list || []
        this.contents = (contentsRes?.list || []).map(item => ({
          ...item,
          user: item.user ? {
            ...item.user,
            avatarUrl: resolveFileUrl(item.user.avatarUrl)
          } : item.user,
          media: normalizeMediaList(item)
        }))
      } catch (error) {
        console.error('加载首页数据失败:', error)
        this.orders = []
        this.contents = []
      }
    },
    getActivityType(type) {
      return ACTIVITY_TYPE_MAP[type] || '其他'
    },
    getStatus(status) {
      return ORDER_STATUS_MAP[status] || '未知'
    },
    getCampus(campus) {
      return CAMPUS_MAP[campus] || '其他校区'
    },
    getUserInitial(user) {
      return user && user.nickname ? user.nickname.slice(0, 1) : '用'
    },
    formatTime,
    formatRelativeTime,
    toUser() {
      if (!this.$store.getters['user/isLogin']) {
        uni.navigateTo({ url: '/pages/auth/login' })
      } else {
        uni.switchTab({ url: '/pages/user/info' })
      }
    },
    toSearch() {
      uni.navigateTo({ url: '/pages/search/index' })
    },
    toOrderList() {
      uni.setStorageSync('orderListFilter', { mode: 'all' })
      uni.switchTab({ url: '/pages/order/list' })
    },
    toContentList() {
      uni.setStorageSync('contentListFilter', { mode: 'all', keyword: '' })
      uni.switchTab({ url: '/pages/content/list' })
    },
    toCreateOrder() {
      if (!this.$store.getters['user/isLogin']) {
        uni.navigateTo({ url: '/pages/auth/login' })
        return
      }
      uni.navigateTo({ url: '/pages/order/create' })
    },
    toAIChat() {
      uni.navigateTo({ url: '/pages/ai/chat' })
    },
    toOrderDetail(orderId) {
      uni.navigateTo({ url: `/pages/order/detail?id=${orderId}` })
    },
    toContentDetail(contentId) {
      uni.navigateTo({ url: `/pages/content/detail?id=${contentId}` })
    }
  }
}
</script>

<style>
.container {
  min-height: 100vh;
  background: #f3f5f9;
  padding-bottom: 44rpx;
}

.app-top {
  padding: 44rpx 30rpx 70rpx;
  background: #1f447a;
  color: #ffffff;
}

.hero-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.hero-copy {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 8rpx;
}

.eyebrow {
  font-size: 22rpx;
  color: rgba(255, 255, 255, 0.72);
}

.brand {
  font-size: 48rpx;
  line-height: 1.1;
  font-weight: 800;
}

.hero-subtitle {
  font-size: 25rpx;
  color: rgba(255, 255, 255, 0.86);
}

.avatar-box {
  width: 82rpx;
  height: 82rpx;
  border-radius: 50%;
  overflow: hidden;
  border: 4rpx solid rgba(255, 255, 255, 0.28);
  background: rgba(255, 255, 255, 0.16);
  flex: 0 0 82rpx;
}

.avatar,
.avatar-placeholder {
  width: 100%;
  height: 100%;
}

.avatar-placeholder {
  display: flex;
  align-items: center;
  justify-content: center;
  color: #ffffff;
  font-size: 30rpx;
  font-weight: 800;
}

.metric-row {
  margin-top: 30rpx;
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 14rpx;
}

.metric-card {
  padding: 18rpx 16rpx;
  border-radius: 12rpx;
  background: rgba(255, 255, 255, 0.12);
  border: 1rpx solid rgba(255, 255, 255, 0.18);
  display: flex;
  flex-direction: column;
  gap: 4rpx;
}

.metric-num {
  font-size: 30rpx;
  font-weight: 800;
}

.metric-label {
  font-size: 21rpx;
  color: rgba(255, 255, 255, 0.72);
}

.search-box {
  margin: -40rpx 30rpx 18rpx;
  height: 84rpx;
  padding: 0 24rpx;
  background: #ffffff;
  border-radius: 12rpx;
  display: flex;
  align-items: center;
  gap: 16rpx;
  box-shadow: 0 12rpx 28rpx rgba(23, 42, 79, 0.14);
}

.search-icon {
  width: 26rpx;
  height: 26rpx;
  border: 4rpx solid #8a94a6;
  border-radius: 50%;
  position: relative;
  flex: 0 0 26rpx;
}

.search-icon::after {
  content: '';
  position: absolute;
  width: 14rpx;
  height: 4rpx;
  background: #8a94a6;
  right: -10rpx;
  bottom: -4rpx;
  transform: rotate(45deg);
  border-radius: 999rpx;
}

.search-text {
  color: #8a94a6;
  font-size: 27rpx;
}

.menu-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 12rpx;
  padding: 26rpx 18rpx 24rpx;
  background-color: #ffffff;
  margin: 18rpx 30rpx;
  border-radius: 12rpx;
  box-shadow: 0 8rpx 22rpx rgba(22, 34, 51, 0.06);
}

.menu-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 14rpx;
  border-radius: 22rpx;
  transition: transform 0.18s ease, background-color 0.18s ease;
}

.menu-item:active {
  background: rgba(31, 68, 122, 0.05);
  transform: translateY(2rpx) scale(0.97);
}

.menu-icon {
  width: 82rpx;
  height: 82rpx;
  border-radius: 25rpx;
  background:
    linear-gradient(145deg, rgba(255, 255, 255, 0.92), rgba(223, 238, 255, 0.72));
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #1f447a;
  overflow: hidden;
  border: 1rpx solid rgba(255, 255, 255, 0.78);
  box-shadow:
    0 14rpx 30rpx rgba(31, 68, 122, 0.14),
    inset 0 1rpx 0 rgba(255, 255, 255, 0.96);
}

.menu-icon::before {
  content: "";
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.86), transparent 48%);
  opacity: 0.78;
  pointer-events: none;
}

.menu-icon::after {
  content: "";
  position: absolute;
  right: -18rpx;
  bottom: -18rpx;
  width: 50rpx;
  height: 50rpx;
  border-radius: 999rpx;
  background: rgba(77, 156, 232, 0.16);
}

.icon-calendar {
  background:
    linear-gradient(145deg, rgba(247, 252, 255, 0.96), rgba(217, 236, 255, 0.74)) !important;
}

.icon-feed {
  background:
    linear-gradient(145deg, rgba(248, 253, 255, 0.96), rgba(224, 246, 250, 0.74)) !important;
}

.icon-plus {
  background:
    linear-gradient(145deg, rgba(248, 252, 255, 0.96), rgba(226, 239, 255, 0.76)) !important;
}

.icon-ai {
  background:
    linear-gradient(145deg, rgba(249, 253, 255, 0.98), rgba(219, 238, 255, 0.78)) !important;
}

.calendar-line {
  position: absolute;
  z-index: 2;
  top: 19rpx;
  left: 18rpx;
  width: 46rpx;
  height: 36rpx;
  border: 4rpx solid #1f447a;
  border-top-width: 11rpx;
  border-radius: 13rpx;
  background: rgba(255, 255, 255, 0.68);
  box-sizing: border-box;
}

.calendar-line::before,
.calendar-line::after {
  content: "";
  position: absolute;
  top: -14rpx;
  width: 5rpx;
  height: 12rpx;
  border-radius: 999rpx;
  background: #1f447a;
}

.calendar-line::before {
  left: 8rpx;
}

.calendar-line::after {
  right: 8rpx;
}

.calendar-dot-row {
  position: absolute;
  z-index: 2;
  left: 28rpx;
  top: 42rpx;
  display: flex;
  gap: 6rpx;
}

.calendar-dot-row view {
  width: 7rpx;
  height: 7rpx;
  border-radius: 50%;
  background: rgba(31, 68, 122, 0.68);
}

.feed-line {
  position: relative;
  z-index: 3;
  width: 7rpx;
  height: 7rpx;
  background: #1f447a;
  border-radius: 50%;
  margin: 0 3rpx;
}

.icon-feed::before {
  content: "";
  position: absolute;
  z-index: 1;
  left: 18rpx;
  top: 21rpx;
  width: 48rpx;
  height: 36rpx;
  border: 4rpx solid #1f447a;
  border-radius: 16rpx;
  background: rgba(255, 255, 255, 0.58);
  box-sizing: border-box;
}

.icon-feed::after {
  content: "";
  position: absolute;
  z-index: 2;
  left: 25rpx;
  bottom: 20rpx;
  width: 13rpx;
  height: 13rpx;
  border-left: 4rpx solid #1f447a;
  border-bottom: 4rpx solid #1f447a;
  border-radius: 0 0 0 5rpx;
  transform: skew(-20deg);
}

.feed-line.wide {
  width: 7rpx;
}

.feed-line.short {
  width: 7rpx;
  opacity: 1;
}

.plus-h,
.plus-v {
  position: absolute;
  z-index: 2;
  background: #1f447a;
  border-radius: 999rpx;
  box-shadow: 0 6rpx 12rpx rgba(31, 68, 122, 0.18);
}

.icon-plus::before {
  content: "";
  position: absolute;
  z-index: 1;
  width: 50rpx;
  height: 50rpx;
  border-radius: 18rpx;
  background:
    linear-gradient(145deg, rgba(255, 255, 255, 0.72), rgba(219, 236, 255, 0.46));
  border: 3rpx solid rgba(31, 68, 122, 0.14);
}

.plus-h {
  width: 32rpx;
  height: 8rpx;
}

.plus-v {
  width: 8rpx;
  height: 32rpx;
}

.icon-ai::before {
  content: "";
  position: absolute;
  z-index: 1;
  left: 15rpx;
  top: 18rpx;
  width: 8rpx;
  height: 8rpx;
  background: #1f447a;
  border-radius: 999rpx;
  box-shadow:
    0 -8rpx 0 -2rpx #1f447a,
    0 8rpx 0 -2rpx #1f447a,
    -8rpx 0 0 -2rpx #1f447a,
    8rpx 0 0 -2rpx #1f447a;
  opacity: 0.52;
}

.icon-ai::after {
  content: "";
  position: absolute;
  z-index: 1;
  right: 14rpx;
  top: 16rpx;
  width: 11rpx;
  height: 11rpx;
  border-radius: 999rpx;
  background: rgba(31, 68, 122, 0.22);
  box-shadow: -5rpx 30rpx 0 rgba(25, 128, 178, 0.20);
}

.icon-ai text {
  position: relative;
  z-index: 2;
  font-size: 28rpx;
  font-weight: 800;
  letter-spacing: 0;
  color: #1f447a;
  text-shadow: 0 6rpx 12rpx rgba(31, 68, 122, 0.12);
}

.menu-text {
  font-size: 24rpx;
  color: #253044;
  font-weight: 700;
  white-space: nowrap;
}

.section {
  margin: 18rpx 30rpx;
  background-color: #ffffff;
  border-radius: 12rpx;
  padding: 26rpx;
  box-shadow: 0 8rpx 22rpx rgba(22, 34, 51, 0.06);
}

.section-title {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 22rpx;
}

.section-title view {
  display: flex;
  flex-direction: column;
  gap: 5rpx;
}

.section-heading {
  font-size: 32rpx;
  line-height: 1.2;
  font-weight: 800;
  color: #172033;
}

.section-desc {
  font-size: 22rpx;
  color: #8a94a6;
}

.more {
  font-size: 24rpx;
  color: #1f447a;
  font-weight: 700;
}

.order-list,
.content-list {
  display: flex;
  flex-direction: column;
  gap: 16rpx;
}

.order-item {
  position: relative;
  display: grid;
  grid-template-columns: 1fr auto;
  gap: 12rpx 18rpx;
  padding: 22rpx;
  background-color: #f8fafc;
  border-radius: 10rpx;
  border-left: 6rpx solid #1f447a;
}

.order-left,
.order-right {
  display: flex;
  flex-direction: column;
}

.order-left {
  gap: 8rpx;
}

.order-right {
  align-items: flex-end;
  gap: 12rpx;
}

.order-type {
  font-size: 30rpx;
  font-weight: 800;
  color: #172033;
}

.order-location,
.order-time,
.order-bottom {
  color: #667085;
  font-size: 24rpx;
}

.status-pill {
  padding: 7rpx 16rpx;
  border-radius: 999rpx;
  font-size: 22rpx;
  color: #1f447a;
  background: #edf4ff;
  white-space: nowrap;
}

.status-COMPLETED,
.status-IN_PROGRESS {
  color: #087443;
  background: #e8f7ef;
}

.status-CANCELLED,
.status-EXPIRED {
  color: #b42318;
  background: #fff1f0;
}

.order-bottom {
  grid-column: 1 / span 2;
  display: flex;
  justify-content: space-between;
  padding-top: 12rpx;
  border-top: 1rpx solid #edf1f6;
}

.content-item {
  display: flex;
  gap: 18rpx;
  padding: 22rpx;
  background-color: #f8fafc;
  border-radius: 10rpx;
}

.content-main {
  flex: 1;
  min-width: 0;
}

.content-header {
  display: flex;
  align-items: center;
  margin-bottom: 14rpx;
}

.user-avatar,
.small-avatar {
  width: 54rpx;
  height: 54rpx;
  border-radius: 50%;
  margin-right: 14rpx;
  flex-shrink: 0;
}

.small-avatar {
  background: #edf4ff;
  color: #1f447a;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24rpx;
  font-weight: 800;
}

.user-info {
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.user-name {
  font-size: 26rpx;
  font-weight: 800;
  color: #172033;
}

.content-time {
  font-size: 22rpx;
  color: #8a94a6;
  margin-top: 4rpx;
}

.content-text {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  font-size: 27rpx;
  color: #344054;
  line-height: 1.6;
}

.content-thumb {
  width: 128rpx;
  height: 128rpx;
  border-radius: 10rpx;
  background: #eef1f5;
  flex-shrink: 0;
}

.content-footer {
  display: flex;
  gap: 24rpx;
  margin-top: 14rpx;
}

.count-item {
  font-size: 23rpx;
  color: #8a94a6;
}

.empty {
  text-align: center;
  padding: 44rpx 0;
  color: #8a94a6;
  font-size: 27rpx;
}
</style>
