# Meeting Action Tracker

A single-page tracker for actions agreed in meetings. Add an action with an owner and due date, tick it off when done, and see open, done and overdue counts at a glance. Overdue actions are highlighted in red.

- Plain HTML, CSS and JavaScript in one file (`index.html`). No build step, no dependencies.
- Data is stored in Supabase, so everyone using the site sees the same list. The page refreshes when the tab comes back into view and every 45 seconds.
- `supabase/schema.sql` holds the table, access rules and sample data.

## Access

The site is open: anyone with the link can read, add, tick off and delete actions. Only the done flag can be changed after an action is created. If you later need sign-in, switch the row-level security policies to `authenticated` only and add a login step.

## Deploy to Vercel

1. Sign in at [vercel.com](https://vercel.com) and choose **Add New... > Project**.
2. Import this GitHub repository.
3. Set **Framework Preset** to **Other**. Leave Build Command and Output Directory empty.
4. Click **Deploy**.

`vercel.json` turns on clean URLs and adds basic security headers.

## Configuration

The Supabase project URL and publishable key are at the top of the script in `index.html`. The publishable key is meant for browser code. Never put a secret or service role key in this file.
