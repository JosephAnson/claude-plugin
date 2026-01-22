# mut-mutation-state: Use useMutationState for Cross-Component Mutation Tracking

## Priority: MEDIUM

## Explanation

`useMutationState` allows you to access mutation state from anywhere in your component tree, not just where `useMutation` was called. Use it to show loading indicators, display optimistic updates, or track pending mutations across components.

## Bad Example

```vue
<script setup lang="ts">
// Prop drilling mutation state
const mutation = useMutation({ mutationFn: createPost })

// Parent passes isPending to Header, Sidebar, Content, Footer
// Or using provide/inject for every mutation - overly complex
</script>

<template>
  <div>
    <Header :is-pending="mutation.isPending" />
    <Sidebar :is-pending="mutation.isPending" />
    <Content :mutation="mutation" />
    <Footer :is-pending="mutation.isPending" />
  </div>
</template>
```

## Good Example

```vue
<script setup lang="ts">
// composables/useCreatePost.ts
import { useMutation } from '@tanstack/vue-query'

export function useCreatePost() {
  return useMutation({
    mutationKey: ['create-post'],
    mutationFn: createPost,
  })
}
</script>
```

```vue
<script setup lang="ts">
// CreatePostButton.vue - triggers mutation
import { useCreatePost } from '@/composables/useCreatePost'

const mutation = useCreatePost()
const newPost = ref({ title: '', content: '' })
</script>

<template>
  <button @click="mutation.mutate(newPost)">
    Create Post
  </button>
</template>
```

```vue
<script setup lang="ts">
// GlobalLoadingIndicator.vue - tracks mutation state from anywhere
import { useMutationState } from '@tanstack/vue-query'

const pendingMutations = useMutationState({
  filters: { status: 'pending' },
  select: (mutation) => mutation.state.variables,
})
</script>

<template>
  <div v-if="pendingMutations.length > 0" class="global-loading">
    Saving {{ pendingMutations.length }} item(s)...
  </div>
</template>
```

## Good Example: Optimistic UI in Separate Component

```vue
<script setup lang="ts">
// TodoForm.vue - mutation defined in form
import { useMutation } from '@tanstack/vue-query'

const createTodo = useMutation({
  mutationKey: ['create-todo'],
  mutationFn: (todo: NewTodo) => api.createTodo(todo),
})
</script>

<template>
  <form @submit.prevent="...">...</form>
</template>
```

```vue
<script setup lang="ts">
// TodoList.vue - optimistic display (different component)
import { useQuery, useMutationState } from '@tanstack/vue-query'

const { data: todos } = useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
})

// Get pending todo creations
const pendingTodos = useMutationState({
  filters: {
    mutationKey: ['create-todo'],
    status: 'pending',
  },
  select: (mutation) => mutation.state.variables as NewTodo,
})
</script>

<template>
  <ul>
    <!-- Existing todos -->
    <TodoItem
      v-for="todo in todos"
      :key="todo.id"
      :todo="todo"
    />

    <!-- Optimistic todos (pending creation) -->
    <TodoItem
      v-for="(todo, index) in pendingTodos"
      :key="`pending-${index}`"
      :todo="{ ...todo, id: `temp-${index}` }"
      is-pending
    />
  </ul>
</template>
```

## Good Example: Track Specific Mutations

```vue
<script setup lang="ts">
import { useMutationState } from '@tanstack/vue-query'
import { computed } from 'vue'

const props = defineProps<{ postId: string }>()

// Track if THIS post is being deleted
const deletingMutations = useMutationState({
  filters: {
    mutationKey: ['delete-post', props.postId],
    status: 'pending',
  },
  select: () => true,
})

const isDeletingThisPost = computed(() => deletingMutations.value.length > 0)

// Track if THIS post is being updated
const updatingMutations = useMutationState({
  filters: {
    mutationKey: ['update-post', props.postId],
    status: 'pending',
  },
  select: () => true,
})

const isUpdatingThisPost = computed(() => updatingMutations.value.length > 0)
</script>

<template>
  <div>
    <button :disabled="isDeletingThisPost || isUpdatingThisPost">
      {{ isDeletingThisPost ? 'Deleting...' : 'Delete' }}
    </button>
  </div>
</template>
```

## Filters Reference

```ts
useMutationState({
  filters: {
    mutationKey: ['key'],           // Match mutation key
    status: 'pending',              // 'idle' | 'pending' | 'success' | 'error'
    predicate: (mutation) => bool,  // Custom filter function
  },
  select: (mutation) => {
    // Transform each matching mutation
    // mutation.state contains: variables, data, error, status, etc.
    return mutation.state.variables
  },
})
```

## Context

- Requires `mutationKey` on mutations you want to track
- Returns array of selected values from matching mutations
- Updates reactively as mutations progress
- Use `status` filter to track pending/success/error states
- Enables optimistic UI without prop drilling
- Pairs with `mutationKey` arrays for granular tracking (e.g., `['delete-post', postId]`)
