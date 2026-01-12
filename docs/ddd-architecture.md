# DDD Component Architecture

## Structure

Path: `components/[Domain]/[Feature]/[Function]/`
File: `[Domain][Feature][Function][Name].vue`

Kebab folders → PascalCase prefixes.

## Hierarchy

1. **Domain** - business vertical (`patient-care`, `records`, `inventory`, `catalog`, `calendar`, `reporting`, `settings`)
2. **Feature** - logical module (`plans`, `laboratory`)
3. **Function** - UI pattern (`form`, `list`, `card`, `chart`, `dialog`, `menu`)
4. **Component** - the Vue file

## Function Types

| Function               | Purpose                    |
| ---------------------- | -------------------------- |
| `form/`, `form/fields` | inputs, fieldsets, wizards |
| `list/`                | tables, rows, grids        |
| `card/`                | summaries, widgets         |
| `chart/`               | visualisations, graphs     |
| `dialog/`              | modals, drawers            |
| `menu/`                | context menus, dropdowns   |

## Examples

| Path                            | Filename                              |
| ------------------------------- | ------------------------------------- |
| `patient-care/plans/list/`      | `PatientCarePlansListActive.vue`      |
| `patient-care/laboratory/card/` | `PatientCareLaboratoryCardResult.vue` |
| `inventory/stock/actions/`      | `InventoryStockActionsAdjust.vue`     |

## Rules

- Simple forms can be contained directly within dialog components
- Extract forms to `form/` only when reused across multiple dialogs or contexts
- Generic components (`StatusBadge`) → `base/` or `ui/`
- Domain-specific shared components stay in primary domain, imported elsewhere
- No barrel files (`index.ts`) in domain folders - direct imports only

## Creating Components

Before creating, verify:

1. **Filename matches path** - `inventory/stock/list/` → starts with `InventoryStockList`
2. **No generic names** - never `Create.vue`, `Index.vue`, `Form.vue`, `List.vue`
3. **Correct function folder** - form logic in `form/`, not `dialog/`
4. **Single responsibility** - one component = one purpose
5. **Import direction** - lower domains can import from higher, not reverse

## Translations

Translation keys follow the same structure as file paths. Use dots instead of hyphens.

**Path:** `pages.[domain].[feature].[function].*`

**Folder path to translation path:**

- `components/inventory/stock-locations/` → `pages.inventory.stock.locations`
- `components/patient-care/plans/` → `pages.patientCare.plans`

**Structure:**

```json
{
  "pages": {
    "inventory": {
      "stock": {
        "locations": {
          "list": {
            "header": "Stock Locations",
            "createButton": "Add Location",
            "filters": { "searchPlaceholder": "Search locations..." }
          },
          "form": {
            "createTitle": "Create Stock Location",
            "editTitle": "Edit Stock Location",
            "nameLabel": "Name",
            "cancel": "Cancel",
            "validation": { "nameRequired": "Name is required" }
          },
          "toast": {
            "create": {
              "success": "Stock location created",
              "error": "Failed to create"
            },
            "edit": {
              "success": "Stock location updated",
              "error": "Failed to update"
            },
            "delete": {
              "success": "Stock location deleted",
              "error": "Failed to delete"
            }
          }
        }
      }
    }
  }
}
```

**Usage in components:**

```typescript
// Single translation variable scoped to feature
const t = useTranslation('pages.inventory.stock.locations')

// Access nested keys via dot notation
t('list.header') // "Stock Locations"
t('list.createButton') // "Add Location"
t('form.nameLabel') // "Name"
t('form.validation.nameRequired') // "Name is required"
t('toast.create.success') // "Stock location created"
t('toast.edit.error') // "Failed to update"
```

**Function categories match component folders:**
| Function | Purpose |
|----------|---------|
| `list` | Headers, buttons, filters, column labels for list views |
| `form` | Labels, titles, buttons, validation for forms |
| `toast` | Success/error notification messages (nested by action: create, edit, delete) |
| `dialog` | Dialog-specific text (if needed beyond form titles) |

## Edge Cases

| Scenario                             | Resolution                                                                        |
| ------------------------------------ | --------------------------------------------------------------------------------- |
| Component used by 2+ domains equally | `shared/[feature]/`                                                               |
| Form reused in multiple dialogs      | Extract to `[...]Form.vue`, dialog imports form                                   |
| Simple form in single dialog         | Keep form inline within dialog component                                          |
| Nested feature                       | `patient-care/laboratory/results/` → `PatientCareLaboratoryResults[Function].vue` |
| Page-level component                 | `pages/`, not `components/`                                                       |
| Composable                           | `composables/[domain]/use[Domain][Feature].ts`                                    |

## Common Translations Reference

Use `const tCommon = useTranslation('common')` for reusable strings:

| Key                      | Values                                                                                                                                |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------- |
| `generalActions.*`       | save, cancel, delete, edit, add, update, archive, retry, search, confirm, restore, back, continue, apply, clear, goBack, share, print |
| `generalStatuses.*`      | active, archived, draft, sent, sending, open, created, creating, ready, rejected, updated, ongoing, all, loading                      |
| `boolean.*`              | yes, no                                                                                                                               |
| `dateAndTime.*`          | date, time, hour, startDate, endDate, years_one/other, months_one/other, days_one/other                                               |
| `dataTable.columns.*`    | id, date, name, email, phone, status, actions, firstName, lastName, client, veterinarian, clinic                                      |
| `dataTable.emptyState.*` | header, description, descriptionNoMatches, buttonClearFilters                                                                         |
| `generalFormFields.*`    | email, phone, tags, remarks, reasonType, reason, veterinarian, department                                                             |
| `enums.*`                | invoiceStatus, invoicePaymentStatus, invoiceType, paymentMethod, patientSex, consultationTypes, consultationStatus                    |

**Example usage:**

```ts
const tCommon = useTranslation('common')
tCommon('generalActions.save') // "Save"
tCommon('generalActions.cancel') // "Cancel"
tCommon('boolean.yes') // "Yes"
tCommon('dataTable.columns.name') // "Name"
```
