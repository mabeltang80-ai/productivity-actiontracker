# Meeting Action Tracker

A single-page tracker for actions agreed in meetings. Add an action with an owner and due date, tick it off when done, and see open, done and overdue counts at a glance. Overdue actions are highlighted in red.

- Plain HTML, CSS and JavaScript in one file (`index.html`). No build step, no dependencies.
- Data is stored in Supabase, so everyone using the site sees the same list. The page refreshes when the tab comes back into view and every 45 seconds.
- People sign in with a username and password. Passwords are stored by Supabase's built-in authentication (`auth.users`).

## Users

- A username maps to the email `username@actiontracker.example` in Supabase Auth. People only type the username.
- `public.profiles` links each account to its username, display name and role (`admin` or `member`).
- Only signed-in people with a profile can read or change actions.
- **Account > Change your password** is available to everyone.
- **Account > Add a user** is shown to admins only. It calls the `create-user` Edge Function (`supabase/functions/create-user`), which checks the caller is an admin before creating the account.

Change the starting passwords as soon as you have signed in, especially the admin account.

## Supabase setup

`supabase/schema.sql` holds the tables, access rules and notes on creating the first admin. The project URL and publishable key are at the top of the script in `index.html`. The publishable key is meant for browser code. Never put a secret or service role key in this file.

## Deploy to Vercel

1. Sign in at [vercel.com](https://vercel.com) and choose **Add New... > Project**.
2. Import this GitHub repository.
3. Set **Framework Preset** to **Other**. Leave Build Command and Output Directory empty.
4. Click **Deploy**.

`vercel.json` turns on clean URLs and adds basic security headers.
