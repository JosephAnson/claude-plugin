---
name: vue-nuxt
description: This skill provides Vue 3 and Nuxt 4 best practices for the fitness app. Use when working with components, composables, data fetching, SSR, or handling async states.
---

# Vue 3 & Nuxt 4 Best Practices

This skill provides guidance for using Vue 3 Composition API and Nuxt 4 patterns effectively in the fitness application.

## Core Principles

**Always use Composition API**: Use `<script setup lang="ts">` for all components. Never use Options API.

**Component Structure**: Follow this order consistently:
1. `<script setup lang="ts">`
2. `<template>`
3. `<style scoped>` (if needed)

**Path Resolution**:
- `~/` - Resolves to `app/` directory (frontend code: components, pages, composables)
- `~~/` - Resolves to project root (server code: database, server utilities)

## Data Fetching Patterns

### Client-Side Mutations: toResult($api(...))

Use for form submissions and user-initiated actions:

```typescript
async function createItem() {
  const result = await toResult($api('/api/items', {
    method: 'POST',
    body: { name: 'New Item' }
  }))

  if (!result.success) {
    return toast.error('Error', { description: result.error.message })
  }

  await navigateTo(`/items/${result.data.id}`)
}
```

**Key points:**
- `toResult` wraps any promise and returns `{ success: true, data: T } | { success: false, error: FetchError }`
- Types are automatically inferred from `$api` route definitions
- Never wrap in try/catch - `toResult` handles errors internally
- Check `!result.success` before accessing data
- Located in `app/utils/result.ts`

### SSR Fetching: useBaseFetch

Use for SSR-compatible data fetching in components:

```typescript
const { data: trips, pending, status, refresh } = useBaseFetch('/api/trips', {
  key: 'user-trips', // Required for caching
  lazy: true, // Non-blocking navigation
  transform: trips => trips.map(trip => ({
    ...trip,
    name: trip.name.toUpperCase()
  })),
  default: () => []
})
```

**Options:**
- `key` - Cache key (required for proper caching)
- `lazy` - Don't block navigation (use with loading states)
- `transform` - Transform data before returning
- `default` - Fallback value while loading
- `watch` - Reactive dependencies to trigger refetch

**Error Checking:**
- Use `status` (not `error`) to check for errors
- Status values: `'idle' | 'pending' | 'success' | 'error'`
- Template: `v-else-if="status === 'error'"`

For complete data fetching patterns including `useAsyncData`, see `references/data-fetching.md`.

## Async State Handling

**Always handle all async states**: loading, error, empty, and success.

```vue
<script setup lang="ts">
const { data, pending, status } = useBaseFetch('/api/items', {
  key: 'items',
  lazy: true,
  default: () => []
})
</script>

<template>
  <div>
    <!-- Loading state -->
    <div v-if="pending" class="space-y-4">
      <UISkeleton class="h-20 w-full" />
      <UISkeleton class="h-20 w-full" />
    </div>

    <!-- Error state: Use status, not error -->
    <UIAlert v-else-if="status === 'error'" variant="destructive">
      <UIAlertTitle>Error</UIAlertTitle>
      <UIAlertDescription>Failed to load items. Please try again.</UIAlertDescription>
    </UIAlert>

    <!-- Empty state -->
    <div v-else-if="data.length === 0" class="text-center py-8">
      <p class="text-muted-foreground">No items found</p>
    </div>

    <!-- Success state -->
    <div v-else class="space-y-4">
      <ItemCard v-for="item in data" :key="item.id" :item="item" />
    </div>
  </div>
</template>
```

**Important:** Use `status === 'error'` instead of checking the `error` object directly.

## SSR & Hydration Rules

### ❌ NEVER: Access browser APIs in script setup

```vue
<!-- ❌ Wrong: Fails during SSR -->
<script setup lang="ts">
const width = window.innerWidth // ERROR: window is not defined
const element = document.getElementById('foo') // ERROR
</script>
```

### ✅ DO: Use onMounted or ClientOnly

```vue
<!-- ✅ Correct: Wait for client-side mounting -->
<script setup lang="ts">
const width = ref(0)

onMounted(() => {
  width.value = window.innerWidth
})
</script>

<template>
  <ClientOnly>
    <div>Client-only content: {{ width }}px</div>
  </ClientOnly>
</template>
```

### ❌ NEVER: Fetch data in lifecycle hooks

```vue
<!-- ❌ Wrong: Loses SSR benefits -->
<script setup lang="ts">
const data = ref([])

onMounted(async () => {
  data.value = await $fetch('/api/data')
})
</script>
```

