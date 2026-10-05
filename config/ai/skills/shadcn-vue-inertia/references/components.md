# shadcn-vue Components for Inertia — Extended Reference

Additional component patterns adapted for Inertia.js + Rails + Vue 3.

## Table of Contents

- [Alert Dialog with Server Action](#alert-dialog-with-server-action)
- [Sheet (Slide-over Panel)](#sheet-slide-over-panel)
- [Tabs with URL State](#tabs-with-url-state)
- [Dropdown Menu with Actions](#dropdown-menu-with-actions)
- [Pagination](#pagination)
- [Search Input with Debounce](#search-input-with-debounce)
- [Checkbox and Switch in Forms](#checkbox-and-switch-in-forms)
- [Textarea in Forms](#textarea-in-forms)
- [Date Picker in Forms](#date-picker-in-forms)
- [Breadcrumbs with Link](#breadcrumbs-with-link)

---

## Alert Dialog with Server Action

Confirm before destructive server actions:

```vue
<script setup lang="ts">
import {
  AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent,
  AlertDialogDescription, AlertDialogFooter, AlertDialogHeader, AlertDialogTitle,
  AlertDialogTrigger
} from '@/components/ui/alert-dialog'
import { Button } from '@/components/ui/button'
import { router } from '@inertiajs/vue3'

defineProps<{ userId: number }>()
</script>

<template>
  <AlertDialog>
    <AlertDialogTrigger as-child>
      <Button variant="destructive">Delete</Button>
    </AlertDialogTrigger>
    <AlertDialogContent>
      <AlertDialogHeader>
        <AlertDialogTitle>Delete user?</AlertDialogTitle>
        <AlertDialogDescription>This action cannot be undone.</AlertDialogDescription>
      </AlertDialogHeader>
      <AlertDialogFooter>
        <AlertDialogCancel>Cancel</AlertDialogCancel>
        <AlertDialogAction @click="router.delete(`/users/${userId}`)">
          Delete
        </AlertDialogAction>
      </AlertDialogFooter>
    </AlertDialogContent>
  </AlertDialog>
</template>
```

## Sheet (Slide-over Panel)

```vue
<script setup lang="ts">
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger } from '@/components/ui/sheet'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Form } from '@inertiajs/vue3'
</script>

<template>
  <Sheet>
    <SheetTrigger as-child>
      <Button>New User</Button>
    </SheetTrigger>
    <SheetContent>
      <SheetHeader>
        <SheetTitle>Create User</SheetTitle>
      </SheetHeader>
      <Form method="post" action="/users">
        <template #default="{ errors, processing }">
          <div class="space-y-4 mt-4">
            <Input name="name" placeholder="Name" />
            <p v-if="errors.name" class="text-sm text-destructive">{{ errors.name }}</p>
            <Button type="submit" :disabled="processing">Create</Button>
          </div>
        </template>
      </Form>
    </SheetContent>
  </Sheet>
</template>
```

## Tabs with URL State

Use Inertia navigation to persist tab state in the URL:

```vue
<script setup lang="ts">
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { router } from '@inertiajs/vue3'

const props = defineProps<{
  activeTab: string
  userId: number
  profile: Profile
  activity: Activity[]
}>()
</script>

<template>
  <Tabs
    :model-value="activeTab"
    @update:model-value="(tab) => router.get(`/users/${userId}`, { tab }, { preserveState: true })"
  >
    <TabsList>
      <TabsTrigger value="profile">Profile</TabsTrigger>
      <TabsTrigger value="activity">Activity</TabsTrigger>
    </TabsList>
    <TabsContent value="profile"><ProfileView :data="profile" /></TabsContent>
    <TabsContent value="activity"><ActivityFeed :data="activity" /></TabsContent>
  </Tabs>
</template>
```

## Dropdown Menu with Actions

```vue
<script setup lang="ts">
import {
  DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger
} from '@/components/ui/dropdown-menu'
import { Button } from '@/components/ui/button'
import { router } from '@inertiajs/vue3'

defineProps<{ user: User }>()
</script>

<template>
  <DropdownMenu>
    <DropdownMenuTrigger as-child>
      <Button variant="ghost" size="icon">
        <MoreHorizontal />
      </Button>
    </DropdownMenuTrigger>
    <DropdownMenuContent>
      <DropdownMenuItem @click="router.visit(`/users/${user.id}/edit`)">
        Edit
      </DropdownMenuItem>
      <DropdownMenuItem
        class="text-destructive"
        @click="() => { if (confirm('Delete?')) router.delete(`/users/${user.id}`) }"
      >
        Delete
      </DropdownMenuItem>
    </DropdownMenuContent>
  </DropdownMenu>
</template>
```

## Pagination

Server-driven pagination with Inertia navigation:

```vue
<script setup lang="ts">
import { Button } from '@/components/ui/button'
import { router } from '@inertiajs/vue3'

const props = defineProps<{ currentPage: number; totalPages: number }>()

const goToPage = (page: number) => {
  router.get(window.location.pathname, { page }, { preserveState: true })
}
</script>

<template>
  <div class="flex gap-2">
    <Button
      variant="outline"
      :disabled="currentPage <= 1"
      @click="goToPage(currentPage - 1)"
    >
      Previous
    </Button>
    <span class="flex items-center px-2">
      Page {{ currentPage }} of {{ totalPages }}
    </span>
    <Button
      variant="outline"
      :disabled="currentPage >= totalPages"
      @click="goToPage(currentPage + 1)"
    >
      Next
    </Button>
  </div>
</template>
```

## Search Input with Debounce

```vue
<script setup lang="ts">
import { Input } from '@/components/ui/input'
import { router } from '@inertiajs/vue3'

defineProps<{ initialValue: string }>()

let timeout: ReturnType<typeof setTimeout>

const handleSearch = (value: string) => {
  clearTimeout(timeout)
  timeout = setTimeout(() => {
    router.get('/users', { search: value }, {
      preserveState: true,
      preserveScroll: true,
    })
  }, 300)
}
</script>

<template>
  <Input
    :default-value="initialValue"
    placeholder="Search users..."
    @input="(e: Event) => handleSearch((e.target as HTMLInputElement).value)"
  />
</template>
```

## Checkbox and Switch in Forms

```vue
<script setup lang="ts">
import { Checkbox } from '@/components/ui/checkbox'
import { Switch } from '@/components/ui/switch'
import { Label } from '@/components/ui/label'
import { Form } from '@inertiajs/vue3'
</script>

<template>
  <Form method="post" action="/settings">
    <template #default="{ errors }">
      <div class="flex items-center gap-2">
        <Checkbox id="notifications" name="notifications" default-checked />
        <Label for="notifications">Email notifications</Label>
      </div>

      <div class="flex items-center gap-2">
        <Switch id="dark_mode" name="dark_mode" />
        <Label for="dark_mode">Dark mode</Label>
      </div>
    </template>
  </Form>
</template>
```

## Textarea in Forms

```vue
<script setup lang="ts">
import { Textarea } from '@/components/ui/textarea'
import { Form } from '@inertiajs/vue3'
</script>

<template>
  <Form method="post" action="/posts">
    <template #default="{ errors }">
      <Textarea name="body" :rows="6" placeholder="Write your post..." />
      <p v-if="errors.body" class="text-sm text-destructive">{{ errors.body }}</p>
    </template>
  </Form>
</template>
```

## Date Picker in Forms

Use a hidden input to submit the selected date value:

```vue
<script setup lang="ts">
import { Calendar } from '@/components/ui/calendar'
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover'
import { Button } from '@/components/ui/button'
import { ref } from 'vue'

const props = defineProps<{ name: string; defaultValue?: string }>()
const date = ref<Date | undefined>(
  props.defaultValue ? new Date(props.defaultValue) : undefined
)
</script>

<template>
  <input type="hidden" :name="name" :value="date?.toISOString() ?? ''" />
  <Popover>
    <PopoverTrigger as-child>
      <Button variant="outline">
        {{ date ? date.toLocaleDateString() : 'Pick a date' }}
      </Button>
    </PopoverTrigger>
    <PopoverContent>
      <Calendar v-model="date" mode="single" />
    </PopoverContent>
  </Popover>
</template>
```

## Breadcrumbs with Link

```vue
<script setup lang="ts">
import {
  Breadcrumb, BreadcrumbItem, BreadcrumbLink, BreadcrumbList, BreadcrumbSeparator
} from '@/components/ui/breadcrumb'
import { Link } from '@inertiajs/vue3'

defineProps<{ items: { label: string; href?: string }[] }>()
</script>

<template>
  <Breadcrumb>
    <BreadcrumbList>
      <BreadcrumbItem v-for="(item, i) in items" :key="i">
        <BreadcrumbLink v-if="item.href" as-child>
          <Link :href="item.href">{{ item.label }}</Link>
        </BreadcrumbLink>
        <span v-else>{{ item.label }}</span>
        <BreadcrumbSeparator v-if="i < items.length - 1" />
      </BreadcrumbItem>
    </BreadcrumbList>
  </Breadcrumb>
</template>
```
