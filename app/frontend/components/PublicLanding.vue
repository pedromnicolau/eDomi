<template>
  <main>
    <section id="about" ref="aboutRef">
      <About />
    </section>

    <section id="properties" ref="propertiesRef">
      <PropertiesList />
    </section>

    <section id="contact" ref="contactRef">
      <Contact />
    </section>
  </main>
</template>

<script setup>
import { nextTick, onMounted, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import About from '@/components/About.vue'
import PropertiesList from '@/components/PropertiesList.vue'
import Contact from '@/components/Contact.vue'

const route = useRoute()

const aboutRef = ref(null)
const propertiesRef = ref(null)
const contactRef = ref(null)

const scrollToCurrentSection = async () => {
  await nextTick()

  if (route.hash === '#properties' || route.path === '/properties') {
    propertiesRef.value?.scrollIntoView({ behavior: 'smooth', block: 'start' })
    return
  }

  if (route.hash === '#contact' || route.path === '/contact') {
    contactRef.value?.scrollIntoView({ behavior: 'smooth', block: 'start' })
    return
  }

  aboutRef.value?.scrollIntoView({ behavior: 'smooth', block: 'start' })
}

onMounted(scrollToCurrentSection)

watch(
  () => [route.path, route.hash],
  () => {
    scrollToCurrentSection()
  }
)
</script>