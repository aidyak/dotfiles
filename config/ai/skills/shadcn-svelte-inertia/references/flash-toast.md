# Flash Toast with svelte-sonner

Full-stack flash toast: Rails flash_keys config + flash watcher + svelte-sonner.

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

## Flash Watcher

**Important:** `toast` is imported from `'svelte-sonner'` (the package), NOT from your component file.

```ts
// app/frontend/lib/use-flash.ts
import { page } from '@inertiajs/svelte'
import { router } from '@inertiajs/svelte'
import { toast } from 'svelte-sonner'
import { get } from 'svelte/store'
import { onMount, onDestroy } from 'svelte'

function showFlash(flash: FlashData) {
  if (flash.alert) toast.error(flash.alert)
  if (flash.notice) toast(flash.notice)
}

export function useFlash() {
  let initialShown = false

  // Show flash from initial page load
  const unsubscribe = page.subscribe(($page) => {
    if (!initialShown) {
      initialShown = true
      showFlash($page.flash)
    }
  })

  // Listen for flash events (client-side flash, redirects)
  let removeListener: (() => void) | undefined

  onMount(() => {
    removeListener = router.on('flash', (event) => {
      showFlash(event.detail.flash)
    })
  })

  onDestroy(() => {
    unsubscribe()
    removeListener?.()
  })
}
```

## Layout Integration

Use in persistent layout (runs once, covers all pages):

```svelte
<!-- app/frontend/layouts/AppLayout.svelte -->
<script lang="ts">
  import { Toaster } from '$lib/components/ui/sonner'
  import { useFlash } from '$lib/use-flash'

  let { children } = $props()

  useFlash()
</script>

{@render children()}
<Toaster />
```

Svelte 4:

```svelte
<script>
  import { Toaster } from '$lib/components/ui/sonner'
  import { useFlash } from '$lib/use-flash'

  useFlash()
</script>

<slot />
<Toaster />
```
