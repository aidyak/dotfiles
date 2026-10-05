# shadcn-svelte Components for Inertia — Extended Reference

Additional component patterns adapted for Inertia.js + Rails + Svelte.
Svelte 5 syntax with Svelte 4 notes where they differ.

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

```svelte
<script lang="ts">
  import {
    AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent,
    AlertDialogDescription, AlertDialogFooter, AlertDialogHeader, AlertDialogTitle,
    AlertDialogTrigger
  } from '$lib/components/ui/alert-dialog'
  import { Button } from '$lib/components/ui/button'
  import { router } from '@inertiajs/svelte'

  let { userId }: { userId: number } = $props()
</script>

<AlertDialog>
  <AlertDialogTrigger asChild let:builder>
    <Button variant="destructive" builders={[builder]}>Delete</Button>
  </AlertDialogTrigger>
  <AlertDialogContent>
    <AlertDialogHeader>
      <AlertDialogTitle>Delete user?</AlertDialogTitle>
      <AlertDialogDescription>This action cannot be undone.</AlertDialogDescription>
    </AlertDialogHeader>
    <AlertDialogFooter>
      <AlertDialogCancel>Cancel</AlertDialogCancel>
      <AlertDialogAction onclick={() => router.delete(`/users/${userId}`)}>
        Delete
      </AlertDialogAction>
    </AlertDialogFooter>
  </AlertDialogContent>
</AlertDialog>
```

## Sheet (Slide-over Panel)

```svelte
<script lang="ts">
  import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger } from '$lib/components/ui/sheet'
  import { Button } from '$lib/components/ui/button'
  import { Input } from '$lib/components/ui/input'
  import { Form } from '@inertiajs/svelte'
</script>

<Sheet>
  <SheetTrigger asChild let:builder>
    <Button builders={[builder]}>New User</Button>
  </SheetTrigger>
  <SheetContent>
    <SheetHeader>
      <SheetTitle>Create User</SheetTitle>
    </SheetHeader>
    <Form method="post" action="/users">
      {#snippet children({ errors, processing })}
        <div class="space-y-4 mt-4">
          <Input name="name" placeholder="Name" />
          {#if errors.name}<p class="text-sm text-destructive">{errors.name}</p>{/if}
          <Button type="submit" disabled={processing}>Create</Button>
        </div>
      {/snippet}
    </Form>
  </SheetContent>
</Sheet>
```

## Tabs with URL State

Use Inertia navigation to persist tab state in the URL:

```svelte
<script lang="ts">
  import { Tabs, TabsContent, TabsList, TabsTrigger } from '$lib/components/ui/tabs'
  import { router } from '@inertiajs/svelte'

  let { activeTab, userId, profile, activity }: {
    activeTab: string
    userId: number
    profile: Profile
    activity: Activity[]
  } = $props()
</script>

<Tabs
  value={activeTab}
  onValueChange={(tab) => router.get(`/users/${userId}`, { tab }, { preserveState: true })}
>
  <TabsList>
    <TabsTrigger value="profile">Profile</TabsTrigger>
    <TabsTrigger value="activity">Activity</TabsTrigger>
  </TabsList>
  <TabsContent value="profile"><ProfileView data={profile} /></TabsContent>
  <TabsContent value="activity"><ActivityFeed data={activity} /></TabsContent>
</Tabs>
```

Svelte 4: `on:valueChange` instead of `onValueChange`.

## Dropdown Menu with Actions

```svelte
<script lang="ts">
  import {
    DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuTrigger
  } from '$lib/components/ui/dropdown-menu'
  import { Button } from '$lib/components/ui/button'
  import { router } from '@inertiajs/svelte'

  let { user }: { user: User } = $props()
</script>

<DropdownMenu>
  <DropdownMenuTrigger asChild let:builder>
    <Button variant="ghost" size="icon" builders={[builder]}>
      <MoreHorizontal />
    </Button>
  </DropdownMenuTrigger>
  <DropdownMenuContent>
    <DropdownMenuItem onclick={() => router.visit(`/users/${user.id}/edit`)}>
      Edit
    </DropdownMenuItem>
    <DropdownMenuItem
      class="text-destructive"
      onclick={() => { if (confirm('Delete?')) router.delete(`/users/${user.id}`) }}
    >
      Delete
    </DropdownMenuItem>
  </DropdownMenuContent>
</DropdownMenu>
```

