# perf-select-transform: Use Select to Transform and Filter Data

## Priority: LOW

## Explanation

The `select` option transforms query data before it reaches your component. Use it for filtering, sorting, or deriving data. Benefits include memoization (re-runs only when data changes) and reduced component re-renders.

## Bad Example

```vue
<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed } from 'vue'

// Transforming in computed - runs on every render
const { data: todos } = useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
})

// This filtering runs on every render
const completedTodos = computed(() =>
  todos.value?.filter(todo => todo.completed) ?? []
)

const sortedTodos = computed(() =>
  [...completedTodos.value].sort((a, b) =>
    new Date(b.completedAt).getTime() - new Date(a.completedAt).getTime()
  )
)
</script>

<template>
  <TodoList :todos="sortedTodos" />
</template>
```

## Good Example

```vue
<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'

// Using select - runs only when data changes
const { data: completedTodos } = useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
  select: (todos) =>
    todos
      .filter(todo => todo.completed)
      .sort((a, b) =>
        new Date(b.completedAt).getTime() - new Date(a.completedAt).getTime()
      ),
})
</script>

<template>
  <TodoList :todos="completedTodos ?? []" />
</template>
```

## Good Example: Selecting Specific Fields

```vue
<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'

// Derive computed values
const { data: stats } = useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
  select: (todos) => ({
    total: todos.length,
    completed: todos.filter(t => t.completed).length,
    pending: todos.filter(t => !t.completed).length,
    completionRate: todos.length
      ? (todos.filter(t => t.completed).length / todos.length) * 100
      : 0,
  }),
})
</script>

<template>
  <div>
    <span>{{ stats?.completed }} / {{ stats?.total }} completed</span>
    <span>({{ stats?.completionRate.toFixed(1) }}%)</span>
  </div>
</template>
```

## Good Example: Stable Select with Computed

```vue
<script setup lang="ts">
import { useQuery } from '@tanstack/vue-query'
import { computed } from 'vue'

// When select depends on external values, make it reactive
const props = defineProps<{ status: 'all' | 'active' | 'completed' }>()

const selectTodos = computed(() => (todos: Todo[]) => {
  switch (props.status) {
    case 'active':
      return todos.filter(t => !t.completed)
    case 'completed':
      return todos.filter(t => t.completed)
    default:
      return todos
  }
})

const { data: filteredTodos } = useQuery({
  queryKey: ['todos'],
  queryFn: fetchTodos,
  select: selectTodos,
})
</script>

<template>
  <TodoList :todos="filteredTodos ?? []" />
</template>
```

## Good Example: Picking Single Item from List

```ts
// composables/useTodoById.ts
import { useQuery } from '@tanstack/vue-query'

export function useTodoById(id: number) {
  return useQuery({
    queryKey: ['todos'],
    queryFn: fetchTodos,
    select: (todos) => todos.find(todo => todo.id === id),
  })
}
```

```vue
<script setup lang="ts">
// Usage - shares cache with list query
import { useTodoById } from '@/composables/useTodoById'

const props = defineProps<{ id: number }>()
const { data: todo } = useTodoById(props.id)
</script>

<template>
  <div v-if="!todo">Todo not found</div>
  <div v-else>{{ todo.title }}</div>
</template>
```

## When to Use Select

| Scenario | Use Select? |
|----------|-------------|
| Filtering list data | Yes |
| Sorting data | Yes |
| Computing derived values | Yes |
| Picking single item from list | Yes |
| Heavy transformations | Yes (memoized) |
| Simple data pass-through | No |
| Transformation needs external state | Yes, with computed |

## Context

- `select` leverages structural sharing - only re-runs when data actually changes
- Original query data stays cached; transformation applies to consumer
- Multiple components can use different `select` on the same query
- In Vue, wrap select function in `computed` when it depends on reactive values
- For complex transformations, consider computed in component instead if readability suffers
