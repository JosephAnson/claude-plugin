# Data Fetching Patterns in Nuxt 4

Complete guide to data fetching patterns using `useFetch`, `useAsyncData`, and `$fetchResult`.

## Overview

Nuxt 4 provides multiple ways to fetch data, each optimized for different use cases:

| Function | Use Case | SSR Support | Returns | Caching |
|----------|----------|-------------|---------|---------|
| `useFetch` | Standard data fetching | Yes | Reactive refs | Yes (with key) |
| `useAsyncData` | Custom async functions | Yes | Reactive refs | Yes (with key) |
| `$fetchResult` | Client-side actions | No | Promise | No |
| `$fetch` | Server-side only | N/A | Promise | No |

## useFetch: Standard Data Fetching

Use `useFetch` for most data fetching needs in components and pages.

### Basic Usage

```vue
<script setup lang="ts">
const { data, pending, error, refresh } = useBaseFetch('/api/users')
</script>

<template>
  <div v-if="pending">Loading...</div>
  <div v-else-if="error">Error: {{ error.message }}</div>
  <div v-else>
    <UserCard v-for="user in data" :key="user.id" :user="user" />
  </div>
</template>
```

### Return Values

```typescript
const {
  data,      // Ref<T | null> - The fetched data
  pending,   // Ref<boolean> - Loading state
  error,     // Ref<Error | null> - Error state
  refresh,   // () => Promise<void> - Refetch function
  execute,   // () => Promise<void> - Manual execution
  status     // Ref<'idle' | 'pending' | 'success' | 'error'>
} = useBaseFetch('/api/endpoint')
```

### Key Option (Required for Caching)

Always provide a unique cache key:

```typescript
// ✅ Correct: With key
const { data } = useBaseFetch('/api/trips', {
  key: 'user-trips'
})

// ❌ Wrong: No key (creates new request on every component mount)
const { data } = useBaseFetch('/api/trips')
```

**Key naming convention:**
- Use descriptive, unique keys
- Include filter/query info if relevant
- Format: `entity-descriptor` or `entity-filter-value`

```typescript
// Good key names
key: 'user-trips'
key: 'active-workouts'
key: 'workout-123'
key: 'user-goals-pending'

// Bad key names
key: 'data'
key: 'list'
key: 'api-call'
```

### Lazy Option

Use `lazy: true` for non-blocking navigation:

```typescript
const { data, pending } = useBaseFetch('/api/trips', {
  key: 'user-trips',
  lazy: true, // Don't block navigation
  default: () => [] // Provide default while loading
})
```

**When to use lazy:**
- Data is not critical for initial render
- You have proper loading states in the template
- You want navigation to be instant

**When NOT to use lazy:**
- Data is required for the page to function
- SEO-critical content
- Above-the-fold content

### Default Option

Provide a default value to avoid null checks:

```typescript
const { data: trips } = useBaseFetch('/api/trips', {
  key: 'user-trips',
  lazy: true,
  default: () => [] // Returns empty array while loading
})

// Now `trips` is always an array (never null)
```

### Transform Option

Transform data before it's stored:

```typescript
const { data: trips } = useBaseFetch('/api/trips', {
  key: 'user-trips',
  transform: (trips) => trips.map(trip => ({
    ...trip,
    displayName: trip.name.toUpperCase(),
    formattedDate: new Date(trip.date).toLocaleDateString()
  }))
})
```

### Query Parameters

Pass dynamic query parameters:

```typescript
const status = ref<'active' | 'completed'>('active')

const { data: goals } = useBaseFetch('/api/goals', {
  key: 'user-goals',
  query: computed(() => ({
    status: status.value,
    limit: 20
  }))
})
```

**Important:** Wrap query in `computed()` for reactivity.

### Watch Option

Automatically refetch when dependencies change:

```typescript
const userId = ref('123')

const { data: user } = useBaseFetch(`/api/users/${userId.value}`, {
  key: computed(() => `user-${userId.value}`),
  watch: [userId] // Refetch when userId changes
})
```

### Pick Option

Select specific fields from the response (reduces payload):

```typescript
const { data: user } = useBaseFetch('/api/users/me', {
  key: 'current-user',
  pick: ['id', 'name', 'email'] // Only these fields
})
```

### Server Option

Control whether to fetch on server, client, or both:

```typescript
// Server-side only (default)
const { data } = useBaseFetch('/api/data', {
  key: 'data',
  server: true
})

// Client-side only
const { data } = useBaseFetch('/api/data', {
  key: 'data',
  server: false
})
```

