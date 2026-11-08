import { createClient } from 'npm:@supabase/supabase-js@2';

// Adds a tracker user. Only a signed-in admin may call it.
// verify_jwt is off because this function checks the caller's session and admin role itself.

const EMAIL_DOMAIN = 'actiontracker.example';

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, apikey, content-type, x-client-info',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, 'Content-Type': 'application/json' },
  });

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });
  if (req.method !== 'POST') return json({ error: 'Use POST.' }, 405);

  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { persistSession: false, autoRefreshToken: false } },
  );

  // 1. Who is calling?
  const token = (req.headers.get('Authorization') ?? '').replace(/^Bearer\s+/i, '');
  if (!token) return json({ error: 'Sign in first.' }, 401);
  const { data: caller, error: callerError } = await admin.auth.getUser(token);
  if (callerError || !caller?.user) {
    return json({ error: 'Your session has expired. Sign in again.' }, 401);
  }

  // 2. Are they an admin?
  const { data: profile } = await admin
    .from('profiles')
    .select('role')
    .eq('id', caller.user.id)
    .maybeSingle();
  if (profile?.role !== 'admin') return json({ error: 'Only an admin can add users.' }, 403);

  // 3. Check the request.
  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json({ error: 'Invalid request.' }, 400);
  }
  const username = String(body.username ?? '').trim().toLowerCase();
  const password = String(body.password ?? '');
  if (!/^[a-z0-9._-]{2,30}$/.test(username)) {
    return json({ error: 'Username needs 2 to 30 letters, numbers, dots, dashes or underscores.' }, 400);
  }
  if (password.length < 6) {
    return json({ error: 'The password needs at least 6 characters.' }, 400);
  }
  const displayName = username.charAt(0).toUpperCase() + username.slice(1);

  // 4. Username already used?
  const { data: existing } = await admin
    .from('profiles')
    .select('id')
    .eq('username', username)
    .maybeSingle();
  if (existing) return json({ error: 'That username is already taken.' }, 409);

  // 5. Create the sign-in account (password is stored in auth.users), then its profile.
  const { data: created, error: createError } = await admin.auth.admin.createUser({
    email: `${username}@${EMAIL_DOMAIN}`,
    password,
    email_confirm: true,
    user_metadata: { username },
  });
  if (createError || !created?.user) {
    return json({ error: 'Could not create the user.' }, 500);
  }

  const { error: profileError } = await admin.from('profiles').insert({
    id: created.user.id,
    username,
    display_name: displayName,
    role: 'member',
  });
  if (profileError) {
    await admin.auth.admin.deleteUser(created.user.id);
    return json({ error: 'Could not create the user.' }, 500);
  }

  return json({ ok: true, username, display_name: displayName, role: 'member' });
});
