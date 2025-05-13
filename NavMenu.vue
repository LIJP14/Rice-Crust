<template>
  <el-menu
      :collapse="isCollapse"
      :default-active="menuId"
      unique-opened
      @open="handleOpen"
      @close="handleClose"
      class="aside-menu"
  >
    <SubmenuView v-for="item in menu" :menu-children="item" :key="item.menuId" />
  </el-menu>
</template>

<script>

export default {
    name: "NavMenu",
    data () {
        return {
            isCollapse: false,
            oldSystemUrl:"",
            loading: false,
            slideBg: null,
            isShow: false,
            menuId: '',
            timeout: null,
            timeout2: null,
        }
    },
    computed: {
        menu () {
          return this.$store.state.menu || [];
        },
    },
    watch: {
        menu (n) {
            if (this.$route) {
                this.setMenuId();
            }
        },
        $route () {
            this.setMenuId();
        },
    },
    created () {
      // qiankun + vue3 的兼容：跳转用 window.history.pushState，设置{ back: '/', current: '/' }，浏览器的历史记录不会乱
      window.history.pushState({ back: '/', current: '/' }, '', '/layout/home');


    },
    methods: {

        /**
         * 递归查询菜单，根据 $route.path 匹配菜单项，返回菜单项的 index path
         * @param menuArr
         * @param $route
         * @param matched
         * @returns {*[]|*}
         */
        recursionMenu (menuArr, $route, matched = []) {
            for (let i = 0; i < menuArr.length; i++) {
                const item = menuArr[i];
                if (item.url === $route.path || item.url === $route.fullPath || (item.url + '/') === $route.path) {
                    matched.push(item);
                    return matched;
                }
                if (item.children && item.children.length) {
                    matched.push(item);
                    const matchedArr = this.recursionMenu(item.children, $route, matched);
                    if (matchedArr) {
                        return matchedArr;
                    }
                }
            }
            matched.length = matched.length ? matched.length - 1 : 0;
        },


        setMenuId () {
            if (this.timeout) {
                clearTimeout(this.timeout);
            }
            this.timeout = setTimeout(() => {
                const arr = this.recursionMenu(this.menu, this.$route) || [];

                if (arr && arr.length) {
                    const menuId = arr[arr.length - 1].menuId;
                    sessionStorage.menuId = menuId;
                    this.menuId = menuId;
                } else {
                    const state = window.history.state || {};

                    if (state._headerMenuId === undefined) {
                        state._headerMenuId = sessionStorage.headerMenuId || '';
                        state._menuId = sessionStorage.menuId || '';
                        window.history.replaceState({...state}, '', '');
                        // console.log('写入window.history', JSON.parse(JSON.stringify(window.history.state)));
                    } else {
                        // console.log('读取window.history', JSON.parse(JSON.stringify(state)));
                        this.menuId = state._menuId;
                        sessionStorage.menuId = state._menuId;
                    }

                }

            }, 100);

        },
    }
}
</script>
