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
  background-color: #f5f5f5;
  height: 100%;
}
</style>
