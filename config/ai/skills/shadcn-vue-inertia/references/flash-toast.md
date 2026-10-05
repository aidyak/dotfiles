# Flash Toast with Sonner (Vue 3)

Full-stack flash toast: Rails flash_keys config + useFlash composable + Sonner.

Use `notice` for success and `alert` for error — these are the standard Rails flash keys
and match the default `FlashData` type.

## Rails Setup

Configure which flash keys are exposed to the client:

```ruby
# config/initializers/inertia_rails.rb
InertiaRails.configure do |config|
  config.flash_keys = %i[notice alert]
end
```

## useFlash Composable

**Important:** `toast` is imported from `'vue-sonner'` (the package), NOT from your component file.

```ts
// app/frontend/composables/use-flash.ts
import { router, usePage } from '@inertiajs/vue3'
import { onMounted, onUnmounted, watch } from 'vue'
import { toast } from 'vue-sonner'

function showFlash(flash: FlashData) {
  if (flash.alert) toast.error(flash.alert)
  if (flash.notice) toast(flash.notice)
}

export function useFlash() {
  const page = usePage()
  let initialShown = false

  // Show flash from initial page load
  watch(() => page.flash, (flash) => {
    if (!initialShown) {
      initialShown = true
      showFlash(flash)
    }
  }, { immediate: true })

  // Listen for flash events (client-side flash, redirects)
  let removeListener: (() => void) | undefined

  onMounted(() => {
    removeListener = router.on('flash', (event) => {
      showFlash(event.detail.flash)
    })
  })

  onUnmounted(() => {
    removeListener?.()
  })
}
```

## Layout Integration

Use in persistent layout (runs once, covers all pages):

```vue
<!-- app/frontend/layouts/AppLayout.vue -->
<script setup lang="ts">
import { Toaster } from '@/components/ui/sonner'
import { useFlash } from '@/composables/use-flash'

useFlash()
</script>

<template>
  <slot />
  <Toaster />
</template>
```
