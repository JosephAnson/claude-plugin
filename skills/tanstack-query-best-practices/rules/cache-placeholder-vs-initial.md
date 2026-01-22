# cache-placeholder-vs-initial: Understand Placeholder vs Initial Data

## Priority: MEDIUM

## Explanation

`placeholderData` and `initialData` both provide data before the fetch completes, but behave differently. `initialData` is treated as real cached data, while `placeholderData` is temporary and doesn't persist to cache. Choose based on whether your fallback data should be cached.

## Bad Example

```vue
<script setup lang="ts">
// Using initialData when you don't want it cached
const props = defineProps<{ postId: string; previewData: Post }>()

const { data } = useQuery({
  queryKey: ['posts', props.postId],
  queryFn: () => fetchPost(props.postId),
  initialData: props.previewData,  // Wrong: this becomes cached "truth"
  // If previewData is incomplete, it pollutes the cache
  // staleTime applies to this data as if it were fetched
})

// Using placeholderData when you want persistence
const { data: user } = useQuery({
  queryKey: ['users', userId],
  queryFn: () => fetchUser(userId),
  placeholderData: cachedUserFromList,  // Wrong: won't persist
  // User navigates away and back - placeholder shown again
  // No cache entry created until fetch completes
})
</script>
```

## Good Example: placeholderData for Temporary Display

```vue
<script setup lang="ts">
import { useQuery, useQueryClient } from '@tanstack/vue-query'

const props = defineProps<{ postId: string }>()
const queryClient = useQueryClient()

const { data, isPlaceholderData } = useQuery({
  queryKey: ['posts', props.postId],
  queryFn: () => fetchPost(props.postId),
  placeholderData: () => {
    // Use partial data from list cache as placeholder
    const posts = queryClient.getQueryData<Post[]>(['posts'])
    return posts?.find(p => p.id === props.postId)
  },
})
</script>

<template>
  <article :class="{ 'opacity-50': isPlaceholderData }">
    <h1>{{ data?.title }}</h1>
    <p v-if="isPlaceholderData">Loading full content...</p>
    <div v-else>{{ data?.content }}</div>
  </article>
</template>
```

## Good Example: initialData for Known Good Data

```vue
<script setup lang="ts">
import { useQuery, useQueryClient } from '@tanstack/vue-query'
import { onMounted } from 'vue'

// SSR: Data fetched on server should be initial
const props = defineProps<{ serverData: Post }>()

const { data } = useQuery({
  queryKey: ['posts', props.serverData.id],
  queryFn: () => fetchPost(props.serverData.id),
  initialData: props.serverData,
  // Specify when this data was fetched for proper stale calculation
  initialDataUpdatedAt: props.serverData.fetchedAt,
})
</script>

<template>
  <PostContent :post="data" />
</template>
```

```vue
<script setup lang="ts">
// Pre-seeding cache with complete data
import { useQueryClient } from '@tanstack/vue-query'
import { onMounted } from 'vue'

const queryClient = useQueryClient()

// If you have complete, authoritative data
onMounted(() => {
  queryClient.setQueryData(['config'], completeConfigData)
})
</script>
```

## Good Example: keepPreviousData Pattern

```vue
<script setup lang="ts">
import { useQuery, keepPreviousData } from '@tanstack/vue-query'

const props = defineProps<{ page: number }>()

// Keep showing old data while fetching new (pagination, filters)
const { data, isPlaceholderData } = useQuery({
  queryKey: ['products', props.page],
  queryFn: () => fetchProducts(props.page),
  placeholderData: keepPreviousData,  // Built-in helper
})
</script>

<template>
  <div :class="{ 'opacity-70': isPlaceholderData }">
    <ProductCard
      v-for="product in data"
      :key="product.id"
      :product="product"
    />
    <LoadingOverlay v-if="isPlaceholderData" />
  </div>
</template>
```

## Comparison Table

| Behavior | `initialData` | `placeholderData` |
|----------|---------------|-------------------|
| Persisted to cache | Yes | No |
| `staleTime` applies | Yes | No (always fetches) |
| `isPlaceholderData` | `false` | `true` |
| Shown to other components | Yes (cached) | No |
| Use case | SSR, complete known data | Preview, previous page |
| Affects `dataUpdatedAt` | Yes (use `initialDataUpdatedAt`) | No |

## Good Example: Combining Both

```vue
<script setup lang="ts">
import { useQuery, useQueryClient } from '@tanstack/vue-query'

const props = defineProps<{ postId: string; ssrData?: Post }>()
const queryClient = useQueryClient()

const { data } = useQuery({
  queryKey: ['posts', props.postId],
  queryFn: () => fetchPost(props.postId),

  // If we have SSR data, use as initial (cached)
  initialData: props.ssrData,
  initialDataUpdatedAt: props.ssrData?.fetchedAt,

  // If no SSR data, try to use list preview as placeholder
  placeholderData: () => {
    if (props.ssrData) return undefined  // Already have initial
    const posts = queryClient.getQueryData<Post[]>(['posts'])
    return posts?.find(p => p.id === props.postId)
  },
})
</script>
```

## Context

- `placeholderData` can be a value or function (lazy evaluation)
- `initialData` affects cache immediately on query creation
- Use `initialDataUpdatedAt` with `initialData` for proper stale calculations
- `keepPreviousData` is a built-in placeholder strategy
- Check `isPlaceholderData` to show loading indicators
- `placeholderData` is ideal for "instant" UI while fetching
