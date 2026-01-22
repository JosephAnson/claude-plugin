# ssr-dehydration: Use Dehydrate/Hydrate Pattern for SSR

## Priority: MEDIUM

## Explanation

For server-side rendering, prefetch queries on the server, dehydrate the cache to a serializable format, send it to the client, and hydrate on the client. This prevents content flash and duplicate requests.

## Bad Example

```vue
<script setup lang="ts">
// No SSR data passing - client refetches everything
// Server-side data fetched but not passed to query cache
const props = defineProps<{ posts: Post[] }>()

// This doesn't benefit from the server fetch
const { data } = useQuery({
  queryKey: ['posts'],
  queryFn: fetchPosts,
  // Will refetch on client, causing flash
})
</script>

<template>
  <!-- Awkward fallback pattern -->
  <PostList :posts="data ?? posts" />
</template>
```

## Good Example: Nuxt 3 with VueQuery

```ts
// plugins/vue-query.ts
import type { DehydratedState, VueQueryPluginOptions } from '@tanstack/vue-query'
import { QueryClient, VueQueryPlugin, hydrate, dehydrate } from '@tanstack/vue-query'
import { defineNuxtPlugin, useState } from '#app'

export default defineNuxtPlugin((nuxt) => {
  const vueQueryState = useState<DehydratedState | null>('vue-query')

  const queryClient = new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 5000,
      },
    },
  })

  const options: VueQueryPluginOptions = { queryClient }

  nuxt.vueApp.use(VueQueryPlugin, options)

  if (import.meta.server) {
    nuxt.hooks.hook('app:rendered', () => {
      vueQueryState.value = dehydrate(queryClient)
    })
  }

  if (import.meta.client) {
    nuxt.hooks.hook('app:created', () => {
      hydrate(queryClient, vueQueryState.value)
    })
  }
})
```

```vue
<script setup lang="ts">
// pages/posts.vue
import { useQuery } from '@tanstack/vue-query'

// Data is prefetched on server, hydrated on client
const { data: posts, suspense } = useQuery({
  queryKey: ['posts'],
  queryFn: fetchPosts,
})

// For SSR, await the suspense promise
await suspense()
</script>

<template>
  <PostList :posts="posts" />
</template>
```

## Good Example: Manual SSR Setup

```ts
// server.ts
import { dehydrate, QueryClient } from '@tanstack/vue-query'
import { renderToString } from 'vue/server-renderer'
import { createApp } from './app'

export async function render(url: string) {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 60 * 1000,  // Prevent immediate client refetch
      },
    },
  })

  const app = createApp({ queryClient })

  // Prefetch required data
  await queryClient.prefetchQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts,
  })

  const dehydratedState = dehydrate(queryClient)

  const html = await renderToString(app)

  // Serialize safely - JSON.stringify is XSS vulnerable
  const serializedState = serialize(dehydratedState)

  return `
    <html>
      <body>
        <div id="app">${html}</div>
        <script>window.__DEHYDRATED_STATE__ = ${serializedState}</script>
      </body>
    </html>
  `
}
```

```ts
// client.ts
import { hydrate, QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { createApp } from './app'

const queryClient = new QueryClient()
hydrate(queryClient, window.__DEHYDRATED_STATE__)

const app = createApp()
app.use(VueQueryPlugin, { queryClient })
app.mount('#app')
```

## Good Example: With useSuspenseQuery

```vue
<script setup lang="ts">
import { useSuspenseQuery } from '@tanstack/vue-query'

// useSuspenseQuery works well with SSR
// Data is guaranteed to be available
const { data: posts } = useSuspenseQuery({
  queryKey: ['posts'],
  queryFn: fetchPosts,
})
</script>

<template>
  <ul>
    <li v-for="post in posts" :key="post.id">
      {{ post.title }}
    </li>
  </ul>
</template>
```

## Good Example: Selective Prefetching

```ts
// Only prefetch certain queries on server
await queryClient.prefetchQuery({
  queryKey: ['posts'],
  queryFn: fetchPosts,
})

// Dehydrate with filter
const dehydratedState = dehydrate(queryClient, {
  shouldDehydrateQuery: (query) => {
    // Don't dehydrate user-specific data
    if (query.queryKey[0] === 'user') return false
    // Only dehydrate successful queries
    return query.state.status === 'success'
  },
})
```

## Context

- Create new QueryClient per request to prevent data sharing between users
- Set `staleTime > 0` on server to prevent immediate client refetch
- Use a safe serializer (not JSON.stringify) to prevent XSS
- Failed queries aren't dehydrated by default; use `shouldDehydrateQuery` to override
- Nuxt 3 integration handles most of this automatically with the right plugin setup
- `useSuspenseQuery` pairs well with Vue's `<Suspense>` for SSR
