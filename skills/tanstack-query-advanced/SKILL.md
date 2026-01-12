---
name: tanstack-query-advanced
description: Advanced TanStack Query patterns including useInfiniteQuery, QueryClient operations, and optimistic updates. Use for infinite scroll, optimistic UI, or advanced caching scenarios.
---

# TanStack Query Advanced

## useInfiniteQuery

```typescript
const { data, fetchNextPage, hasNextPage, isFetchingNextPage } =
  useInfiniteQuery({
    queryKey: ['users', 'infinite'],
    queryFn: ({ pageParam = 1 }) =>
      api((client) =>
        client.GET('/api/users', {
          params: {
            query: { 'page[number]': pageParam },
          },
        }),
      ),
    getNextPageParam: (lastPage) =>
      lastPage.meta?.page < lastPage.meta?.pages
        ? lastPage.meta.page + 1
        : undefined,
    initialPageParam: 1,
  })

// All pages data
const allUsers = computed(
  () => data.value?.pages.flatMap((page) => page.data) || [],
)
```

## Infinite Scroll UI

```vue
<div v-for="user in allUsers" :key="user.id">
  {{ user.name }}
</div>

<nord-button
  v-if="hasNextPage"
  :loading="isFetchingNextPage"
  @click="fetchNextPage"
>
  Load More
</nord-button>
```

## Optimistic Updates

```typescript
const queryClient = useQueryClient()

const { mutate } = useMutation({
  mutationFn: updateUser,
  onMutate: async (newUser) => {
    // Cancel outgoing refetches
    await queryClient.cancelQueries({ queryKey: ['users', newUser.id] })

    // Snapshot previous value
    const previousUser = queryClient.getQueryData(['users', newUser.id])

    // Optimistically update
    queryClient.setQueryData(['users', newUser.id], newUser)

    return { previousUser }
  },
  onError: (err, newUser, context) => {
    // Rollback on error
    queryClient.setQueryData(['users', newUser.id], context?.previousUser)
  },
  onSettled: (_, __, newUser) => {
    // Refetch after mutation
    queryClient.invalidateQueries({ queryKey: ['users', newUser.id] })
  },
})
```

## Prefetch Queries

```typescript
const queryClient = useQueryClient()

// Prefetch on hover
const handleHover = (userId: string) => {
  queryClient.prefetchQuery({
    queryKey: ['users', userId],
    queryFn: () => fetchUser(userId),
  })
}
```

## Set Query Data

```typescript
const queryClient = useQueryClient()

// Manually set cache data
queryClient.setQueryData(['users', '123'], newUserData)
```

## Get Query Data

```typescript
const queryClient = useQueryClient()

// Read from cache
const cachedUser = queryClient.getQueryData(['users', '123'])
```

## Remove Queries

```typescript
const queryClient = useQueryClient()

// Remove from cache
queryClient.removeQueries({ queryKey: ['users', '123'] })
```

## Reset Queries

```typescript
const queryClient = useQueryClient()

// Reset to initial state
queryClient.resetQueries({ queryKey: ['users'] })
```

## Parallel Queries

```typescript
const { data: users } = useQuery({
  queryKey: ['users'],
  queryFn: fetchUsers,
})

const { data: departments } = useQuery({
  queryKey: ['departments'],
  queryFn: fetchDepartments,
})

const { data: roles } = useQuery({
  queryKey: ['roles'],
  queryFn: fetchRoles,
})

// All run in parallel
```

## useQueries (Dynamic Multiple)

```typescript
const userIds = ref(['1', '2', '3'])

const queries = useQueries({
  queries: computed(() =>
    userIds.value.map((id) => ({
      queryKey: ['users', id],
      queryFn: () => fetchUser(id),
    })),
  ),
})

// Access results
const allUsers = computed(() =>
  queries.value.map((q) => q.data).filter(Boolean),
)
```

## Mutation with Multiple Invalidations

```typescript
const { mutate } = useMutation({
  mutationFn: createConsultation,
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: consultationKeys.all })
    queryClient.invalidateQueries({ queryKey: patientKeys.all })
    queryClient.invalidateQueries({ queryKey: clientKeys.all })
  },
})
```

## Query Cancellation

```typescript
const { data, refetch } = useQuery({
  queryKey: ['users'],
  queryFn: async ({ signal }) => {
    const response = await fetch('/api/users', { signal })
    return response.json()
  },
})

// Cancel if component unmounts
onUnmounted(() => {
  queryClient.cancelQueries({ queryKey: ['users'] })
})
```

## Global Query Defaults

```typescript
// In nuxt.config.ts or plugin
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5,
      refetchOnWindowFocus: true,
      retry: 1,
    },
  },
})
```

## Suspense Mode

```typescript
const { data } = useQuery({
  queryKey: ['users'],
  queryFn: fetchUsers,
  suspense: true, // Throws promise for Suspense boundary
})
```
