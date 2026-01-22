# err-error-boundaries: Use Error Boundaries with useQueryErrorResetBoundary

## Priority: HIGH

## Explanation

When using Suspense with TanStack Query, errors propagate to error boundaries. Use `useQueryErrorResetBoundary` to reset query errors when users retry, preventing stuck error states. In Vue, you can use error handling composables or libraries like `vue-error-boundary`.

## Bad Example

```vue
<script setup lang="ts">
// Error boundary without query reset - retry may not work
// Parent component
</script>

<template>
  <ErrorBoundary @error="handleError">
    <template #fallback="{ error, retry }">
      <div>
        <p>Error: {{ error.message }}</p>
        <button @click="retry">Try again</button>
        <!-- retry alone doesn't reset query state -->
      </div>
    </template>
    <ChildComponent />
  </ErrorBoundary>
</template>

<!-- Query error persists after retry click -->
```

## Good Example

```vue
<script setup lang="ts">
// QueryErrorBoundary.vue
import { useQueryErrorResetBoundary } from '@tanstack/vue-query'

const { reset } = useQueryErrorResetBoundary()

const handleReset = () => {
  reset()
}
</script>

<template>
  <ErrorBoundary @reset="handleReset">
    <template #fallback="{ error, reset: resetBoundary }">
      <div class="error-container">
        <h2>Something went wrong</h2>
        <pre>{{ error.message }}</pre>
        <button @click="resetBoundary">
          Try again
        </button>
      </div>
    </template>
    <slot />
  </ErrorBoundary>
</template>
```

```vue
<script setup lang="ts">
// Usage with Suspense
import QueryErrorBoundary from './QueryErrorBoundary.vue'
</script>

<template>
  <QueryErrorBoundary>
    <Suspense>
      <template #default>
        <Posts />
      </template>
      <template #fallback>
        <Loading />
      </template>
    </Suspense>
  </QueryErrorBoundary>
</template>
```

```vue
<script setup lang="ts">
// Posts.vue - uses useSuspenseQuery
import { useSuspenseQuery } from '@tanstack/vue-query'

// useSuspenseQuery throws on error, caught by boundary
const { data } = useSuspenseQuery({
  queryKey: ['posts'],
  queryFn: fetchPosts,
})
</script>

<template>
  <PostList :posts="data" />
</template>
```

## Good Example: With Vue Router Error Handling

```vue
<script setup lang="ts">
// Route-level error handling
import { useQueryErrorResetBoundary } from '@tanstack/vue-query'
import { onErrorCaptured, ref } from 'vue'

const { reset: resetQuery } = useQueryErrorResetBoundary()
const error = ref<Error | null>(null)

onErrorCaptured((err) => {
  error.value = err as Error
  return false // Prevent error propagation
})

const handleRetry = () => {
  resetQuery()
  error.value = null
}
</script>

<template>
  <div v-if="error">
    <p>Failed to load: {{ error.message }}</p>
    <button @click="handleRetry">Retry</button>
  </div>
  <RouterView v-else />
</template>
```

## Error Boundary Placement Strategy

```vue
<script setup lang="ts">
// Granular error boundaries for isolated failures
import QueryErrorBoundary from './QueryErrorBoundary.vue'
</script>

<template>
  <div class="dashboard">
    <!-- Each section can fail independently -->
    <QueryErrorBoundary>
      <Suspense>
        <template #default>
          <RecentActivity />
        </template>
        <template #fallback>
          <Skeleton />
        </template>
      </Suspense>
    </QueryErrorBoundary>

    <QueryErrorBoundary>
      <Suspense>
        <template #default>
          <Statistics />
        </template>
        <template #fallback>
          <Skeleton />
        </template>
      </Suspense>
    </QueryErrorBoundary>

    <QueryErrorBoundary>
      <Suspense>
        <template #default>
          <Notifications />
        </template>
        <template #fallback>
          <Skeleton />
        </template>
      </Suspense>
    </QueryErrorBoundary>
  </div>
</template>
```

## Context

- `useQueryErrorResetBoundary` clears error state for all queries in the boundary
- Always pair Suspense queries with error boundaries
- Place boundaries based on failure isolation needs
- Consider inline error handling for non-critical data
- The reset only affects queries that were in error state
- Vue's `onErrorCaptured` can be used for custom error boundaries
