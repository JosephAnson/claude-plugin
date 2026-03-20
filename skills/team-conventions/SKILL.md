---
name: team-conventions
description: Team code review conventions for ProVet Cloud frontend. Use when writing Vue components, composables, templates, or translations.
---

# Team Conventions

Coding patterns enforced during team code reviews. Apply when writing/modifying Vue components, composables, or translations.

## Nord Components

- Icon-only `<nord-button>` → add `square` prop; omit `size` on child `<nord-icon>` (inherits from button)
- Prefer CSS stack (`<div class="n:flex n:flex-col n:gap-m">`) over `<nord-stack>` component
- Prefer Tailwind classes (`n:flex n:flex-col n:gap-l`) over Nord layout web components

## Templates

- Emit directly in template unless handler has logic beyond the emit call
- No wrapper methods that only call `emit`

```vue
<!-- ✓ -->
<nord-button @click="emit('delete')">Delete</nord-button>

<!-- ✗ -->
<nord-button @click="handleDelete">Delete</nord-button>
<!-- where handleDelete() only calls emit('delete') -->
```

## Composables

- Params: `MaybeRefOrGetter<T>` + `toValue()` to unwrap
- TanStack Query keys: wrap in `computed()` when depending on reactive params
- API-only composables → `composables/api/ResourceName.ts`
- Domain logic composables → `composables/useResourceName.ts`

```typescript
// ✓
function useCatalogItems(
  pagination: MaybeRefOrGetter<PaginationState>,
  enabled?: MaybeRefOrGetter<boolean>,
) {
  return useQuery({
    queryKey: computed(() => keys.list(toValue(pagination))),
    queryFn: () => fetch({ query: toValue(pagination) }),
    enabled: toValue(enabled),
  })
}
```

## Reuse Before Creating

Check existing composables before writing new ones:

- **`useAuth()`** → user-scoped departments/department groups (don't query all)
- **`useFiltersStateSync()`** → filter state + debounce (don't write manual watchers)
- **`useConsultationItemDisplay()`** → item type display/translation

## Translations

- Search `locales/en-US/application.json` for existing keys before adding new ones
- Common duplicates: "Items", "Name", "Account number", "Delete", "Edit", "Save"
- Use `tCommon()` for shared strings

## Utilities

- Shared helpers used in 2+ components → extract to `utils/` with unit tests
- Don't duplicate functions across Create/Edit modals

## Imports

- Don't use `#components` alias — use actual relative paths instead
- Refactor existing `#components` imports to relative paths when encountered

## TypeScript

- No unnecessary `as` casts when type already matches
- Trust inference

## Render Functions

Keep TanStack Table cell renderers simple — single element preferred.

```typescript
// ✓
cell: (props) => h('span', { style: { paddingLeft: `${level * 1.25}rem` } }, title)

// ✗ nested divs for simple indentation
```

## Pre-Review Checklist

- [ ] Icon-only buttons: `square` prop, no `size` on child icons
- [ ] No emit-only wrapper methods
- [ ] Composable params: `MaybeRefOrGetter` + `toValue()`
- [ ] Query keys: `computed()` when reactive
- [ ] Shared helpers in `utils/` with tests
- [ ] No duplicate translation keys
- [ ] Checked existing composables first
- [ ] API composables in `composables/api/`
- [ ] Tailwind over Nord layout components
- [ ] No unnecessary type casts