## Pagination

Server-driven pagination with Inertia navigation:

```svelte
<script lang="ts">
  import { Button } from '$lib/components/ui/button'
  import { router } from '@inertiajs/svelte'

  let { currentPage, totalPages }: { currentPage: number; totalPages: number } = $props()

  const goToPage = (page: number) => {
    router.get(window.location.pathname, { page }, { preserveState: true })
  }
</script>

<div class="flex gap-2">
  <Button
    variant="outline"
    disabled={currentPage <= 1}
    onclick={() => goToPage(currentPage - 1)}
  >
    Previous
  </Button>
  <span class="flex items-center px-2">
    Page {currentPage} of {totalPages}
  </span>
  <Button
    variant="outline"
    disabled={currentPage >= totalPages}
    onclick={() => goToPage(currentPage + 1)}
  >
    Next
  </Button>
</div>
```

## Search Input with Debounce

```svelte
<script lang="ts">
  import { Input } from '$lib/components/ui/input'
  import { router } from '@inertiajs/svelte'

  let { initialValue }: { initialValue: string } = $props()

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

<Input
  value={initialValue}
  placeholder="Search users..."
  oninput={(e) => handleSearch(e.currentTarget.value)}
/>
```

## Checkbox and Switch in Forms

```svelte
<script lang="ts">
  import { Checkbox } from '$lib/components/ui/checkbox'
  import { Switch } from '$lib/components/ui/switch'
  import { Label } from '$lib/components/ui/label'
  import { Form } from '@inertiajs/svelte'
</script>

<Form method="post" action="/settings">
  {#snippet children({ errors })}
    <div class="flex items-center gap-2">
      <Checkbox id="notifications" name="notifications" checked />
      <Label for="notifications">Email notifications</Label>
    </div>

    <div class="flex items-center gap-2">
      <Switch id="dark_mode" name="dark_mode" />
      <Label for="dark_mode">Dark mode</Label>
    </div>
  {/snippet}
</Form>
```

## Textarea in Forms

```svelte
<script lang="ts">
  import { Textarea } from '$lib/components/ui/textarea'
  import { Form } from '@inertiajs/svelte'
</script>

<Form method="post" action="/posts">
  {#snippet children({ errors })}
    <Textarea name="body" rows={6} placeholder="Write your post..." />
    {#if errors.body}<p class="text-sm text-destructive">{errors.body}</p>{/if}
  {/snippet}
</Form>
```

## Date Picker in Forms

Use a hidden input to submit the selected date value:

```svelte
<script lang="ts">
  import { Calendar } from '$lib/components/ui/calendar'
  import { Popover, PopoverContent, PopoverTrigger } from '$lib/components/ui/popover'
  import { Button } from '$lib/components/ui/button'

  let { name, defaultValue }: { name: string; defaultValue?: string } = $props()
  let date = $state<Date | undefined>(
    defaultValue ? new Date(defaultValue) : undefined
  )
</script>

<input type="hidden" {name} value={date?.toISOString() ?? ''} />
<Popover>
  <PopoverTrigger asChild let:builder>
    <Button variant="outline" builders={[builder]}>
      {date ? date.toLocaleDateString() : 'Pick a date'}
    </Button>
  </PopoverTrigger>
  <PopoverContent>
    <Calendar bind:value={date} mode="single" />
  </PopoverContent>
</Popover>
```

## Breadcrumbs with Link

```svelte
<script lang="ts">
  import {
    Breadcrumb, BreadcrumbItem, BreadcrumbLink, BreadcrumbList, BreadcrumbSeparator
  } from '$lib/components/ui/breadcrumb'
  import { Link } from '@inertiajs/svelte'

  let { items }: { items: { label: string; href?: string }[] } = $props()
</script>

<Breadcrumb>
  <BreadcrumbList>
    {#each items as item, i (i)}
      <BreadcrumbItem>
        {#if item.href}
          <BreadcrumbLink asChild>
            <Link href={item.href}>{item.label}</Link>
          </BreadcrumbLink>
        {:else}
          <span>{item.label}</span>
        {/if}
        {#if i < items.length - 1}
          <BreadcrumbSeparator />
        {/if}
      </BreadcrumbItem>
    {/each}
  </BreadcrumbList>
</Breadcrumb>
```
