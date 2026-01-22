# query-cancellation: Implement Query Cancellation Properly

## Priority: MEDIUM

## Explanation

TanStack Query provides an `AbortSignal` to cancel in-flight requests when queries become stale or components unmount. Pass this signal to your fetch calls to prevent memory leaks and wasted bandwidth.

## Bad Example

```vue
<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'

// Not using abort signal - requests complete even when unnecessary
const { data } = useQuery({
  queryKey: ['search', searchTerm],
  queryFn: async () => {
    // User types fast: "a", "ab", "abc"
    // Three requests fire, all complete, wasting bandwidth
    const response = await fetch(`/api/search?q=${searchTerm}`)
    return response.json()
  },
})
</script>
```

```vue
<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'

const props = defineProps<{ userId: string }>()

// Component unmounts but request keeps running
const { data } = useQuery({
  queryKey: ['user', props.userId],
  queryFn: async () => {
    const response = await fetch(`/api/users/${props.userId}`)
    return response.json()  // Completes even if user navigated away
  },
})
</script>
```

## Good Example: Using AbortSignal with Fetch

```vue
<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { ref } from 'vue'

const searchTerm = ref('')

const { data } = useQuery({
  queryKey: ['search', searchTerm],
  queryFn: async ({ signal }) => {
    const response = await fetch(`/api/search?q=${searchTerm.value}`, {
      signal,  // Pass abort signal to fetch
    })
    return response.json()
  },
})

// Now when user types "a", "ab", "abc" quickly:
// - "a" request is cancelled when "ab" starts
// - "ab" request is cancelled when "abc" starts
// - Only "abc" completes
</script>
```

## Good Example: With Axios

```vue
<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import axios from 'axios'

const props = defineProps<{ userId: string }>()

const { data } = useQuery({
  queryKey: ['users', props.userId],
  queryFn: async ({ signal }) => {
    const response = await axios.get(`/api/users/${props.userId}`, {
      signal,  // Axios supports AbortSignal
    })
    return response.data
  },
})
</script>
```

## Good Example: Manual Cancellation

```vue
<script setup lang="ts">
import { useQuery, useQueryClient } from '@tanstack/vue-query'
import { ref } from 'vue'

const queryClient = useQueryClient()
const searchTerm = ref('')

const { data } = useQuery({
  queryKey: ['search', searchTerm],
  queryFn: async ({ signal }) => {
    const response = await fetch(`/api/search?q=${searchTerm.value}`, { signal })
    return response.json()
  },
  enabled: () => searchTerm.value.length > 0,
})

// Cancel all search queries manually
const handleClear = () => {
  queryClient.cancelQueries({ queryKey: ['search'] })
  searchTerm.value = ''
}
</script>

<template>
  <div>
    <input v-model="searchTerm" />
    <button @click="handleClear">Clear</button>
    <Results :data="data" />
  </div>
</template>
```

## Good Example: In Mutations (Before Optimistic Update)

```vue
<script setup lang="ts">
import { useMutation, useQueryClient } from '@tanstack/vue-query'

const queryClient = useQueryClient()

const updateTodo = useMutation({
  mutationFn: (todo: Todo) => api.updateTodo(todo),
  onMutate: async (newTodo) => {
    // Cancel outgoing queries to prevent overwriting optimistic update
    await queryClient.cancelQueries({ queryKey: ['todos'] })
    await queryClient.cancelQueries({ queryKey: ['todos', newTodo.id] })

    // Proceed with optimistic update...
    const previousTodos = queryClient.getQueryData(['todos'])
    queryClient.setQueryData(['todos'], (old) => /* ... */)

    return { previousTodos }
  },
})
</script>
```

## Good Example: Custom Cancellable Promise

```vue
<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'

const props = defineProps<{ params: ComputationParams }>()

// For non-fetch APIs that need custom cancellation
const { data } = useQuery({
  queryKey: ['expensive-computation', props.params],
  queryFn: ({ signal }) => {
    return new Promise((resolve, reject) => {
      // Check if already cancelled
      if (signal.aborted) {
        reject(new DOMException('Aborted', 'AbortError'))
        return
      }

      const worker = new Worker('computation.js')
      worker.postMessage(props.params)

      worker.onmessage = (e) => resolve(e.data)
      worker.onerror = (e) => reject(e)

      // Listen for cancellation
      signal.addEventListener('abort', () => {
        worker.terminate()
        reject(new DOMException('Aborted', 'AbortError'))
      })
    })
  },
})
</script>
```

## When Queries Are Cancelled

| Scenario | Cancelled? |
|----------|------------|
| Query key changes | Yes |
| Component unmounts | Yes |
| `queryClient.cancelQueries()` called | Yes |
| Refetch triggered | Previous request cancelled |
| `enabled` becomes false | Yes |

## Context

- Always pass `signal` to fetch/axios for automatic cancellation
- Cancelled queries don't trigger `onError` - they're silently dropped
- Use `queryClient.cancelQueries()` before optimistic updates
- AbortError is thrown when cancelled - handle if needed
- Cancellation prevents wasted bandwidth and race conditions
- Essential for search-as-you-type and fast navigation patterns
