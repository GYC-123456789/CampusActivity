<script>
import config from './utils/config.js'
import store from './store/index.js'

export default {
  onLaunch() {
    console.log('App launch', config.baseURL)
    store.dispatch('user/initUserState').catch((error) => {
      console.error('Init user state failed:', error)
    })
  },
  onShow() {
    console.log('App show')
  },
  onHide() {
    console.log('App hide')
  }
}
</script>

<style>
page {
  background:
    radial-gradient(circle at 18% 0%, rgba(78, 161, 255, 0.16), transparent 34%),
    linear-gradient(180deg, #f7fbff 0%, #eef4fb 46%, #f8fbff 100%);
  height: 100%;
  color: #172033;
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}

uni-page-body {
  min-height: 100%;
}

.container,
.page,
.user-info-container,
.chat-container,
.content-page,
.detail-page,
.create-page {
  background:
    radial-gradient(circle at 16% 2%, rgba(78, 161, 255, 0.18), transparent 32%),
    radial-gradient(circle at 88% 8%, rgba(24, 196, 214, 0.10), transparent 30%),
    linear-gradient(180deg, #f7fbff 0%, #eef4fb 48%, #f8fbff 100%) !important;
}

.uni-app--showtabbar .container,
.uni-app--showtabbar .user-info-container {
  padding-bottom: 156rpx !important;
  box-sizing: border-box;
}

.uni-app--showtabbar .list-box,
.uni-app--showtabbar .empty-box,
.uni-app--showtabbar .loading-box {
  padding-bottom: 146rpx;
  box-sizing: border-box;
}

.app-top {
  position: relative;
  overflow: hidden;
  background:
    linear-gradient(135deg, rgba(23, 55, 105, 0.98) 0%, rgba(31, 68, 122, 0.98) 48%, rgba(35, 108, 151, 0.96) 100%) !important;
  box-shadow: inset 0 -1rpx 0 rgba(255, 255, 255, 0.18);
}

.app-top::before {
  content: "";
  position: absolute;
  left: -18%;
  top: -42%;
  width: 72%;
  height: 120%;
  background: linear-gradient(118deg, rgba(255, 255, 255, 0.26), rgba(255, 255, 255, 0.04) 58%, transparent);
  transform: rotate(-11deg);
  pointer-events: none;
  animation: header-sheen 8s ease-in-out infinite alternate;
}

.app-top::after {
  content: "";
  position: absolute;
  right: 26rpx;
  bottom: -72rpx;
  width: 220rpx;
  height: 220rpx;
  border-radius: 999rpx;
  background: radial-gradient(circle, rgba(125, 222, 255, 0.22), transparent 70%);
  pointer-events: none;
}

.app-top > * {
  position: relative;
  z-index: 1;
}

.profile-card,
.login-card,
.shortcut-card,
.menu-list,
.menu-grid,
.metric-card,
.search-box,
.section,
.filter-card,
.mode-card,
.item-box,
.order-item,
.content-item,
.form-card,
.detail-card,
.content-card,
.comment-card,
.reply-card,
.apply-card,
.message-bubble,
.assistant-bubble,
.empty-state,
.empty-box,
.memory-panel {
  border: 1rpx solid rgba(255, 255, 255, 0.72) !important;
  background:
    linear-gradient(145deg, rgba(255, 255, 255, 0.92), rgba(246, 251, 255, 0.72)) !important;
  box-shadow:
    0 20rpx 42rpx rgba(22, 47, 84, 0.11),
    inset 0 1rpx 0 rgba(255, 255, 255, 0.82) !important;
  -webkit-backdrop-filter: blur(22rpx) saturate(1.28);
  backdrop-filter: blur(22rpx) saturate(1.28);
}

.app-top .metric-card {
  background:
    linear-gradient(145deg, rgba(255, 255, 255, 0.24), rgba(255, 255, 255, 0.10)) !important;
  border-color: rgba(255, 255, 255, 0.32) !important;
  box-shadow:
    0 14rpx 30rpx rgba(8, 29, 61, 0.12),
    inset 0 1rpx 0 rgba(255, 255, 255, 0.46) !important;
}

.app-top .metric-num,
.app-top .metric-label {
  color: #ffffff !important;
  text-shadow: 0 1rpx 8rpx rgba(11, 29, 54, 0.18);
}

.app-top .metric-label {
  opacity: 0.84;
}

.search-box,
.filter-card,
.profile-card,
.login-card,
.section,
.item-box,
.menu-grid,
.menu-list,
.content-card,
.detail-card,
.form-card,
.empty-state,
.empty-box {
  border-radius: 28rpx !important;
}

.shortcut-card,
.metric-card,
.order-item,
.content-item,
.comment-card,
.reply-card,
.apply-card,
.assistant-bubble,
.message-bubble {
  border-radius: 24rpx !important;
}

.top-action,
.send-btn,
.submit-btn,
.login-btn,
.logout-btn,
.bottom-btn,
.tool-btn,
.memory-close,
.mode-clear,
.status-pill,
.action-btn,
.publish-btn {
  transition: transform 0.18s ease, box-shadow 0.18s ease, opacity 0.18s ease;
}

.top-action:active,
.send-btn:active,
.submit-btn:active,
.login-btn:active,
.logout-btn:active,
.bottom-btn:active,
.tool-btn:active,
.memory-close:active,
.mode-clear:active,
.action-btn:active,
.publish-btn:active,
.menu-item:active,
.item-box:active,
.order-item:active,
.content-item:active,
.shortcut-card:active,
.search-box:active {
  transform: scale(0.975);
  opacity: 0.88;
}

.profile-card,
.login-card,
.search-box,
.menu-grid,
.filter-card,
.mode-card,
.section,
.shortcut-card,
.item-box,
.order-item,
.content-item,
.assistant-row,
.user-bubble {
  animation: glass-rise 0.48s cubic-bezier(0.2, 0.78, 0.25, 1) both;
}

.section:nth-of-type(2),
.item-box:nth-child(2),
.shortcut-card:nth-child(2),
.content-item:nth-child(2),
.order-item:nth-child(2) {
  animation-delay: 0.05s;
}

.section:nth-of-type(3),
.item-box:nth-child(3),
.content-item:nth-child(3),
.order-item:nth-child(3) {
  animation-delay: 0.1s;
}

.avatar-box,
.avatar-wrap,
.type-mark,
.assistant-avatar,
.empty-logo,
.menu-icon,
.camera-badge {
  box-shadow:
    inset 0 1rpx 0 rgba(255, 255, 255, 0.75),
    0 12rpx 28rpx rgba(23, 42, 79, 0.14);
}

.avatar-box,
.avatar-wrap {
  animation: soft-float 4.8s ease-in-out infinite;
}

.profile-card .avatar,
.profile-card .avatar-placeholder,
.login-card .login-illustration {
  border-color: rgba(236, 246, 255, 0.92) !important;
  box-shadow:
    0 0 0 10rpx rgba(255, 255, 255, 0.58),
    0 16rpx 34rpx rgba(23, 42, 79, 0.16);
}

.menu-list .menu-icon,
.menu-grid .menu-icon {
  background-color: rgba(232, 243, 255, 0.78) !important;
  box-shadow:
    0 0 0 8rpx rgba(31, 68, 122, 0.055),
    inset 0 1rpx 0 rgba(255, 255, 255, 0.88);
}

.top-action,
.send-btn,
.submit-btn,
.login-btn,
.bottom-btn.primary,
.tool-btn.subtle {
  background:
    linear-gradient(135deg, rgba(40, 90, 158, 0.96), rgba(31, 68, 122, 0.96)) !important;
  box-shadow: 0 14rpx 30rpx rgba(31, 68, 122, 0.22);
}

.input-bar,
.bottom-actions {
  border-top: 1rpx solid rgba(255, 255, 255, 0.74) !important;
  background: rgba(248, 251, 255, 0.86) !important;
  -webkit-backdrop-filter: blur(24rpx) saturate(1.25);
  backdrop-filter: blur(24rpx) saturate(1.25);
}

uni-tabbar .uni-tabbar {
  left: 18rpx !important;
  right: 18rpx !important;
  bottom: 16rpx !important;
  width: auto !important;
  height: 92rpx !important;
  padding: 8rpx 12rpx calc(8rpx + env(safe-area-inset-bottom)) !important;
  border: 1rpx solid rgba(255, 255, 255, 0.82) !important;
  border-radius: 30rpx !important;
  background: rgba(255, 255, 255, 0.94) !important;
  box-shadow: 0 18rpx 40rpx rgba(22, 47, 84, 0.14) !important;
  -webkit-backdrop-filter: blur(28rpx) saturate(1.18);
  backdrop-filter: blur(28rpx) saturate(1.18);
  overflow: hidden;
}

uni-tabbar .uni-tabbar__item {
  border-radius: 22rpx !important;
  transition: transform 0.18s ease, background-color 0.18s ease;
}

uni-tabbar .uni-tabbar__item:active {
  transform: scale(0.96);
  background: rgba(31, 68, 122, 0.08);
}

@keyframes glass-rise {
  from {
    opacity: 0;
    transform: translateY(18rpx) scale(0.985);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

@keyframes header-sheen {
  from {
    opacity: 0.52;
    transform: translateX(-18rpx) rotate(-11deg);
  }
  to {
    opacity: 0.88;
    transform: translateX(34rpx) rotate(-11deg);
  }
}

@keyframes soft-float {
  0%,
  100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-5rpx);
  }
}

@media (prefers-reduced-motion: reduce) {
  .profile-card,
  .login-card,
  .search-box,
  .menu-grid,
  .filter-card,
  .mode-card,
  .section,
  .shortcut-card,
  .item-box,
  .order-item,
  .content-item,
  .assistant-row,
  .user-bubble {
    animation: none !important;
  }

  .top-action,
  .send-btn,
  .submit-btn,
  .login-btn,
  .logout-btn,
  .bottom-btn,
  .tool-btn,
  .memory-close,
  .mode-clear,
  .status-pill,
  .action-btn,
  .publish-btn {
    transition: none !important;
  }

  .app-top::before,
  .avatar-box,
  .avatar-wrap {
    animation: none !important;
  }
}
</style>