### ✅ DO: Use useBaseFetch at top level

```vue
<!-- ✅ Correct: SSR-compatible -->
<script setup lang="ts">
const { data, pending, status } = useBaseFetch('/api/data', {
  key: 'my-data',
  lazy: true,
  default: () => []
})
</script>
```

## Path Resolution (Critical)

Nuxt 4 uses different aliases for different parts of the app:

```typescript
// ❌ WRONG: Server code using ~/
import { users } from '~/server/database/schema/users'
// Nitro looks in: /project/app/server/database/schema/users (doesn't exist!)

// ✅ CORRECT: Server code using ~~/
import { users } from '~~/server/database/schema/users'
// Nitro looks in: /project/server/database/schema/users (correct!)

// ✅ CORRECT: Frontend code using ~/
import MyComponent from '~/components/MyComponent.vue'
// Resolves to: /project/app/components/MyComponent.vue
```

**Rule of thumb:**
- Frontend imports (components, composables, pages) → `~/`
- Server imports (database, server utils, shared) → `~~/`

## Composables

Extract reusable logic into composables with a `use` prefix:

```typescript
// composables/useMobileMode.ts
export function useMobileMode() {
  const isMobile = ref(false)

  onMounted(() => {
    const checkMobile = () => {
      isMobile.value = window.innerWidth < 768
    }
    checkMobile()
    window.addEventListener('resize', checkMobile)

    onUnmounted(() => {
      window.removeEventListener('resize', checkMobile)
    })
  })

  return { isMobile }
}
```

**Composable rules:**
- Only for utility logic (NOT for state management/data fetching)
- Must start with `use` prefix
- Handle cleanup in `onUnmounted` when needed
- Don't create data fetching composables - use `useFetch` in pages

## Cleanup Logic

Always clean up event listeners and subscriptions:

```typescript
onMounted(() => {
  const handleResize = () => {
    // Handle resize
  }

  window.addEventListener('resize', handleResize)

  // Clean up when component unmounts
  onUnmounted(() => {
    window.removeEventListener('resize', handleResize)
  })
})
```

## Component Props & Emits

Always type props and emits explicitly:

```vue
<script setup lang="ts">
interface Props {
  title: string
  count?: number
  isActive?: boolean
}

const props = defineProps<Props>()

// With defaults
const props = withDefaults(defineProps<Props>(), {
  count: 0,
  isActive: false
})

// Emits
const emit = defineEmits<{
  update: [value: string]
  delete: [id: string]
  submit: [data: FormData]
}>()
</script>
```

## Critical Rules

### ✅ MUST DO
- Use `<script setup lang="ts">` for all components
- Use `toResult($api(...))` for client-side mutations (forms, actions)
- Use `useBaseFetch` for SSR-compatible data fetching
- Always provide a `key` option when using `useBaseFetch`
- Use `status === 'error'` for error checking (not the `error` object)
- Handle all async states (loading, error, empty, success)
- Use `onMounted` for browser API access
- Extract reusable logic into composables
- Implement cleanup in `onUnmounted` for listeners
- Type all props and emits explicitly
- Use `~~/` for server-side imports

### ❌ NEVER DO
- Use Options API
- Wrap `toResult` in try/catch blocks
- Check `error` directly from `useBaseFetch` (use `status === 'error'`)
- Access `window` or `document` in `<script setup>`
- Fetch data in `onMounted` (use `useBaseFetch` instead)
- Mutate props directly
- Write unscoped CSS
- Forget cleanup for event listeners
- Create state management composables (use page-level `useBaseFetch`)
- Use `~/` for server-side imports
- Skip loading/error/empty states

## Reference Files

For detailed patterns and examples:
- `references/data-fetching.md` - Complete guide to useFetch, useAsyncData, and $fetchResult
- `references/composables.md` - Composable patterns and when to use them
- `references/ssr-hydration.md` - SSR pitfalls and solutions

## Quick Reference: When to Use What

| Scenario | Tool | Why |
|----------|------|-----|
| Page data loading | `useBaseFetch` | SSR support, automatic caching |
| Form submission | `toResult($api(...))` | Simple error handling, no SSR needed |
| User-triggered action | `toResult($api(...))` | Client-only, returns typed result |
| Complex data transform | `useAsyncData` | Custom async function with caching |
| Reusable utility logic | Composable | Share non-data logic |
| Browser API access | `onMounted` | Avoid SSR errors |
| Client-only rendering | `<ClientOnly>` | Skip SSR for specific parts |
| Checking for errors | `status === 'error'` | Preferred over checking `error` object |
