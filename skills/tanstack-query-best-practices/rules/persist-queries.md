# persist-queries: Configure Query Persistence for Offline Support

## Priority: LOW

## Explanation

TanStack Query can persist the cache to storage (localStorage, IndexedDB, AsyncStorage) and restore it on app load. This enables offline support and faster startup by eliminating initial loading states.

## Bad Example

```ts
// No persistence - always starts fresh
const queryClient = new QueryClient()

// App setup
app.use(VueQueryPlugin, { queryClient })

// User refreshes page:
// 1. Empty cache
// 2. Loading spinners everywhere
// 3. Refetch all data
// Poor offline experience
```

## Good Example: Basic Persistence with localStorage

```ts
// main.ts
import { QueryClient, VueQueryPlugin } from '@tanstack/vue-query'
import { createSyncStoragePersister } from '@tanstack/query-sync-storage-persister'
import { persistQueryClient } from '@tanstack/query-persist-client-core'

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      gcTime: 1000 * 60 * 60 * 24,  // 24 hours - keep cache longer for persistence
      staleTime: 1000 * 60 * 5,     // 5 minutes
    },
  },
})

const persister = createSyncStoragePersister({
  storage: window.localStorage,
  key: 'VUE_QUERY_CACHE',
})

persistQueryClient({
  queryClient,
  persister,
  maxAge: 1000 * 60 * 60 * 24,  // 24 hours max
})

app.use(VueQueryPlugin, { queryClient })
```

## Good Example: Async Persistence with IndexedDB

```ts
import { createAsyncStoragePersister } from '@tanstack/query-async-storage-persister'
import { get, set, del } from 'idb-keyval'
import { persistQueryClient } from '@tanstack/query-persist-client-core'

const persister = createAsyncStoragePersister({
  storage: {
    getItem: async (key) => await get(key),
    setItem: async (key, value) => await set(key, value),
    removeItem: async (key) => await del(key),
  },
  key: 'VUE_QUERY_CACHE',
})

persistQueryClient({
  queryClient,
  persister,
  maxAge: 1000 * 60 * 60 * 24 * 7,  // 7 days
  buster: APP_VERSION,  // Bust cache on app updates
})
```

## Good Example: Selective Persistence

```ts
import { persistQueryClient } from '@tanstack/query-persist-client-core'

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      gcTime: 1000 * 60 * 60 * 24,
    },
  },
})

// Only persist certain queries
persistQueryClient({
  queryClient,
  persister,
  dehydrateOptions: {
    shouldDehydrateQuery: (query) => {
      // Don't persist user-specific sensitive data
      if (query.queryKey[0] === 'user-session') return false
      // Don't persist real-time data
      if (query.queryKey[0] === 'notifications') return false
      // Don't persist failed queries
      if (query.state.status !== 'success') return false
      // Persist everything else
      return true
    },
  },
})
```

## Good Example: Handling Restoration Loading

```vue
<script setup lang="ts">
// App.vue
import { ref, onMounted } from 'vue'
import { useQueryClient } from '@tanstack/vue-query'

const isRestoring = ref(true)

onMounted(async () => {
  // Wait for persistence restoration
  // This depends on your persistence setup
  await persistenceReady
  isRestoring.value = false
})
</script>

<template>
  <SplashScreen v-if="isRestoring" />
  <MainApp v-else />
</template>
```

## Good Example: Using VueQueryPlugin with Persistence

```ts
// plugins/vue-query.ts
import type { VueQueryPluginOptions } from '@tanstack/vue-query'
import { QueryClient } from '@tanstack/vue-query'
import { createSyncStoragePersister } from '@tanstack/query-sync-storage-persister'
import { persistQueryClient } from '@tanstack/query-persist-client-core'

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      gcTime: 1000 * 60 * 60 * 24,
      staleTime: 1000 * 60 * 5,
    },
  },
})

// Set up persistence
if (typeof window !== 'undefined') {
  const persister = createSyncStoragePersister({
    storage: window.localStorage,
  })

  persistQueryClient({
    queryClient,
    persister,
    maxAge: 1000 * 60 * 60 * 24,
  })
}

export const vueQueryPluginOptions: VueQueryPluginOptions = {
  queryClient,
}
```

```ts
// main.ts
import { VueQueryPlugin } from '@tanstack/vue-query'
import { vueQueryPluginOptions } from './plugins/vue-query'

app.use(VueQueryPlugin, vueQueryPluginOptions)
```

## Persistence Configuration

| Option | Purpose |
|--------|---------|
| `maxAge` | Maximum cache age before considered invalid |
| `buster` | String to invalidate cache (use app version) |
| `dehydrateOptions.shouldDehydrateQuery` | Filter which queries to persist |
| `hydrateOptions.shouldHydrate` | Filter which queries to restore |

## Context

- Requires `@tanstack/query-persist-client-core` and storage persister packages
- Set `gcTime` higher than default (5 min) for persistence to be useful
- Use `buster` option to invalidate cache on app updates
- Don't persist sensitive data or real-time data
- IndexedDB is better than localStorage for large caches
- Restored data is still subject to staleTime checks
- Works well with `networkMode: 'offlineFirst'`
