# Hedaya Data (أذكار وأدعية)

Data is kept in JSON here so it stays separate from app logic. You can add or edit groups and azkar without changing Swift code.

## Structure

- **`groups.json`** – List of all groups (order, name, icon, color, tags).
- **`azkar/<id>.json`** – One file per group; `id` must match the `id` in `groups.json`.

## Adding a new group

1. In **`groups.json`**, add an object with: `id`, `name`, `icon`, `color`, `tags`, `order`.
2. Create **`azkar/<your_id>.json`** with an array of `{ "text", "repetitions", "reference" }`.

Example for a new Ad3ia category (e.g. travel):

```json
// In groups.json add:
{ "id": "ad3ia_travel", "name": "أدعية السفر", "icon": "airplane", "color": "ad3ia", "tags": ["Ad3ia"], "order": 7 }
```

Then add `azkar/ad3ia_travel.json` with the duas.

## Tags

- **`Ad3ia`** – أدعية (supplications); card subtitle shows “X أدعية” instead of “X أذكار”.
- **`MostPopular`** – Use for “أدعية الأكثر شيوعاً” or other “most popular” categories.
- **`From Quran`** – أدعية قرآنية (Quranic supplications); source is the Quran with سورة/آية references.

## Colors (for `color` field)

Use one of: `morning`, `evening`, `prayer`, `sleep`, `misc`, `ad3ia`. The app maps these to gradients.