### Complete useFetch Example

```vue
<script setup lang="ts">
const status = ref<'active' | 'completed'>('active')
const sortBy = ref<'date' | 'name'>('date')

const {
  data: workouts,
  pending,
  error,
  refresh
} = useBaseFetch('/api/workouts', {
  key: computed(() => `workouts-${status.value}-${sortBy.value}`),
  query: computed(() => ({
    status: status.value,
    sortBy: sortBy.value,
    limit: 50
  })),
  lazy: true,
  default: () => [],
  transform: (workouts) => workouts.map(w => ({
    ...w,
    formattedDate: new Date(w.createdAt).toLocaleDateString()
  })),
  watch: [status, sortBy]
})

// Expose refresh to parent if needed
defineExpose({ refresh })
</script>

<template>
  <div>
    <!-- Filters -->
    <div class="flex gap-2 mb-4">
      <UIButton
        :variant="status === 'active' ? 'default' : 'outline'"
        @click="status = 'active'"
      >
        Active
      </UIButton>
      <UIButton
        :variant="status === 'completed' ? 'default' : 'outline'"
        @click="status = 'completed'"
      >
        Completed
      </UIButton>
    </div>

    <!-- Loading state -->
    <div v-if="pending" class="space-y-4">
      <UISkeleton class="h-20 w-full" />
      <UISkeleton class="h-20 w-full" />
    </div>

    <!-- Error state -->
    <UIAlert v-else-if="error" variant="destructive">
      <UIAlertTitle>Error</UIAlertTitle>
      <UIAlertDescription>{{ error.message }}</UIAlertDescription>
    </UIAlert>

    <!-- Empty state -->
    <div v-else-if="workouts.length === 0" class="text-center py-8">
      <p class="text-muted-foreground">No workouts found</p>
    </div>

    <!-- Success state -->
    <div v-else class="space-y-4">
      <WorkoutCard
        v-for="workout in workouts"
        :key="workout.id"
        :workout="workout"
      />
    </div>
  </div>
</template>
```

## useAsyncData: Custom Async Functions

Use when you need to run custom async code (not just fetch):

```typescript
const { data, pending, error } = await useAsyncData(
  'complex-data', // Cache key
  async () => {
    // Custom async logic
    const [users, workouts] = await Promise.all([
      $fetch('/api/users'),
      $fetch('/api/workouts')
    ])

    return {
      users,
      workouts,
      combined: users.map(u => ({
        ...u,
        workoutCount: workouts.filter(w => w.userId === u.id).length
      }))
    }
  }
)
```

**When to use useAsyncData:**
- Need to combine multiple API calls
- Complex data transformation
- Conditional fetching logic
- Non-HTTP async operations

## $fetchResult: Client-Side Actions

Use for form submissions and user-initiated actions:

```typescript
async function createGoal() {
  const result = await $fetchResult('/api/goals', {
    method: 'POST',
    body: {
      title: 'New Goal',
      targetValue: 100
    }
  })

  if (!result.success) {
    toast.error({
      title: 'Error',
      description: result.error.message
    })
    return
  }

  toast.success({
    title: 'Success',
    description: 'Goal created!'
  })

  await navigateTo(`/goals/${result.data.id}`)
}
```

**Return type:**

```typescript
type FetchResult<T> =
  | { success: true; data: T }
  | { success: false; error: { message: string; statusCode: number } }
```

**Key features:**
- Returns typed result object (not throwing errors)
- No need for try/catch
- Perfect for form submissions
- Client-side only (no SSR)

**Common pattern in form components:**

```vue
<script setup lang="ts">
const emit = defineEmits<{
  created: [goal: Goal]
  cancelled: []
}>()

const isSubmitting = ref(false)

async function handleSubmit() {
  isSubmitting.value = true

  const result = await $fetchResult('/api/goals', {
    method: 'POST',
    body: formData
  })

  isSubmitting.value = false

  if (!result.success) {
    toast.error({
      title: 'Error',
      description: result.error.message
    })
    return
  }

  emit('created', result.data)
}
</script>
```

## Refreshing Data

### Manual Refresh

```typescript
const { data, refresh } = useBaseFetch('/api/workouts', {
  key: 'workouts'
})

async function handleDelete(id: string) {
  await $fetchResult(`/api/workouts/${id}`, { method: 'DELETE' })
  await refresh() // Refetch workouts
}
```

