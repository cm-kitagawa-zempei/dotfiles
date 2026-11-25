async function call(method: string, token: string, body: unknown): Promise<void> {
  const res = await fetch(`https://slack.com/api/${method}`, {
    method: "POST",
    headers: { "Content-Type": "application/json; charset=utf-8", Authorization: `Bearer ${token}` },
    body: JSON.stringify(body),
  });
  const json = (await res.json()) as { ok: boolean; error?: string };
  if (!json.ok) throw new Error(`${method}: ${json.error ?? res.status}`);
}

// ユーザートークンで呼ぶと本人の発言として投稿される
export function postMessage(token: string, channel: string, text: string): Promise<void> {
  return call("chat.postMessage", token, { channel, text });
}

export function setStatus(token: string, emoji: string, text: string): Promise<void> {
  return call("users.profile.set", token, {
    profile: { status_emoji: emoji, status_text: text, status_expiration: 0 },
  });
}
