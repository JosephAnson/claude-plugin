# pf-intent-prefetch: Prefetch on User Intent (Hover, Focus)

## Priority: MEDIUM

## Explanation

Prefetch data when users show intent to navigate (hover, focus) rather than waiting for click. This eliminates perceived loading time for likely next actions.

## Bad Example

```vue
<script setup lang="ts">
// No prefetching - data fetches on click
const props = defineProps<{ posts: Post[] }>()
</script>

<template>
  <ul>
    <li v-for="post in posts" :key="post.id">
      <RouterLink :to="`/posts/${post.id}`">
        {{ post.title }}
      </RouterLink>
      <!-- User clicks, waits for data to load -->
    </li>
  </ul>
</template>
```

## Good Example

```vue
<script setup lang="ts">
import { useQueryClient } from '@tanstack/vue-query'
import { postQueries } from '@/lib/queries'

const props = defineProps<{ posts: Post[] }>()
const queryClient = useQueryClient()

const handlePrefetch = (postId: number) => {
  queryClient.prefetchQuery({
    ...postQueries.detail(postId),
    staleTime: 60 * 1000,  // Consider fresh for 1 minute
  })
}
</script>

<template>
  <ul>
    <li v-for="post in posts" :key="post.id">
      <RouterLink
        :to="`/posts/${post.id}`"
        @mouseenter="handlePrefetch(post.id)"
        @focus="handlePrefetch(post.id)"
      >
        {{ post.title }}
      </RouterLink>
    </li>
  </ul>
</template>
```

## Good Example: With Vue Router Navigation Guards

```ts
// router/index.ts
import { queryClient } from '@/lib/query-client'
import { postQueries } from '@/lib/queries'

const router = createRouter({
  // ...
})

router.beforeResolve(async (to) => {
  // Prefetch data before navigation completes
  if (to.name === 'post-detail') {
    await queryClient.prefetchQuery(postQueries.detail(Number(to.params.id)))
  }
})
```

## Good Example: Prefetch with Delay

```vue
<script setup lang="ts">
import { useQueryClient } from '@tanstack/vue-query'
import { ref } from 'vue'
import { postQueries } from '@/lib/queries'

const props = defineProps<{ post: Post }>()
const queryClient = useQueryClient()
const timeoutRef = ref<ReturnType<typeof setTimeout>>()

const handleMouseEnter = () => {
  // Delay prefetch to avoid unnecessary requests on quick mouse movements
  timeoutRef.value = setTimeout(() => {
    queryClient.prefetchQuery(postQueries.detail(props.post.id))
  }, 100)
}

const handleMouseLeave = () => {
  if (timeoutRef.value) {
    clearTimeout(timeoutRef.value)
  }
}
</script>

<template>
  <RouterLink
    :to="`/posts/${post.id}`"
    @mouseenter="handleMouseEnter"
    @mouseleave="handleMouseLeave"
  >
    {{ post.title }}
  </RouterLink>
</template>
```

## Good Example: Composable for Prefetch on Hover

```ts
// composables/usePrefetchOnHover.ts
import { useQueryClient } from '@tanstack/vue-query'
import { ref, onUnmounted } from 'vue'
import type { QueryOptions } from '@tanstack/vue-query'

export function usePrefetchOnHover(getQueryOptions: () => QueryOptions, delay = 100) {
  const queryClient = useQueryClient()
  const timeoutRef = ref<ReturnType<typeof setTimeout>>()

  const onMouseEnter = () => {
    timeoutRef.value = setTimeout(() => {
      queryClient.prefetchQuery(getQueryOptions())
    }, delay)
  }

  const onMouseLeave = () => {
    if (timeoutRef.value) {
      clearTimeout(timeoutRef.value)
    }
  }

  onUnmounted(() => {
    if (timeoutRef.value) {
      clearTimeout(timeoutRef.value)
    }
  })

  return { onMouseEnter, onMouseLeave }
}
```

```vue
<script setup lang="ts">
import { usePrefetchOnHover } from '@/composables/usePrefetchOnHover'
import { postQueries } from '@/lib/queries'

const props = defineProps<{ post: Post }>()

const { onMouseEnter, onMouseLeave } = usePrefetchOnHover(
  () => postQueries.detail(props.post.id)
)
</script>

<template>
  <RouterLink
    :to="`/posts/${post.id}`"
    @mouseenter="onMouseEnter"
    @mouseleave="onMouseLeave"
  >
    {{ post.title }}
  </RouterLink>
</template>
```

## Prefetch Triggers

| Trigger | When to Use |
|---------|-------------|
| `@mouseenter` | Desktop, links/buttons user will likely click |
| `@focus` | Keyboard navigation, accessibility |
| `@touchstart` | Mobile, before navigation |
| Component mount | Likely next pages, wizard steps |
| Intersection Observer | Below-fold content |

## Context

- Set appropriate `staleTime` when prefetching to avoid immediate refetch
- Consider mobile where hover isn't available
- Don't prefetch everything - focus on likely paths
- Prefetched data uses `gcTime` for retention
- Watch network tab to verify prefetch timing
