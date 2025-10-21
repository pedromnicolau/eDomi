import { createApp } from 'vue'
import App from '@/App.vue'
import { router } from '@/router'
import '@/styles/application.scss'
import 'bootstrap/dist/css/bootstrap.min.css'
import 'bootstrap' // JS do Bootstrap (Popper vem por dependência)


createApp(App).use(router).mount('#app')
