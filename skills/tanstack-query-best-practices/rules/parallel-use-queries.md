# parallel-use-queries: Use useQueries for Dynamic Parallel Queries

## Priority: MEDIUM

## Explanation

When you need to fetch multiple queries in parallel where the number or identity of queries is dynamic (e.g., fetching details for a list of IDs), use `useQueries`. It handles parallel execution and returns an array of query results.

## Bad Example

```vue
<script setup lang="ts">
import { ref, watch } from 'vue'

// Sequential fetching with watch - waterfall
const props = defineProps<{ userIds: string[] }>()
const users = ref<User[]>([])
const loading = ref(true)

watch(() => props.userIds, async (ids) => {
  const results = []
  for (const id of ids) {
    const user = await fetchUser(id)  // Sequential!
    results.push(user)
  }
  users.value = results
  loading.value = false
}, { immediate: true })

// N requests run one after another
</script>
```

```vue
<script setup lang="ts">
// Multiple useQuery calls in computed - breaks reactivity expectations
const props = defineProps<{ userIds: string[] }>()

// Can't call composables in a loop dynamically!
// This pattern doesn't work correctly
</script>
```

## Good Example

```vue
<script setup lang="ts">
import { useQueries } from '@tanstack/vue-query'
import { computed } from 'vue'

const props = defineProps<{ userIds: string[] }>()

const userQueries = useQueries({
  queries: computed(() =>
    props.userIds.map(id => ({
      queryKey: ['users', id],
      queryFn: () => fetchUser(id),
      staleTime: 5 * 60 * 1000,
    }))
  ),
})

const isLoading = computed(() => userQueries.value.some(q => q.isLoading))
const isError = computed(() => userQueries.value.some(q => q.isError))
const users = computed(() =>
  userQueries.value.map(q => q.data).filter(Boolean)
)
</script>

<template>
  <Loading v-if="isLoading" />
  <Error v-else-if="isError" />
  <ul v-else>
    <li v-for="user in users" :key="user.id">{{ user.name }}</li>
  </ul>
</template>
```

## Good Example: With Combine Option

```vue
<script setup lang="ts">
import { useQueries } from '@tanstack/vue-query'
import { computed } from 'vue'

const props = defineProps<{ userIds: string[] }>()

const { data: users, isPending } = useQueries({
  queries: computed(() =>
    props.userIds.map(id => ({
      queryKey: ['users', id],
      queryFn: () => fetchUser(id),
    }))
  ),
  // Combine results into single value
  combine: (results) => ({
    data: results.map(r => r.data).filter(Boolean),
    isPending: results.some(r => r.isPending),
    isError: results.some(r => r.isError),
  }),
})
</script>

<template>
  <Loading v-if="isPending" />
  <UserList v-else :users="users" />
</template>
```

## Good Example: Dependent Parallel Queries

```vue
<script setup lang="ts">
import { useQueries } from '@tanstack/vue-query'
import { computed } from 'vue'

const props = defineProps<{ postIds: string[] }>()

// First: fetch all posts in parallel
const postQueries = useQueries({
  queries: computed(() =>
    props.postIds.map(id => ({
      queryKey: ['posts', id],
      queryFn: () => fetchPost(id),
    }))
  ),
})

const posts = computed(() =>
  postQueries.value.map(q => q.data).filter(Boolean)
)

const authorIds = computed(() =>
  [...new Set(posts.value.map(p => p.authorId))]
)

// Then: fetch all unique authors in parallel
const authorQueries = useQueries({
  queries: computed(() =>
    authorIds.value.map(id => ({
      queryKey: ['users', id],
      queryFn: () => fetchUser(id),
      enabled: posts.value.length > 0,  // Wait for posts
    }))
  ),
})

// Combine data...
</script>
```

## Good Example: With Suspense

```vue
<script setup lang="ts">
import { useSuspenseQueries } from '@tanstack/vue-query'
import { computed } from 'vue'

const props = defineProps<{ userIds: string[] }>()

const userQueries = useSuspenseQueries({
  queries: computed(() =>
    props.userIds.map(id => ({
      queryKey: ['users', id],
      queryFn: () => fetchUser(id),
    }))
  ),
})

// All data guaranteed - no loading states needed
const users = computed(() => userQueries.value.map(q => q.data))
</script>

<template>
  <UserList :users="users" />
</template>
```

## Context

- Queries run in parallel, not sequentially
- Each query is cached independently
- Use `combine` to transform results array into single value
- Empty queries array is valid (returns empty results)
- Pairs well with `useSuspenseQueries` for guaranteed data
- Individual query options (staleTime, etc.) apply per-query
- In Vue, wrap queries array in `computed` for reactivity