### Auto-refresh with refreshNuxtData

Refresh specific or all cached data:

```typescript
// Refresh specific key
await refreshNuxtData('user-workouts')

// Refresh multiple keys
await refreshNuxtData(['user-workouts', 'user-goals'])

// Refresh all data
await refreshNuxtData()
```

### Refresh on navigation

```typescript
const { data } = useBaseFetch('/api/data', {
  key: 'data',
  getCachedData: (key) => {
    // Only use cache if data is less than 30 seconds old
    const data = useNuxtData(key)
    if (!data.data) return

    const age = Date.now() - data._value.fetchedAt
    if (age < 30000) return data.data

    return undefined // Force refetch
  }
})
```

## Error Handling

### useFetch Errors

```vue
<script setup lang="ts">
const { data, error } = useBaseFetch('/api/workouts', {
  key: 'workouts',
  lazy: true,
  onResponseError({ response }) {
    // Handle specific error codes
    if (response.status === 401) {
      navigateTo('/login')
    }
  }
})
</script>

<template>
  <UIAlert v-if="error" variant="destructive">
    <UIAlertTitle>Error</UIAlertTitle>
    <UIAlertDescription>{{ error.message }}</UIAlertDescription>
  </UIAlert>
</template>
```

### $fetchResult Errors

```typescript
const result = await $fetchResult('/api/endpoint', {
  method: 'POST',
  body: data
})

if (!result.success) {
  // Handle error
  if (result.error.statusCode === 404) {
    toast.error({ title: 'Not found' })
  } else {
    toast.error({
      title: 'Error',
      description: result.error.message
    })
  }
  return
}

// Success
const responseData = result.data
```

## Common Patterns

### Pattern: List + Create/Update

```vue
<script setup lang="ts">
const { data: goals, refresh } = useBaseFetch('/api/goals', {
  key: 'user-goals',
  lazy: true,
  default: () => []
})

function handleCreated(goal: Goal) {
  toast.success({ title: 'Created!', description: goal.title })
  refresh()
}

function handleUpdated(goal: Goal) {
  toast.success({ title: 'Updated!', description: goal.title })
  refresh()
}
</script>

<template>
  <div>
    <UIDialog v-slot="{ close }">
      <UIDialogTrigger as-child>
        <UIButton>Create Goal</UIButton>
      </UIDialogTrigger>
      <UIDialogContent>
        <GoalFormCreate
          @created="(goal) => { handleCreated(goal); close(); }"
          @cancelled="close"
        />
      </UIDialogContent>
    </UIDialog>

    <GoalCard
      v-for="goal in goals"
      :key="goal.id"
      :goal="goal"
      @updated="handleUpdated"
    />
  </div>
</template>
```

### Pattern: Dependent Fetches

```vue
<script setup lang="ts">
// First fetch
const { data: user } = useBaseFetch('/api/users/me', {
  key: 'current-user'
})

// Second fetch depends on first
const { data: workouts } = useBaseFetch('/api/workouts', {
  key: computed(() => `workouts-${user.value?.id}`),
  query: computed(() => ({
    userId: user.value?.id
  })),
  // Only fetch when user is loaded
  immediate: computed(() => !!user.value?.id)
})
</script>
```

### Pattern: Infinite Scroll

```vue
<script setup lang="ts">
const page = ref(1)
const allWorkouts = ref<Workout[]>([])

const { data: workouts, pending } = useBaseFetch('/api/workouts', {
  key: computed(() => `workouts-page-${page.value}`),
  query: computed(() => ({
    page: page.value,
    limit: 20
  })),
  lazy: true,
  watch: [page],
  onResponse({ response }) {
    if (response._data) {
      allWorkouts.value.push(...response._data)
    }
  }
})

function loadMore() {
  page.value++
}
</script>
```

## Summary: Decision Tree

**When to use what:**

1. **Need SSR + caching?** → `useFetch`
2. **Complex async logic?** → `useAsyncData`
3. **Form submission?** → `$fetchResult`
4. **User action (delete, update)?** → `$fetchResult`
5. **Server-side only?** → `$fetch` (in API routes)

**Common mistakes to avoid:**

❌ Fetching in `onMounted` instead of `useFetch`
❌ Not providing a `key` for `useFetch`
❌ Wrapping `$fetchResult` in try/catch
❌ Using `$fetch` in components (use `useFetch` instead)
❌ Forgetting to handle all async states
