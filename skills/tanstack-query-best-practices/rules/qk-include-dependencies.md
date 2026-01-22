# qk-include-dependencies: Include All Variables the Query Depends On

## Priority: CRITICAL

## Explanation

If your query function depends on a variable, that variable must be included in the query key. This ensures independent caching per variable combination and automatic refetching when dependencies change. Missing dependencies cause stale data bugs and cache collisions.

## Bad Example

```vue
<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'

const props = defineProps<{ userId: string }>()

// Missing userId in query key - all users share the same cache!
const { data } = useQuery({
  queryKey: ['posts'],
  queryFn: () => fetchPostsByUser(props.userId),
})
</script>
```

```vue
<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'

const props = defineProps<{ status: string; page: number }>()

// Missing filter parameters - won't refetch when filters change
const { data } = useQuery({
  queryKey: ['todos'],
  queryFn: () => fetchTodos({ status: props.status, page: props.page }),
})
</script>
```

## Good Example

```vue
<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'

const props = defineProps<{ userId: string }>()

// userId included - each user has their own cache entry
const { data } = useQuery({
  queryKey: ['posts', props.userId],
  queryFn: () => fetchPostsByUser(props.userId),
})
</script>
```

```vue
<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'

const props = defineProps<{ status: string; page: number }>()

// All dependencies included - refetches when any change
const { data } = useQuery({
  queryKey: ['todos', { status: props.status, page: props.page }],
  queryFn: () => fetchTodos({ status: props.status, page: props.page }),
})
</script>
```

## Good Example: With Reactive Props

```vue
<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { toRefs } from 'vue'

const props = defineProps<{ userId: string; filters: TodoFilters }>()
const { userId, filters } = toRefs(props)

// Query key uses refs - automatically reactive
const { data } = useQuery({
  queryKey: ['todos', userId, filters],
  queryFn: () => fetchTodos(userId.value, filters.value),
})
</script>
```

## Context

- This is arguably the most important query key rule
- Applies whenever query function uses external variables
- Prevents subtle bugs where different contexts share cached data
- Works in conjunction with staleTime - even with long staleTime, changing keys triggers new fetches
- In Vue, query keys are automatically reactive when using refs
