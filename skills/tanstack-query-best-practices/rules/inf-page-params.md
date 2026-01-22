# inf-page-params: Always Provide getNextPageParam for Infinite Queries

## Priority: MEDIUM

## Explanation

`useInfiniteQuery` requires `getNextPageParam` to determine how to fetch subsequent pages. This function receives the last page's data and must return the next page parameter, or `undefined` when there are no more pages.

## Bad Example

```vue
<script setup lang="ts">
import { useInfiniteQuery } from '@tanstack/vue-query'

// Missing getNextPageParam - can't load more pages
const { data, fetchNextPage } = useInfiniteQuery({
  queryKey: ['posts'],
  queryFn: ({ pageParam }) => fetchPosts(pageParam),
  initialPageParam: 1,
  // Missing getNextPageParam - fetchNextPage won't work correctly
})
</script>
```

## Good Example: Offset-Based Pagination

```vue
<script setup lang="ts">
import { useInfiniteQuery } from '@tanstack/vue-query'

const {
  data,
  fetchNextPage,
  hasNextPage,
  isFetchingNextPage,
} = useInfiniteQuery({
  queryKey: ['posts'],
  queryFn: ({ pageParam }) => fetchPosts({ page: pageParam, limit: 20 }),
  initialPageParam: 1,
  getNextPageParam: (lastPage, allPages) => {
    // Return next page number, or undefined if no more pages
    if (lastPage.length < 20) {
      return undefined  // No more pages
    }
    return allPages.length + 1
  },
})
</script>
```

## Good Example: Cursor-Based Pagination

```vue
<script setup lang="ts">
import { useInfiniteQuery } from '@tanstack/vue-query'

interface PostsResponse {
  posts: Post[]
  nextCursor: string | null
}

const { data, fetchNextPage, hasNextPage } = useInfiniteQuery({
  queryKey: ['posts'],
  queryFn: ({ pageParam }): Promise<PostsResponse> =>
    fetchPosts({ cursor: pageParam }),
  initialPageParam: undefined as string | undefined,
  getNextPageParam: (lastPage) => lastPage.nextCursor ?? undefined,
})
</script>
```

## Good Example: Bi-directional Pagination

```vue
<script setup lang="ts">
import { useInfiniteQuery } from '@tanstack/vue-query'

interface PageParam {
  cursor?: string
  direction: 'initial' | 'next' | 'prev'
}

const props = defineProps<{ chatId: string }>()

const { data, fetchNextPage, fetchPreviousPage, hasNextPage, hasPreviousPage } =
  useInfiniteQuery({
    queryKey: ['messages', props.chatId],
    queryFn: ({ pageParam }) => fetchMessages({ chatId: props.chatId, cursor: pageParam }),
    initialPageParam: { direction: 'initial' } as PageParam,
    getNextPageParam: (lastPage) =>
      lastPage.hasMore ? { cursor: lastPage.nextCursor, direction: 'next' } : undefined,
    getPreviousPageParam: (firstPage) =>
      firstPage.hasPrevious
        ? { cursor: firstPage.prevCursor, direction: 'prev' }
        : undefined,
  })
</script>
```

## Good Example: With Total Count

```vue
<script setup lang="ts">
import { useInfiniteQuery } from '@tanstack/vue-query'
import { computed } from 'vue'

interface PaginatedResponse<T> {
  items: T[]
  total: number
  page: number
  pageSize: number
}

const props = defineProps<{ filters: ProductFilters }>()

const { data, hasNextPage } = useInfiniteQuery({
  queryKey: ['products', props.filters],
  queryFn: ({ pageParam }) =>
    fetchProducts({ ...props.filters, page: pageParam, pageSize: 20 }),
  initialPageParam: 1,
  getNextPageParam: (lastPage) => {
    const totalPages = Math.ceil(lastPage.total / lastPage.pageSize)
    if (lastPage.page < totalPages) {
      return lastPage.page + 1
    }
    return undefined
  },
})
</script>
```

## Accessing Flattened Data

```vue
<script setup lang="ts">
import { useInfiniteQuery } from '@tanstack/vue-query'
import { computed } from 'vue'

const { data, fetchNextPage, hasNextPage, isFetchingNextPage } = useInfiniteQuery({
  queryKey: ['posts'],
  queryFn: ({ pageParam }) => fetchPosts({ page: pageParam }),
  initialPageParam: 1,
  getNextPageParam: (lastPage, allPages) =>
    lastPage.posts.length === 20 ? allPages.length + 1 : undefined,
})

// data.pages is an array of page responses
// Flatten for easier iteration
const allPosts = computed(() =>
  data.value?.pages.flatMap(page => page.posts) ?? []
)
</script>

<template>
  <div>
    <PostCard
      v-for="post in allPosts"
      :key="post.id"
      :post="post"
    />
    <button
      v-if="hasNextPage"
      :disabled="isFetchingNextPage"
      @click="fetchNextPage()"
    >
      {{ isFetchingNextPage ? 'Loading...' : 'Load More' }}
    </button>
  </div>
</template>
```

## Context

- `getNextPageParam` returning `undefined` sets `hasNextPage` to `false`
- For bi-directional scrolling, also provide `getPreviousPageParam`
- `initialPageParam` is required and sets the first page parameter
- Use `maxPages` option to limit stored pages for memory management
- Consider `select` to transform page structure for component consumption
